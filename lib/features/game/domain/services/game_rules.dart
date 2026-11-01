import 'dart:math';

import 'package:block/core/errors/app_exception.dart';
import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_constants.dart';
import 'package:block/features/game/domain/entities/game_history_entry.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';

/// Pure Dart rules shared by repository actions; no persistence or UI state.
class GameRules {
  GameRules({Random? random, DateTime Function()? now})
    : _random = random ?? Random(),
      _now = now ?? DateTime.now;
  final Random _random;
  final DateTime Function() _now;
  static const _size = GameConstants.gridSize;
  List<Piece?> spawnDock() => List.generate(
    3,
    (_) => Piece(
      GameConstants.shapesPool[_random.nextInt(
        GameConstants.shapesPool.length,
      )],
      _random.nextInt(GameConstants.paletteSize),
    ),
  );

  GameState startNewGame(GameState previous, {bool recordHistory = false}) {
    final history = [...previous.history];
    if (recordHistory && previous.score > 0 && !_isGameOver(previous)) {
      history.insert(
        0,
        GameHistoryEntry(
          score: previous.score,
          time: _now().toString().substring(0, 16),
        ),
      );
    }
    return GameState(
      board: List.generate(_size, (_) => List.filled(_size, null)),
      dock: spawnDock(),
      bestScore: previous.bestScore,
      history: history.take(25).toList(),
    );
  }

  bool canPlace(GameState state, Piece piece, int row, int col) {
    for (var r = 0; r < piece.rows; r++) {
      for (var c = 0; c < piece.cols; c++) {
        if (piece.matrix[r][c] != 1) continue;
        final targetRow = row + r;
        final targetCol = col + c;
        if (targetRow < 0 ||
            targetRow >= _size ||
            targetCol < 0 ||
            targetCol >= _size ||
            state.board[targetRow][targetCol] != null) {
          return false;
        }
      }
    }
    return true;
  }

  bool _isGameOver(GameState state) {
    for (final piece in state.dock) {
      if (piece == null) continue;
      for (var row = 0; row <= _size - piece.rows; row++) {
        for (var col = 0; col <= _size - piece.cols; col++) {
          if (canPlace(state, piece, row, col)) return false;
        }
      }
    }
    return true;
  }

  bool isValid(GameState state) =>
      state.board.length == _size &&
      state.board.every(
        (row) =>
            row.length == _size &&
            row.every(
              (cell) =>
                  cell == null ||
                  (cell >= 0 && cell < GameConstants.paletteSize),
            ),
      ) &&
      state.dock.length == 3 &&
      state.score >= 0 &&
      state.combo >= 0 &&
      state.dock.every(
        (piece) =>
            piece == null ||
            (piece.colorIndex >= 0 &&
                piece.colorIndex < GameConstants.paletteSize &&
                piece.matrix.isNotEmpty &&
                piece.matrix.first.isNotEmpty &&
                piece.matrix.every(
                  (row) =>
                      row.length == piece.cols &&
                      row.every((cell) => cell == 0 || cell == 1),
                ) &&
                piece.matrix.any((row) => row.contains(1))),
      );

  Result<GameMove> placePiece(GameState state, int slot, int row, int col) {
    try {
      if (slot < 0 || slot >= state.dock.length) {
        return const Failure(InvalidMoveException('Ô chứa khối không hợp lệ.'));
      }
      final piece = state.dock[slot];
      if (piece == null || !canPlace(state, piece, row, col)) {
        return const Failure(
          InvalidMoveException('Không thể đặt khối tại vị trí này.'),
        );
      }
      final board = state.board.map((row) => row.toList()).toList();
      var placed = 0;
      for (var r = 0; r < piece.rows; r++) {
        for (var c = 0; c < piece.cols; c++) {
          if (piece.matrix[r][c] == 1) {
            board[row + r][col + c] = piece.colorIndex;
            placed++;
          }
        }
      }
      final placedBoard = board.map((row) => row.toList()).toList();
      final fullRows = <int>[];
      final fullCols = <int>[];
      for (var index = 0; index < _size; index++) {
        if (board[index].every((cell) => cell != null)) fullRows.add(index);
        if (board.every((row) => row[index] != null)) fullCols.add(index);
      }
      final flash = <String>{};
      for (final r in fullRows) {
        for (var c = 0; c < _size; c++) {
          flash.add('$r,$c');
          board[r][c] = null;
        }
      }
      for (final c in fullCols) {
        for (var r = 0; r < _size; r++) {
          flash.add('$r,$c');
          board[r][c] = null;
        }
      }
      final lines = fullRows.length + fullCols.length;
      final combo = lines > 0 ? state.combo + 1 : 0;
      final points = placed + lines * 10 * lines * combo;
      final score = state.score + points;
      var dock = [...state.dock]..[slot] = null;
      if (dock.every((piece) => piece == null)) dock = spawnDock();
      var next = GameState(
        board: board,
        dock: dock,
        score: score,
        combo: combo,
        bestScore: max(score, state.bestScore),
        history: state.history,
      );
      final isGameOver = _isGameOver(next);
      if (isGameOver && score > 0) {
        next = GameState(
          board: board,
          dock: dock,
          score: score,
          combo: combo,
          bestScore: next.bestScore,
          history: [
            GameHistoryEntry(
              score: score,
              time: _now().toString().substring(0, 16),
            ),
            ...state.history,
          ].take(25).toList(),
        );
      }
      return Success(
        GameMove(
          state: next,
          placedBoard: placedBoard,
          flashCells: flash,
          points: points,
          isGameOver: isGameOver,
        ),
      );
    } on Object {
      return const Failure(UnknownException('Không thể xử lý nước đi.'));
    }
  }
}
