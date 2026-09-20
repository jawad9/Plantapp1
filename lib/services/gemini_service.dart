import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

/// Result of a successful Gemini call, including which key in the pool
/// actually served the request (so the caller can remember it and skip
/// straight past exhausted keys next time).
class GeminiResult {
  final String text;
  final int workingKeyIndex;

  const GeminiResult({required this.text, required this.workingKeyIndex});
}

class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);

  @override
  String toString() => message;
}

/// Thin client for the Gemini API that automatically falls back through a
/// pool of API keys: it starts at [startIndex] and, if a key is rejected or
/// out of quota, tries the next one (wrapping around) until one succeeds or
/// every key has been exhausted. Used for the AI Plant Doctor's photo
/// analysis and the AI Chat assistant.
class GeminiService {
  GeminiService._();

  static const String _model = 'gemini-2.0-flash';

  static Uri _endpoint(String apiKey) => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
      );

  static const String _plantDoctorPrompt =
      'You are an expert houseplant doctor inside a gamified plant-care app. '
      'Look at this photo of a houseplant and identify the single most '
      'important visible issue (e.g. dry or browning leaf tips, yellowing, '
      'pests, wilting, leggy growth, signs of overwatering, etc). Reply with '
      'ONE short sentence in the style of an in-app quest: a terse diagnosis '
      'followed by a colon and a concrete care instruction. Example: '
      '"Monstera tips dry: Mist leaves and move 2ft toward an east window." '
      'Under 25 words. Plain text only, no markdown, no preamble.';

  static const String _chatSystemPrompt =
      "You are SproutRoll's in-app plant-care assistant: warm, concise, and "
      'a little playful, fitting a gamified jungle-themed app. Answer the '
      "player's plant-care questions practically and specifically. Keep "
      'replies short (2-4 sentences), plain text, no markdown.';

  /// Sends a plant photo to Gemini and returns a one-line diagnosis quest.
  static Future<GeminiResult> analyzeImage({
    required List<String> apiKeys,
    required int startIndex,
    required File image,
  }) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _plantDoctorPrompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 200},
    });

    return _sendWithFallback(apiKeys: apiKeys, startIndex: startIndex, body: body);
  }

  /// Sends a chat turn (with prior history) to Gemini and returns the reply.
  static Future<GeminiResult> chat({
    required List<String> apiKeys,
    required int startIndex,
    required List<ChatMessage> history,
  }) async {
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': _chatSystemPrompt},
        ],
      },
      'contents': history
          .map((m) => {
                'role': m.geminiRole,
                'parts': [
                  {'text': m.text},
                ],
              })
          .toList(),
      'generationConfig': {'temperature': 0.6, 'maxOutputTokens': 300},
    });

    return _sendWithFallback(apiKeys: apiKeys, startIndex: startIndex, body: body);
  }

  static Future<GeminiResult> _sendWithFallback({
    required List<String> apiKeys,
    required int startIndex,
    required String body,
  }) async {
    if (apiKeys.isEmpty) {
      throw const GeminiException('No Gemini API key configured.');
    }

    String? lastError;
    for (int attempt = 0; attempt < apiKeys.length; attempt++) {
      final index = (startIndex + attempt) % apiKeys.length;
      final apiKey = apiKeys[index];
      try {
        final response = await http
            .post(
              _endpoint(apiKey),
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final text = _extractText(response.body);
          if (text != null && text.trim().isNotEmpty) {
            return GeminiResult(text: text.trim(), workingKeyIndex: index);
          }
          lastError = 'Gemini returned an empty response.';
          continue;
        }

        // 429 (quota exhausted) and 400/401/403 (bad/expired key) both mean:
        // move on and try the next key in the pool.
        lastError = _describeError(response.statusCode, response.body);
      } catch (e) {
        lastError = 'Network error: $e';
      }
    }

    throw GeminiException(lastError ?? 'All Gemini API keys failed.');
  }

  static String? _extractText(String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return null;
    return parts.first['text'] as String?;
  }

  static String _describeError(int statusCode, String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final message = decoded['error']?['message'];
      if (message is String && message.isNotEmpty) {
        return 'Gemini error ($statusCode): $message';
      }
    } catch (_) {
      // Fall through to the generic message below.
    }
    return 'Gemini error: HTTP $statusCode';
  }
}
