import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/app_state.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import 'settings_screen.dart';

/// A simple chat interface backed by Gemini, sharing the same rotating API
/// key pool as the AI Plant Doctor's photo analysis.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    final appState = context.read<AppState>();

    setState(() {
      _messages.add(ChatMessage(text: text, fromUser: true, sentAt: DateTime.now()));
      _inputController.clear();
      _sending = true;
      _error = null;
    });
    _scrollToBottom();

    try {
      final result = await GeminiService.chat(
        apiKeys: appState.geminiApiKeys,
        startIndex: appState.activeGeminiKeyIndex,
        history: _messages,
      );
      appState.reportWorkingGeminiKeyIndex(result.workingKeyIndex);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: result.text, fromUser: false, sentAt: DateTime.now()));
        _sending = false;
      });
      _scrollToBottom();
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'Something went wrong: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AI Chat'),
      ),
      body: SafeArea(
        child: appState.hasGeminiKeys ? _buildChat() : const _NoKeysPrompt(),
      ),
    );
  }

  Widget _buildChat() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? const _EmptyChat()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _MessageBubble(message: _messages[index]),
                ),
        ),
        if (_sending)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Thinking...', style: TextStyle(color: AppColors.softSage, fontSize: 12)),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask about your plant...',
                    hintStyle: const TextStyle(color: AppColors.softSage),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: AppColors.neonMint.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: AppColors.neonMint.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppColors.neonMint),
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.neonMint,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.neonMint.withOpacity(0.4), blurRadius: 10)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.black),
                  onPressed: _sending ? null : _send,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.neonMint.withOpacity(0.16) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser ? AppColors.neonMint.withOpacity(0.35) : AppColors.neonMint.withOpacity(0.15),
          ),
        ),
        child: Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35)),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: AppColors.softSage, size: 40),
          SizedBox(height: 10),
          Text('Ask me anything about your plants!', style: TextStyle(color: AppColors.softSage)),
        ],
      ),
    );
  }
}

class _NoKeysPrompt extends StatelessWidget {
  const _NoKeysPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.vpn_key_rounded, color: AppColors.amberGold, size: 36),
              const SizedBox(height: 14),
              const Text(
                'Add a Gemini API key to chat',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI Chat, AI Doctor, and photo analysis all run on your own '
                'Gemini API key. Add one in Settings to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.softSage, fontSize: 13),
              ),
              const SizedBox(height: 18),
              GlowButton(
                label: 'Open Settings',
                icon: Icons.settings_rounded,
                expand: true,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
