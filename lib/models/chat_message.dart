/// A single turn in an AI Chat conversation.
class ChatMessage {
  final String text;
  final bool fromUser;
  final DateTime sentAt;

  const ChatMessage({
    required this.text,
    required this.fromUser,
    required this.sentAt,
  });

  /// Gemini's `contents[].role` value for this message.
  String get geminiRole => fromUser ? 'user' : 'model';
}
