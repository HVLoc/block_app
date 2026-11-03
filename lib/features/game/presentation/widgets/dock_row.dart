import 'package:block/core/theme/app_colors.dart';
import 'package:block/core/theme/block_theme.dart';
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
    this.theme = BlockTheme.classic,
    this.selectedSlot,
    this.onSelectSlot,
    super.key,
  });
  final List<Piece?> dock;
  final BlockTheme theme;
  final int? selectedSlot;
  final ValueChanged<int>? onSelectSlot;
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
              child: Semantics(
                label: p == null
                    ? 'Vị trí khối ${i + 1} trống'
                    : 'Khối ${i + 1}, ${p.rows} hàng, ${p.cols} cột',
                selected: selectedSlot == i,
                child: Material(
                  color: selectedSlot == i
                      ? AppColors.cellEmpty
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selectedSlot == i
                          ? AppColors.recordText
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: p == null || onSelectSlot == null
                        ? null
                        : () => onSelectSlot!(i),
                    child: Center(
                      child: p == null
                          ? const SizedBox()
                          : CustomPaint(
                              size: Size(p.cols * 20.0, p.rows * 20.0),
                              painter: PiecePainter(
                                piece: p,
                                theme: theme,
                                color: AppColors.piecePalette[p.colorIndex],
                              ),
                            ),
                    ),
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
