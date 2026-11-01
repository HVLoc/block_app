import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';

class PlacePieceUseCase {
  const PlacePieceUseCase(this._repository);
  final GameRepository _repository;

  /// Places the dock slot at zero-based row/col; invalid moves return Failure.
  Future<Result<GameMove>> execute(
    GameState state,
    int slot,
    int row,
    int col,
  ) => _repository.placePiece(state, slot, row, col);
}
