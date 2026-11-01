import 'package:block/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({required this.bestScore, required this.onReset, super.key});
  final int bestScore;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'KỶ LỤC: $bestScore',
          style: const TextStyle(
            color: AppColors.recordText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          key: const Key('game_reset_button'),
          onPressed: onReset,
          icon: const Icon(Icons.refresh, color: AppColors.scoreText),
        ),
      ],
    );
  }
}
