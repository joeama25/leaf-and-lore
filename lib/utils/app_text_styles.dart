import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 36, fontWeight: FontWeight.w400,
    color: AppColors.ink, height: 1.15,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 24, fontWeight: FontWeight.w400,
    color: AppColors.ink, height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 18, fontWeight: FontWeight.w500,
    color: AppColors.ink, height: 1.25,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10, fontWeight: FontWeight.w600,
    color: AppColors.inkMuted, letterSpacing: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.ink, height: 1.5,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.inkMuted, height: 1.5,
  );

  static const TextStyle small = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.white, letterSpacing: 0.3,
  );
}