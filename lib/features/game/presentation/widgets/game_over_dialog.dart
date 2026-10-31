import 'package:block/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    required this.score,
    required this.bestScore,
    required this.onRestart,
    super.key,
  });
  final int score;
  final int bestScore;
  final VoidCallback onRestart;
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.dialogBackground,
    title: const Text(
      'Hết nước đi!',
      style: TextStyle(color: AppColors.scoreText),
    ),
    content: Text(
      'Điểm: $score\nKỷ lục: $bestScore',
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
    ),
    actions: [
      ElevatedButton(
        key: const Key('game_restart_button'),
        onPressed: onRestart,
        child: const Text('Chơi lại'),
      ),
    ],
  );
}
