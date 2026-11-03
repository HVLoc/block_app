import 'package:block/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();
  static const gap = 8.0;
  static const gutter = 16.0;
  static const touchTarget = 48.0;
  static const boardMaxWidth = 520.0;
  static const panelMaxWidth = 560.0;

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.recordText,
      secondary: AppColors.recordText,
      surface: AppColors.dialogBackground,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.scoreText,
        minimumSize: const Size.square(touchTarget),
      ),
    ),
    tooltipTheme: const TooltipThemeData(preferBelow: true),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.dialogBackground,
      modalBarrierColor: AppColors.shadow,
      constraints: BoxConstraints(maxWidth: panelMaxWidth),
    ),
  );
}
