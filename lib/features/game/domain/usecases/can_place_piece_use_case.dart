import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';

class CanPlacePieceUseCase {
  const CanPlacePieceUseCase(this._repository);
  final GameRepository _repository;

  /// Checks overlap and bounds at zero-based row/col, returning `Result<bool>`.
  Future<Result<bool>> execute(
    GameState state,
    Piece piece,
    int row,
    int col,
  ) => _repository.canPlacePiece(state, piece, row, col);
}
