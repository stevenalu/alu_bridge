import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle get _base => GoogleFonts.sourceSans3();

  static TextStyle eyebrow = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: AppColors.red,
  );

  static TextStyle h1 = _base.copyWith(
    fontSize: 27,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.navy,
  );

  static TextStyle h2 = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static TextStyle h3 = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static TextStyle body = _base.copyWith(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static TextStyle sub = _base.copyWith(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
  );

  static TextStyle tiny = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.grey400,
  );

  static TextStyle label = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.navy,
  );

  static TextStyle button = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
}
