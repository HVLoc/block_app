import 'package:block/core/theme/app_colors.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:block/features/game/presentation/widgets/piece_painter.dart';
import 'package:flutter/material.dart';

class DockRow extends StatelessWidget {
  const DockRow({
    required this.dock,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    super.key,
  });
  final List<Piece?> dock;
  final void Function(int, DragStartDetails) onDragStart;
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(3, (i) {
          final p = dock[i];
          return Expanded(
            child: GestureDetector(
              key: ValueKey('game_dock_${i}_drag'),
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => onDragStart(i, d),
              onPanUpdate: onDragUpdate,
              onPanEnd: onDragEnd,
              onPanCancel: onDragCancel,
              child: Center(
                child: p == null
                    ? const SizedBox()
                    : CustomPaint(
                        size: Size(p.cols * 20.0, p.rows * 20.0),
                        painter: PiecePainter(
                          piece: p,
                          color: AppColors.piecePalette[p.colorIndex],
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
