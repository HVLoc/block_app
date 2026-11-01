import 'package:block/features/game/domain/entities/piece.dart';
import 'package:flutter/material.dart';

class PiecePainter extends CustomPainter {
  const PiecePainter({required this.piece, required this.color});
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
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PiecePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.piece != piece;
}
