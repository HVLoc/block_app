import 'dart:async';

import 'package:block/core/theme/app_colors.dart';
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

class BlockBlastGamePage extends GetView<GameController> {
  const BlockBlastGamePage({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<GameController>(
    builder: (game) => Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameHeader(
                    bestScore: game.state.bestScore,
                    onReset: () => unawaited(game.resetGame()),
                  ),
                  AnimatedScoreDisplay(scoreNotifier: game.scoreNotifier),
                  Flexible(
                    child: GameBoard(
                      boardKey: game.boardKey,
                      board: game.board,
                      dragNotifier: game.dragNotifier,
                      flashCells: game.flashCells,
                    ),
                  ),
                  DockRow(
                    dock: game.dock,
                    onDragStart: game.startDrag,
                    onDragUpdate: (details) =>
                        unawaited(game.updateDrag(details)),
                    onDragEnd: (details) => unawaited(game.endDrag(details)),
                    onDragCancel: game.cancelDrag,
                  ),
                ],
              ),
            ),
          ),
          DragLayer(
            dragNotifier: game.dragNotifier,
            boardRectNotifier: game.boardRectNotifier,
            gridSize: GameController.gridSize,
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
                            style: const TextStyle(color: AppColors.scoreText),
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
}
