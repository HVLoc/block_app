import 'package:block/core/theme/app_colors.dart';
import 'package:block/features/game/presentation/models/drag_info.dart';
import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  const BoardPainter({
    required this.board,
    this.drag,
    this.flashCells = const {},
  });
  final List<List<int?>> board;
  final DragInfo? drag;
  final Set<String> flashCells;

  static const int _gridSize = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / _gridSize;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var r = 0; r < _gridSize; r++) {
      for (var c = 0; c < _gridSize; c++) {
        final rect = Rect.fromLTWH(
          c * cellW + 2,
          r * cellW + 2,
          cellW - 4,
          cellW - 4,
        );
        final colorIdx = board[r][c];
        final isFlashing = flashCells.contains('$r,$c');

        if (isFlashing) {
          paint.color = AppColors.flashCell;
        } else if (colorIdx != null) {
          paint.color = AppColors.piecePalette[colorIdx];
        } else {
          paint.color = AppColors.cellEmpty;
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      }
    }

    // Hover preview
    final d = drag;
    if (d != null && d.hoverRow != null && d.hoverCol != null) {
      paint.color = AppColors.piecePalette[d.piece.colorIndex].withValues(
        alpha: 0.45,
      );
      for (var r = 0; r < d.piece.rows; r++) {
        for (var c = 0; c < d.piece.cols; c++) {
          if (d.piece.matrix[r][c] == 1) {
            final tr = d.hoverRow! + r;
            final tc = d.hoverCol! + c;
            final rect = Rect.fromLTWH(
              tc * cellW + 2,
              tr * cellW + 2,
              cellW - 4,
              cellW - 4,
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(5)),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      oldDelegate.board != board ||
      oldDelegate.drag != drag ||
      oldDelegate.flashCells != flashCells;
}
