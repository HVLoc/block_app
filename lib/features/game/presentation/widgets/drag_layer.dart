import 'package:block/core/theme/app_colors.dart';
import 'package:block/features/game/presentation/models/drag_info.dart';
import 'package:block/features/game/presentation/widgets/piece_painter.dart';
import 'package:flutter/material.dart';

class DragLayer extends StatelessWidget {
  const DragLayer({
    required this.dragNotifier,
    required this.boardRectNotifier,
    required this.gridSize,
    super.key,
  });
  final ValueNotifier<DragInfo?> dragNotifier;
  final ValueNotifier<Rect?> boardRectNotifier;
  final int gridSize;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: ValueListenableBuilder<DragInfo?>(
          valueListenable: dragNotifier,
          builder: (_, drag, __) {
            final cachedBoardRect = boardRectNotifier.value;
            if (drag == null || cachedBoardRect == null) {
              return const SizedBox.shrink();
            }
            final cellSize = cachedBoardRect.width / gridSize;
            final w = drag.piece.cols * cellSize;
            final h = drag.piece.rows * cellSize;
            return Stack(
              children: [
                Positioned(
                  left: drag.globalPos.dx - w / 2,
                  top: drag.globalPos.dy - h / 2 - 80.0,
                  child: CustomPaint(
                    size: Size(w, h),
                    painter: PiecePainter(
                      piece: drag.piece,
                      color: AppColors.piecePalette[drag.piece.colorIndex],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
