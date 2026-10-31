import 'package:block/core/errors/app_exception.dart';
import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';

class FakeGameRepository implements GameRepository {
  bool shouldFail = false;
  int saves = 0;
  GameState state = GameState(
    board: List.generate(8, (_) => List.filled(8, null)),
    dock: const [
      Piece([
        [1],
      ], 0),
      null,
      null,
    ],
    score: 40,
    bestScore: 100,
  );
  @override
  Future<Result<GameState>> loadGame() async => shouldFail
      ? const Failure(CacheException('storage failed'))
      : Success(state);
  @override
  Future<Result<void>> saveGame(GameState state) async {
    saves++;
    return shouldFail
        ? const Failure(CacheException('save failed'))
        : const Success(null);
  }

  @override
  Future<Result<GameState>> startNewGame(GameState previous) async => shouldFail
      ? const Failure(CacheException('reset failed'))
      : Success(
          GameState(
            board: state.board,
            dock: state.dock,
            bestScore: previous.bestScore,
          ),
        );
  @override
  Future<Result<bool>> canPlacePiece(
    GameState state,
    Piece piece,
    int row,
    int col,
  ) async => shouldFail
      ? const Failure(InvalidMoveException('invalid'))
      : const Success(true);
  @override
  Future<Result<GameMove>> placePiece(
    GameState state,
    int slot,
    int row,
    int col,
  ) async => shouldFail
      ? const Failure(InvalidMoveException('invalid'))
      : Success(
          GameMove(
            state: state,
            placedBoard: state.board,
            flashCells: {},
            points: 1,
            isGameOver: false,
          ),
        );
}
