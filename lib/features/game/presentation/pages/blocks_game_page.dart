import 'dart:async';
import 'dart:math' as math;

import 'package:block/core/theme/app_colors.dart';
import 'package:block/core/theme/app_theme.dart';
import 'package:block/features/appearance/presentation/theme_controller.dart';
import 'package:block/features/appearance/presentation/theme_picker.dart';
import 'package:block/features/game/presentation/controllers/game_controller.dart';
import 'package:block/features/game/presentation/widgets/animated_score_display.dart';
import 'package:block/features/game/presentation/widgets/dock_row.dart';
import 'package:block/features/game/presentation/widgets/drag_layer.dart';
import 'package:block/features/game/presentation/widgets/game_board.dart';
import 'package:block/features/game/presentation/widgets/game_header.dart';
import 'package:block/features/game/presentation/widgets/game_over_dialog.dart';
import 'package:block/features/game/presentation/widgets/score_popup_layer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlocksGamePage extends GetView<GameController> {
  const BlocksGamePage({super.key});
  @override
  Widget build(BuildContext context) => Obx(() {
    final appearance = Get.find<ThemeController>();
    final theme = appearance.theme.value;
    return GetBuilder<GameController>(
      builder: (game) => Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scaler = MediaQuery.textScalerOf(context);
                  final boardSide = math
                      .min(
                        math.min(
                          constraints.maxWidth - AppTheme.gutter * 2,
                          AppTheme.boardMaxWidth,
                        ),
                        math.max(
                          224,
                          constraints.maxHeight -
                              360 * (scaler.scale(16) / 16).clamp(1, 2),
                        ),
                      )
                      .toDouble();
                  final reduceMotion = MediaQuery.disableAnimationsOf(context);
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.gutter),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppTheme.panelMaxWidth,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GameHeader(
                                  bestScore: game.state.bestScore,
                                  onReset: () => unawaited(game.resetGame()),
                                  onThemes: () => unawaited(
                                    showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      builder: (_) =>
                                          ThemePicker(controller: appearance),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AnimatedScoreDisplay(
                                  scoreNotifier: game.scoreNotifier,
                                ),
                                const SizedBox(height: 16),
                                Semantics(
                                  label: 'Bảng chơi 8 hàng, 8 cột',
                                  child: SizedBox.square(
                                    dimension: boardSide,
                                    child: GameBoard(
                                      boardKey: game.boardKey,
                                      theme: theme,
                                      board: game.board,
                                      dragNotifier: game.dragNotifier,
                                      flashCells: game.flashCells,
                                      onCellTap: game.selectedSlot == null
                                          ? null
                                          : (row, col) => unawaited(
                                              game.placeSelectedAt(
                                                row,
                                                col,
                                                reduceMotion: reduceMotion,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DockRow(
                                  dock: game.dock,
                                  theme: theme,
                                  selectedSlot: game.selectedSlot,
                                  onSelectSlot: game.selectSlot,
                                  onDragStart: game.startDrag,
                                  onDragUpdate: (details) =>
                                      unawaited(game.updateDrag(details)),
                                  onDragEnd: (details) => unawaited(
                                    game.endDrag(
                                      details,
                                      reduceMotion: reduceMotion,
                                    ),
                                  ),
                                  onDragCancel: game.cancelDrag,
                                ),
                                const SizedBox(height: 8),
                                Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    game.moveHint ??
                                        'Kéo khối hoặc chạm chọn '
                                            'rồi chạm ô để đặt.',
                                    key: const Key('game_move_hint'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: game.selectedSlot == null
                                          ? AppColors.textSecondary
                                          : AppColors.recordText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            DragLayer(
              dragNotifier: game.dragNotifier,
              boardRectNotifier: game.boardRectNotifier,
              gridSize: GameController.gridSize,
              theme: theme,
            ),
            ScorePopupLayer(
              popupNotifier: game.popupNotifier,
              onPopupDone: game.removePopup,
            ),
            Obx(
              () => game.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink(),
            ),
            Obx(() {
              final message = game.errorMessage.value;
              return message == null
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        child: Material(
                          color: AppColors.dialogBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              message,
                              key: const Key('game_storage_error'),
                              style: const TextStyle(
                                color: AppColors.scoreText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
            }),
            Obx(
              () => game.isGameOver.value
                  ? Positioned.fill(
                      child: Stack(
                        children: [
                          const ModalBarrier(
                            dismissible: false,
                            color: AppColors.shadow,
                          ),
                          Center(
                            child: GameOverDialog(
                              score: game.state.score,
                              bestScore: game.state.bestScore,
                              onRestart: () => unawaited(game.resetGame()),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  });
}
