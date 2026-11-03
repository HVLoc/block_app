import 'package:block/core/theme/app_colors.dart';
import 'package:block/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    required this.bestScore,
    required this.onReset,
    required this.onThemes,
    super.key,
  });
  final int bestScore;
  final VoidCallback onReset;
  final VoidCallback onThemes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'BLOCKS',
                style: TextStyle(
                  color: AppColors.scoreText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'KỶ LỤC: $bestScore',
                style: const TextStyle(
                  color: AppColors.recordText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('game_themes_button'),
          tooltip: 'Chủ đề',
          onPressed: onThemes,
          icon: const Icon(Icons.palette_outlined, color: AppColors.scoreText),
        ),
        const SizedBox(width: AppTheme.gap),
        IconButton(
          key: const Key('game_reset_button'),
          tooltip: 'Chơi lại',
          onPressed: onReset,
          icon: const Icon(Icons.refresh, color: AppColors.scoreText),
        ),
      ],
    );
  }
}
