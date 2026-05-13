import 'package:flutter/material.dart';

class GlowingBorder extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;

  const GlowingBorder({
    super.key,
    required this.child,
    required this.glowColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
