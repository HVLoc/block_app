import 'package:block/core/theme/app_colors.dart';
import 'package:block/core/theme/block_theme.dart';
import 'package:block/features/game/presentation/models/drag_info.dart';
import 'package:block/features/game/presentation/widgets/board_painter.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.boardKey,
    required this.board,
    required this.dragNotifier,
    required this.flashCells,
    this.theme = BlockTheme.classic,
    this.onCellTap,
    super.key,
  });
  final GlobalKey boardKey;
  final BlockTheme theme;
  final void Function(int row, int col)? onCellTap;
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
              theme: theme,
              drag: drag,
              flashCells: flashCells,
            ),
            child: onCellTap == null
                ? null
                : GridView.count(
                    crossAxisCount: 8,
                    padding: EdgeInsets.zero,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(64, (index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      return Semantics(
                        label:
                            'Hàng ${row + 1}, cột ${col + 1}, '
                            '${board[row][col] == null ? 'trống' : 'có khối'}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            key: ValueKey('game_cell_${row}_$col'),
                            onTap: () => onCellTap!(row, col),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        ),
      ),
    ),
  );
}
