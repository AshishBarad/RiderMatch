import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);

  // Curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Cubic(
    0.4,
    0.0,
    0.2,
    1.0,
  ); // Similar to Framer Motion ease

  // Transitions
  static Widget slideAndFade({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(0, 0.1),
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: smoothCurve)),
        child: child,
      ),
    );
  }
}
