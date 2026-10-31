import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';

class SaveGameUseCase {
  const SaveGameUseCase(this._repository);
  final GameRepository _repository;

  /// Persists this snapshot; storage errors are returned as Failure.
  Future<Result<void>> execute(GameState state) => _repository.saveGame(state);
}
