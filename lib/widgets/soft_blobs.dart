import 'dart:ui';

import 'package:flutter/material.dart';

import '../main.dart';

/// Soft yellow and green blobs behind the content. Only for login and onboarding.
class SoftBlobs extends StatelessWidget {
  const SoftBlobs({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PinjeminColors>()!;
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _Blob(color: colors.softYellow, size: 240),
        ),
        Positioned(
          bottom: -90,
          left: -70,
          child: _Blob(color: colors.positiveContainer, size: 260),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
