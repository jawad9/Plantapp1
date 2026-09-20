import 'package:flutter/material.dart';

/// A translucent, fade+scale route used for the quest result, reward, and
/// paywall modals so the darkened screen behind them stays visible.
PageRouteBuilder<T> fadeScaleRoute<T>(Widget child, {Color barrierColor = Colors.black54}) {
  return PageRouteBuilder<T>(
    opaque: false,
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => child,
    transitionsBuilder: (_, animation, __, c) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: c,
        ),
      );
    },
  );
}
