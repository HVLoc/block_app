import 'dart:math';

import 'package:block/core/errors/app_exception.dart';
import 'package:block/core/errors/result.dart';
import 'package:block/features/game/data/datasources/game_local_data_source.dart';
import 'package:block/features/game/domain/entities/game_history_entry.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';
import 'package:block/features/game/domain/services/game_rules.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._storage, {Random? random, DateTime Function()? now})
    : _rules = GameRules(random: random, now: now);
  final GameLocalDataSource _storage;
  final GameRules _rules;
  @override
  Future<Result<GameState>> loadGame() async {
    try {
      final best = _storage.readBestScore();
      // Corrupt history must not prevent restoring a valid board.
      var history = <GameHistoryEntry>[];
      try {
        history = _storage
            .readHistory()
            .map((entry) => entry.toEntity())
            .take(25)
            .toList();
      } on Object {
        history = [];
      }
      final empty = GameState(
        board: const [],
        dock: const [],
        bestScore: best,
        history: history,
      );
      GameState? state;
      try {
        state = _storage.readActiveGame()?.toEntity(
          bestScore: best,
          history: history,
        );
      } on Object {
        state = null;
      }
      if (state == null || !_rules.isValid(state)) {
        return Success(_rules.startNewGame(empty));
      }
      if (state.dock.every((piece) => piece == null)) {
        state = GameState(
          board: state.board,
          dock: _rules.spawnDock(),
          score: state.score,
          combo: state.combo,
          bestScore: state.bestScore,
          history: state.history,
        );
      }
      return Success(state);
    } on Object {
      return const Failure(CacheException('Không thể đọc dữ liệu trò chơi.'));
    }
  }

  @override
  Future<Result<void>> saveGame(GameState state) async {
    try {
      await _storage.saveGame(state);
      return const Success(null);
    } on Object {
      return const Failure(CacheException('Không thể lưu dữ liệu trò chơi.'));
    }
  }

  @override
  Future<Result<GameState>> startNewGame(GameState previous) async {
    try {
      return Success(_rules.startNewGame(previous, recordHistory: true));
    } on Object {
      return const Failure(UnknownException('Không thể bắt đầu trò chơi.'));
    }
  }

  @override
  Future<Result<bool>> canPlacePiece(
    GameState state,
    Piece piece,
    int row,
    int col,
  ) async {
    try {
      return Success(_rules.canPlace(state, piece, row, col));
    } on Object {
      return const Failure(InvalidMoveException('Khối không hợp lệ.'));
    }
  }

  @override
  Future<Result<GameMove>> placePiece(
    GameState state,
    int slot,
    int row,
    int col,
  ) async => _rules.placePiece(state, slot, row, col);
}
