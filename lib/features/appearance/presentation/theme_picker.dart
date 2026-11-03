import 'dart:async';

import 'package:block/core/theme/app_colors.dart';
import 'package:block/core/theme/app_theme.dart';
import 'package:block/core/theme/block_decoration.dart';
import 'package:block/core/theme/block_theme.dart';
import 'package:block/features/appearance/presentation/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({required this.controller, super.key});
  final ThemeController controller;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.gutter),
          child: Obx(() {
            final selected = controller.theme.value;
            final saving = controller.isSaving.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Chủ đề khối',
                        style: TextStyle(
                          color: AppColors.scoreText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('theme_picker_close'),
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.scoreText),
                    ),
                  ],
                ),
                const Text(
                  'Chọn phong cách bạn thích. Lựa chọn được lưu tự động.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                for (final theme in BlockTheme.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Semantics(
                      selected: selected == theme,
                      enabled: !saving,
                      child: Material(
                        color: selected == theme
                            ? AppColors.cellEmpty
                            : AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: selected == theme
                                ? AppColors.recordText
                                : AppColors.controlBorder,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          key: ValueKey('theme_option_${theme.name}'),
                          onTap: saving
                              ? null
                              : () => unawaited(controller.selectTheme(theme)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: (selected == theme
                                                ? AppColors.recordText
                                                : AppColors.controlBorder)
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        theme.icon,
                                        size: 18,
                                        color: selected == theme
                                            ? AppColors.recordText
                                            : AppColors.scoreText,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        theme.label,
                                        style: const TextStyle(
                                          color: AppColors.scoreText,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    if (selected == theme)
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.recordText,
                                        size: 22,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  theme.description,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 32,
                                  child: CustomPaint(
                                    painter: _ThemePreview(theme),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (saving) const LinearProgressIndicator(),
                if (controller.errorMessage.value != null)
                  Text(
                    controller.errorMessage.value!,
                    key: const Key('theme_save_error'),
                    semanticsLabel: controller.errorMessage.value,
                    style: const TextStyle(color: AppColors.recordText),
                  ),
              ],
            );
          }),
        ),
      ),
    ),
  );
}

class _ThemePreview extends CustomPainter {
  const _ThemePreview(this.theme);
  final BlockTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = ((size.width - 18) / 7).clamp(0.0, size.height);
    for (var i = 0; i < 7; i++) {
      final rect = Rect.fromLTWH(i * (cell + 3), 0, cell - 3, cell - 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()..color = AppColors.piecePalette[i],
      );
      BlockDecoration.paint(canvas, rect, i, theme);
    }
  }

  @override
  bool shouldRepaint(covariant _ThemePreview oldDelegate) =>
      oldDelegate.theme != theme;
}
