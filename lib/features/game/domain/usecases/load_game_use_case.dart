import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';

class LoadGameUseCase {
  const LoadGameUseCase(this._repository);
  final GameRepository _repository;

  /// Restores the saved session; storage errors are returned as Failure.
  Future<Result<GameState>> execute() => _repository.loadGame();
}
