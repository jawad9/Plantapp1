import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/modal_route.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import 'paywall_screen.dart';

/// App settings: subscription status and the Gemini API key pool that
/// powers the AI Plant Doctor, photo analysis, and AI Chat.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscureInput = true;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _addKey() async {
    final appState = context.read<AppState>();
    final value = _keyController.text.trim();
    if (value.isEmpty) {
      setState(() => _errorText = 'Enter a Gemini API key first.');
      return;
    }
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    final added = await appState.addGeminiApiKey(value);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (added) {
      _keyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.surface,
          content: Text('API key added.'),
        ),
      );
    } else {
      setState(() => _errorText = 'That key is already in your list.');
    }
  }

  Future<void> _removeKey(int index) async {
    await context.read<AppState>().removeGeminiApiKey(index);
  }

  String _maskKey(String key) {
    if (key.length <= 8) return '${key.substring(0, key.length > 2 ? 2 : key.length)}••••';
    return '${key.substring(0, 4)}••••••••${key.substring(key.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _SectionLabel('Account'),
            const SizedBox(height: 10),
            GlassCard(
              borderRadius: 18,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (appState.isPro ? AppColors.neonMint : AppColors.softSage)
                          .withOpacity(0.15),
                    ),
                    child: Icon(
                      appState.isPro ? Icons.workspace_premium_rounded : Icons.person_rounded,
                      color: appState.isPro ? AppColors.neonMint : AppColors.softSage,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.isPro ? 'Pro member' : 'Free plan',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appState.isPro
                              ? 'Unlimited scans · 2x coins · Neon skins'
                              : '${appState.scanCredits}/${AppState.maxScanCredits} AI Doctor scans today',
                          style: const TextStyle(color: AppColors.softSage, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (!appState.isPro)
                    GlowButton(
                      label: 'Upgrade',
                      style: GlowButtonStyle.secondary,
                      onPressed: () => Navigator.of(context).push(fadeScaleRoute(const PaywallScreen())),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const _SectionLabel('Gemini API Keys'),
            const SizedBox(height: 6),
            const Text(
              'Add your own Gemini API key to power the AI Plant Doctor, photo '
              'analysis, and AI Chat. Add more than one - if a key runs out of '
              'quota, SproutRoll automatically switches to the next one.',
              style: TextStyle(color: AppColors.softSage, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 14),
            GlassCard(
              borderRadius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _keyController,
                          obscureText: _obscureInput,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Paste Gemini API key',
                            hintStyle: const TextStyle(color: AppColors.softSage),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.neonMint.withOpacity(0.2)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.neonMint.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.neonMint),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureInput ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: AppColors.softSage,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscureInput = !_obscureInput),
                            ),
                          ),
                          onSubmitted: (_) => _addKey(),
                        ),
                      ),
                    ],
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  GlowButton(
                    label: _submitting ? 'Adding...' : 'Add API Key',
                    icon: Icons.vpn_key_rounded,
                    expand: true,
                    onPressed: _submitting ? null : _addKey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (appState.geminiApiKeys.isEmpty)
              const GlassCard(
                borderRadius: 16,
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.softSage, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No API keys added yet - AI Doctor will use a demo '
                        'diagnosis until you add one.',
                        style: TextStyle(color: AppColors.softSage, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(appState.geminiApiKeys.length, (index) {
                final key = appState.geminiApiKeys[index];
                final isActive = index == appState.activeGeminiKeyIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    borderRadius: 14,
                    borderColor: isActive
                        ? AppColors.neonMint.withOpacity(0.5)
                        : AppColors.neonMint.withOpacity(0.15),
                    child: Row(
                      children: [
                        Icon(
                          Icons.key_rounded,
                          color: isActive ? AppColors.neonMint : AppColors.softSage,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _maskKey(key),
                            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonMint.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(color: AppColors.neonMint, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Fallback',
                              style: TextStyle(color: AppColors.softSage, fontSize: 11),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                          onPressed: () => _removeKey(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.softSage,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
