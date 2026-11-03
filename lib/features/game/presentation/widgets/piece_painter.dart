import 'package:block/core/theme/block_decoration.dart';
import 'package:block/core/theme/block_theme.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:flutter/material.dart';

class PiecePainter extends CustomPainter {
  const PiecePainter({
    required this.piece,
    required this.color,
    this.theme = BlockTheme.classic,
  });
  final BlockTheme theme;
  final Piece piece;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / piece.cols;
    final cellH = size.height / piece.rows;
    final paint = Paint()..color = color;

    for (var r = 0; r < piece.rows; r++) {
      for (var c = 0; c < piece.cols; c++) {
        if (piece.matrix[r][c] == 1) {
          final rect = Rect.fromLTWH(
            c * cellW + 1.5,
            r * cellH + 1.5,
            cellW - 3,
            cellH - 3,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            paint,
          );
          BlockDecoration.paint(canvas, rect, piece.colorIndex, theme);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PiecePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.piece != piece ||
      oldDelegate.theme != theme;
}
