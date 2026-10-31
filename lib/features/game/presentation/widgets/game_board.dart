import 'package:block/core/theme/app_colors.dart';
import 'package:block/features/game/presentation/models/drag_info.dart';
import 'package:block/features/game/presentation/widgets/board_painter.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.boardKey,
    required this.board,
    required this.dragNotifier,
    required this.flashCells,
    super.key,
  });
  final GlobalKey boardKey;
  final List<List<int?>> board;
  final ValueNotifier<DragInfo?> dragNotifier;
  final Set<String> flashCells;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AspectRatio(
      aspectRatio: 1,
      child: Container(
        key: boardKey,
        decoration: BoxDecoration(
          color: AppColors.boardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ValueListenableBuilder<DragInfo?>(
          valueListenable: dragNotifier,
          builder: (_, drag, _) => CustomPaint(
            painter: BoardPainter(
              board: board,
              drag: drag,
              flashCells: flashCells,
            ),
          ),
        ),
      ),
    ),
  );
}
