import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/quest_bank.dart';
import '../models/quest.dart';
import '../models/quest_type.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/modal_route.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/scan_line_overlay.dart';
import 'paywall_screen.dart';
import 'reward_popup_screen.dart';

enum _Stage { regularQuest, awaitingPhoto, scanning, diagnosisResult }

/// Screen 4: Quest & Diagnosis Result Modal. Branches into a regular
/// care/adopt/mission quest card, or the AI Plant Doctor photo flow
/// (credit check -> capture -> mock scan -> diagnosis quest).
class QuestResultScreen extends StatefulWidget {
  final QuestType questType;

  const QuestResultScreen({super.key, required this.questType});

  @override
  State<QuestResultScreen> createState() => _QuestResultScreenState();
}

class _QuestResultScreenState extends State<QuestResultScreen>
    with SingleTickerProviderStateMixin {
  late _Stage _stage;
  Quest? _quest;
  File? _photo;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.questType == QuestType.doctor) {
      _stage = _Stage.awaitingPhoto;
    } else {
      _stage = _Stage.regularQuest;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final appState = context.read<AppState>();
        setState(() => _quest = appState.rollQuest(widget.questType));
      });
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _goToPaywall() async {
    await Navigator.of(context).push(fadeScaleRoute(const PaywallScreen()));
    if (!mounted) return;
    final appState = context.read<AppState>();
    if (!appState.canScan) {
      // Player declined Pro - back out of the AI Doctor die to the arena.
      Navigator.of(context).pop();
    } else {
      // Mock purchase unlocked Pro - retry the scan immediately.
      _startPhotoQuest();
    }
  }

  Future<void> _startPhotoQuest() async {
    final appState = context.read<AppState>();
    if (!appState.canScan) {
      _goToPaywall();
      return;
    }

    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    } catch (_) {
      file = null;
    }
    if (file == null) {
      try {
        file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      } catch (_) {
        file = null;
      }
    }
    if (file == null || !mounted) return; // user cancelled both pickers

    if (!appState.consumeScanCredit()) {
      _goToPaywall();
      return;
    }

    setState(() {
      _photo = File(file!.path);
      _stage = _Stage.scanning;
    });

    _scanController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final diagnosis = QuestBank.randomDiagnosis();
    final quest = appState.submitDiagnosis(diagnosis);
    setState(() {
      _quest = quest;
      _stage = _Stage.diagnosisResult;
    });
  }

  void _claim() {
    final appState = context.read<AppState>();
    final earned = appState.claimPendingQuest();
    Navigator.of(context)
        .pushReplacement(fadeScaleRoute(RewardPopupScreen(coinsEarned: earned), barrierColor: Colors.black87));
  }

  void _forfeit() {
    final appState = context.read<AppState>();
    appState.forfeitPendingQuest();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ForfeitDialog(
        onDone: () => Navigator.of(dialogContext).popUntil((route) => route.isFirst),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(width: 320, child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_stage) {
      case _Stage.awaitingPhoto:
        return _AwaitingPhotoCard(onTakePhoto: _startPhotoQuest);
      case _Stage.scanning:
        return _ScanningCard(photo: _photo, controller: _scanController);
      case _Stage.regularQuest:
      case _Stage.diagnosisResult:
        if (_quest == null) {
          return const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(color: AppColors.neonMint),
          );
        }
        return _QuestCard(quest: _quest!, onClaim: _claim, onForfeit: _forfeit);
    }
  }
}

class _AwaitingPhotoCard extends StatelessWidget {
  final VoidCallback onTakePhoto;
  const _AwaitingPhotoCard({required this.onTakePhoto});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glow: true,
      glowColor: AppColors.amberGold,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.amberGold.withOpacity(0.15)),
            child: const Icon(Icons.camera_alt_rounded, color: AppColors.amberGold, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI Plant Doctor',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Snap a photo of your plant for a custom diagnosis quest.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.softSage, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GlowButton(label: 'Open Camera', icon: Icons.camera_alt_rounded, expand: true, onPressed: onTakePhoto),
        ],
      ),
    );
  }
}

class _ScanningCard extends StatelessWidget {
  final File? photo;
  final AnimationController controller;

  const _ScanningCard({required this.photo, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glow: true,
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (photo != null) Image.file(photo!, fit: BoxFit.cover) else Container(color: AppColors.surface),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => ScanLineOverlay(progress: controller.value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Analyzing foliage and soil...',
            style: TextStyle(color: AppColors.neonMint, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onClaim;
  final VoidCallback onForfeit;

  const _QuestCard({required this.quest, required this.onClaim, required this.onForfeit});

  @override
  Widget build(BuildContext context) {
    final bool isDoctor = quest.type == QuestType.doctor;
    return GlassCard(
      glow: true,
      glowColor: isDoctor ? AppColors.amberGold : AppColors.neonMint,
      borderRadius: 24,
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(quest.type.icon, color: AppColors.neonMint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quest.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quest.description,
            style: const TextStyle(color: AppColors.softSage, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.amberGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${quest.coinReward} Coins',
              style: const TextStyle(color: AppColors.amberGold, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 22),
          GlowButton(label: 'Done! Claim Coins', icon: Icons.check_circle_rounded, expand: true, onPressed: onClaim),
          const SizedBox(height: 10),
          GlowButton(
            label: "I Can't Do This",
            style: GlowButtonStyle.secondary,
            expand: true,
            onPressed: onForfeit,
          ),
        ],
      ),
    );
  }
}

class _ForfeitDialog extends StatelessWidget {
  final VoidCallback onDone;
  const _ForfeitDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'No worries, sprout!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Every jungle explorer skips a vine sometimes. Try another quest!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.softSage),
            ),
            const SizedBox(height: 20),
            GlowButton(label: 'Back to Jungle', expand: true, onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
