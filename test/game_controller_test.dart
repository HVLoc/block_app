import 'package:block/features/game/domain/usecases/can_place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/load_game_use_case.dart';
import 'package:block/features/game/domain/usecases/place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/save_game_use_case.dart';
import 'package:block/features/game/domain/usecases/start_new_game_use_case.dart';
import 'package:block/features/game/presentation/controllers/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_game_repository.dart';

void main() {
  late FakeGameRepository repository;
  late GameController controller;
  setUp(() {
    repository = FakeGameRepository();
    controller = GameController(
      LoadGameUseCase(repository),
      SaveGameUseCase(repository),
      StartNewGameUseCase(repository),
      PlacePieceUseCase(repository),
      CanPlacePieceUseCase(repository),
    );
  });
  tearDown(() => controller.onClose());
  test('load updates score and finishes loading', () async {
    await controller.loadGame();
    expect(controller.scoreNotifier.value, 40);
    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, isNull);
  });
  test('load failure surfaces a classified error', () async {
    repository.shouldFail = true;
    await controller.loadGame();
    expect(controller.errorMessage.value, 'storage failed');
    expect(controller.isLoading.value, isFalse);
  });
  test('reset preserves best and saves the new state', () async {
    await controller.loadGame();
    await controller.resetGame();
    expect(controller.state.score, 0);
    expect(controller.state.bestScore, 100);
    expect(repository.saves, 1);
    expect(controller.isBusy.value, isFalse);
  });
  test('failed reset leaves current game intact', () async {
    await controller.loadGame();
    repository.shouldFail = true;
    await controller.resetGame();
    expect(controller.state.score, 40);
    expect(controller.errorMessage.value, 'reset failed');
    expect(repository.saves, 0);
    expect(controller.isBusy.value, isFalse);
  });
}
