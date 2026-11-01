import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';

/// Provides game rules and persistence without exposing storage plugins.
abstract interface class GameRepository {
  /// Restores a valid saved session or starts a fresh board.
  Future<Result<GameState>> loadGame();

  /// Saves the active board, best score and history with existing storage keys.
  Future<Result<void>> saveGame(GameState state);

  /// Starts a new board and records the previous nonzero score.
  Future<Result<GameState>> startNewGame(GameState previous);

  /// Resolves a move, clearing intersecting cells once and scoring combos.
  Future<Result<GameMove>> placePiece(
    GameState state,
    int slot,
    int row,
    int col,
  );

  /// Reports whether a piece fits within the board without overlap.
  Future<Result<bool>> canPlacePiece(
    GameState state,
    Piece piece,
    int row,
    int col,
  );
}
