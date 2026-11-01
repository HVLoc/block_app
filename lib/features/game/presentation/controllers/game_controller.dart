import 'dart:async';

import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_constants.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:block/features/game/domain/usecases/can_place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/load_game_use_case.dart';
import 'package:block/features/game/domain/usecases/place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/save_game_use_case.dart';
import 'package:block/features/game/domain/usecases/start_new_game_use_case.dart';
import 'package:block/features/game/presentation/models/drag_info.dart';
import 'package:block/features/game/presentation/models/score_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
  GameController(
    this._loadGame,
    this._saveGame,
    this._startNewGame,
    this._placePiece,
    this._canPlacePiece,
  );
  final LoadGameUseCase _loadGame;
  final SaveGameUseCase _saveGame;
  final StartNewGameUseCase _startNewGame;
  final PlacePieceUseCase _placePiece;
  final CanPlacePieceUseCase _canPlacePiece;
  static const gridSize = GameConstants.gridSize;
  final boardKey = GlobalKey();
  final dragNotifier = ValueNotifier<DragInfo?>(null);
  final popupNotifier = ValueNotifier<List<ScorePopup>>([]);
  final scoreNotifier = ValueNotifier<int>(0);
  final boardRectNotifier = ValueNotifier<Rect?>(null);
  final isLoading = true.obs;
  final isBusy = false.obs;
  final isGameOver = false.obs;
  final errorMessage = RxnString();
  GameState state = GameState(
    board: List.generate(gridSize, (_) => List.filled(gridSize, null)),
    dock: const [null, null, null],
  );
  List<List<int?>>? _previewBoard;
  Set<String> flashCells = {};
  int _nextPopupId = 0;
  int _dragRevision = 0;
  Future<void> _pendingSave = Future.value();
  Future<void> _pendingDragUpdate = Future.value();
  List<List<int?>> get board => _previewBoard ?? state.board;
  List<Piece?> get dock {
    final items = [...state.dock];
    final drag = dragNotifier.value;
    if (drag != null) items[drag.slotIndex] = null;
    return items;
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(loadGame());
  }

  Future<void> loadGame() async {
    isLoading.value = true;
    switch (await _loadGame.execute()) {
      case Success(:final data):
        if (isClosed) return;
        state = data;
        scoreNotifier.value = data.score;
        errorMessage.value = null;
      case Failure(:final exception):
        if (isClosed) return;
        errorMessage.value = exception.message;
    }
    isLoading.value = false;
    update();
  }

  Future<void> _persist() {
    final snapshot = state;
    return _pendingSave = _pendingSave.then((_) async {
      final result = await _saveGame.execute(snapshot);
      if (isClosed) return;
      switch (result) {
        case Success():
          break;
        case Failure(:final exception):
          errorMessage.value = exception.message;
      }
    });
  }

  Future<void> resetGame() async {
    if (isBusy.value || isLoading.value) return;
    isBusy.value = true;
    cancelDrag();
    switch (await _startNewGame.execute(state)) {
      case Success(:final data):
        if (isClosed) return;
        state = data;
        scoreNotifier.value = 0;
        flashCells = {};
        popupNotifier.value = [];
        isGameOver.value = false;
        errorMessage.value = null;
        update();
        await _persist();
      case Failure(:final exception):
        if (isClosed) return;
        errorMessage.value = exception.message;
    }
    if (!isClosed) isBusy.value = false;
  }

  void startDrag(int slot, DragStartDetails details) {
    if (isBusy.value ||
        isLoading.value ||
        isGameOver.value ||
        dragNotifier.value != null) {
      return;
    }
    final piece = state.dock[slot];
    if (piece == null) return;
    final box = boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    boardRectNotifier.value = box.localToGlobal(Offset.zero) & box.size;
    _dragRevision++;
    dragNotifier.value = DragInfo(
      slotIndex: slot,
      piece: piece,
      globalPos: details.globalPosition,
    );
    update();
  }

  Future<void> updateDrag(DragUpdateDetails details) =>
      _pendingDragUpdate = _updateDrag(details);

  Future<void> _updateDrag(DragUpdateDetails details) async {
    final current = dragNotifier.value;
    final rect = boardRectNotifier.value;
    if (current == null || rect == null) return;
    final revision = ++_dragRevision;
    final cellSize = rect.width / gridSize;
    final col =
        ((details.globalPosition.dx -
                    current.piece.cols * cellSize / 2 +
                    cellSize / 2 -
                    rect.left) /
                cellSize)
            .floor();
    final row =
        ((details.globalPosition.dy -
                    current.piece.rows * cellSize / 2 -
                    80 +
                    cellSize / 2 -
                    rect.top) /
                cellSize)
            .floor();
    final result = await _canPlacePiece.execute(state, current.piece, row, col);
    if (isClosed || revision != _dragRevision) return;
    final isValid = switch (result) {
      Success(:final data) => data,
      Failure() => false,
    };
    dragNotifier.value = DragInfo(
      slotIndex: current.slotIndex,
      piece: current.piece,
      globalPos: details.globalPosition,
      hoverRow: isValid ? row : null,
      hoverCol: isValid ? col : null,
    );
  }

  void cancelDrag() {
    _dragRevision++;
    dragNotifier.value = null;
    update();
  }

  Future<void> endDrag(DragEndDetails details) async {
    await _pendingDragUpdate;
    if (isClosed) return;
    final drag = dragNotifier.value;
    cancelDrag();
    if (drag == null) return;
    final row = drag.hoverRow;
    final col = drag.hoverCol;
    if (row == null || col == null || isBusy.value) return;
    isBusy.value = true;
    switch (await _placePiece.execute(state, drag.slotIndex, row, col)) {
      case Success(:final data):
        if (isClosed) return;
        await _animateMove(data, drag.piece, row, col);
      case Failure(:final exception):
        if (isClosed) return;
        errorMessage.value = exception.message;
    }
    if (!isClosed) isBusy.value = false;
  }

  Future<void> _animateMove(
    GameMove move,
    Piece piece,
    int row,
    int col,
  ) async {
    _previewBoard = move.placedBoard;
    flashCells = move.flashCells;
    update();
    if (flashCells.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    if (isClosed) return;
    state = move.state;
    _previewBoard = null;
    flashCells = {};
    scoreNotifier.value = state.score;
    final rect = boardRectNotifier.value;
    if (rect != null) {
      final cellSize = rect.width / gridSize;
      popupNotifier.value = [
        ...popupNotifier.value,
        ScorePopup(
          points: move.points,
          position: Offset(
            rect.left + (col + piece.cols / 2) * cellSize,
            rect.top + (row + piece.rows / 2) * cellSize,
          ),
          id: _nextPopupId++,
        ),
      ];
    }
    update();
    await _persist();
    if (!isClosed) isGameOver.value = move.isGameOver;
  }

  void removePopup(int id) {
    if (!isClosed) {
      popupNotifier.value = popupNotifier.value
          .where((p) => p.id != id)
          .toList();
    }
  }

  @override
  void onClose() {
    _dragRevision++;
    dragNotifier.dispose();
    popupNotifier.dispose();
    scoreNotifier.dispose();
    boardRectNotifier.dispose();
    super.onClose();
  }
}
