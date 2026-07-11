import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({this.size = 16, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
      child: Icon(Icons.check, size: size * 0.65, color: Colors.white),
    );
  }
}
