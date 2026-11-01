import 'package:block/core/errors/result.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:block/features/game/domain/usecases/can_place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/load_game_use_case.dart';
import 'package:block/features/game/domain/usecases/place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/save_game_use_case.dart';
import 'package:block/features/game/domain/usecases/start_new_game_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_game_repository.dart';

void main() {
  for (final shouldFail in [false, true]) {
    test(
      'use cases preserve ${shouldFail ? "failure" : "success"} results',
      () async {
        final repository = FakeGameRepository()..shouldFail = shouldFail;
        final state = repository.state;
        final load = await LoadGameUseCase(repository).execute();
        final save = await SaveGameUseCase(repository).execute(state);
        final reset = await StartNewGameUseCase(repository).execute(state);
        final place = await PlacePieceUseCase(
          repository,
        ).execute(state, 0, 0, 0);
        final canPlace = await CanPlacePieceUseCase(repository).execute(
          state,
          const Piece([
            [1],
          ], 0),
          0,
          0,
        );
        expect(
          load,
          shouldFail ? isA<Failure<GameState>>() : isA<Success<GameState>>(),
        );
        expect(save, shouldFail ? isA<Failure<void>>() : isA<Success<void>>());
        expect(
          reset,
          shouldFail ? isA<Failure<GameState>>() : isA<Success<GameState>>(),
        );
        expect(
          place,
          shouldFail ? isA<Failure<GameMove>>() : isA<Success<GameMove>>(),
        );
        expect(
          canPlace,
          shouldFail ? isA<Failure<bool>>() : isA<Success<bool>>(),
        );
      },
    );
  }
}
