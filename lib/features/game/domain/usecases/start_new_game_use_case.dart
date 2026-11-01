import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';

class StartNewGameUseCase {
  const StartNewGameUseCase(this._repository);
  final GameRepository _repository;

  /// Resets the board and records the previous score, preserving best/history.
  Future<Result<GameState>> execute(GameState previous) =>
      _repository.startNewGame(previous);
}
