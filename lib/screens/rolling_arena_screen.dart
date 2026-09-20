import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/store_bank.dart';
import '../models/quest_type.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/modal_route.dart';
import '../widgets/dice_painter.dart';
import '../widgets/glow_button.dart';
import 'quest_result_screen.dart';

/// Screen 3: The Rolling Arena. A big isometric die tumbles in pseudo-3D
/// when the player taps "Start Adventure" or shakes the device, then
/// settles and bursts into the quest result modal.
class RollingArenaScreen extends StatefulWidget {
  final QuestType questType;

  const RollingArenaScreen({super.key, required this.questType});

  @override
  State<RollingArenaScreen> createState() => _RollingArenaScreenState();
}

class _RollingArenaScreenState extends State<RollingArenaScreen>
    with TickerProviderStateMixin {
  static const double _shakeThreshold = 22.0;
  static const Duration _shakeCooldown = Duration(milliseconds: 1500);

  late final AnimationController _tumbleController;
  late final AnimationController _burstController;
  late final Animation<double> _scale;
  Animation<double>? _animX;
  Animation<double>? _animY;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _hapticTimer;
  bool _isRolling = false;
  bool _settled = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _tumbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _tumbleController, curve: Curves.easeOut));

    _tumbleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSettled();
      }
    });

    _accelSub = accelerometerEventStream().listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final double delta = (magnitude - 9.8).abs();
    final now = DateTime.now();
    if (delta > _shakeThreshold &&
        now.difference(_lastShake) > _shakeCooldown &&
        !_isRolling) {
      _lastShake = now;
      _startRoll();
    }
  }

  void _startRoll() {
    if (_isRolling) return;
    setState(() {
      _isRolling = true;
      _settled = false;
    });

    final double turnsX = (2 + _random.nextInt(2)) * 2 * pi;
    final double turnsY = (3 + _random.nextInt(2)) * 2 * pi;

    _tumbleController
      ..reset()
      ..duration = const Duration(milliseconds: 1500);

    // Build fresh tweens with randomized end rotation for each tumble.
    final rotX = Tween<double>(begin: 0, end: turnsX)
        .chain(CurveTween(curve: Curves.easeOutCubic));
    final rotY = Tween<double>(begin: 0, end: turnsY)
        .chain(CurveTween(curve: Curves.easeOutCubic));

    setState(() {
      _animX = rotX.animate(_tumbleController);
      _animY = rotY.animate(_tumbleController);
    });

    HapticFeedback.mediumImpact();
    int tick = 0;
    _hapticTimer?.cancel();
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      tick++;
      HapticFeedback.selectionClick();
      if (tick > 8) timer.cancel();
    });

    _tumbleController.forward();
  }

  void _onSettled() {
    _hapticTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isRolling = false;
      _settled = true;
    });
    _burstController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      Navigator.of(context)
          .push(fadeScaleRoute(QuestResultScreen(questType: widget.questType)))
          .then((_) {
        if (mounted) {
          setState(() => _settled = false);
          _burstController.reset();
        }
      });
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _hapticTimer?.cancel();
    _tumbleController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final skinColors = StoreBank.colorsForSkin(appState.activeSkinId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.questType.label),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _isRolling ? 'Rolling...' : 'Shake your phone or tap below',
              style: const TextStyle(color: AppColors.softSage, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _burstController,
                    builder: (context, child) {
                      final double burst = _burstController.value;
                      if (burst <= 0) return const SizedBox.shrink();
                      return Container(
                        width: 260 * (1 + burst * 1.5),
                        height: 260 * (1 + burst * 1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.neonMint.withOpacity(0.35 * (1 - burst)),
                              AppColors.neonMint.withOpacity(0.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _tumbleController,
                    builder: (context, child) {
                      final double rx = _animX?.value ?? 0;
                      final double ry = _animY?.value ?? 0;
                      final matrix = Matrix4.identity()
                        ..setEntry(3, 2, 0.0025)
                        ..rotateX(rx)
                        ..rotateY(ry);
                      return Transform(
                        alignment: Alignment.center,
                        transform: matrix,
                        child: Transform.scale(
                          scale: _scale.value,
                          child: CustomPaint(
                            size: const Size(220, 220),
                            painter: DicePainter(
                              skinColors: skinColors,
                              glowStrength: _isRolling ? 0.9 : (_settled ? 1.0 : 0.5),
                              faceIcon: _settled ? widget.questType.icon : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: GlowButton(
                label: _isRolling ? 'Rolling...' : 'START ADVENTURE',
                icon: Icons.casino_rounded,
                expand: true,
                onPressed: _isRolling ? null : _startRoll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
