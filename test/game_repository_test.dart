import 'dart:convert';
import 'dart:math';

import 'package:block/core/errors/result.dart';
import 'package:block/features/game/data/datasources/game_local_data_source.dart';
import 'package:block/features/game/data/repositories/game_repository_impl.dart';
import 'package:block/features/game/domain/entities/game_history_entry.dart';
import 'package:block/features/game/domain/entities/game_move.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:block/features/game/domain/entities/piece.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences preferences;
  late GameRepositoryImpl repository;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    repository = GameRepositoryImpl(
      GameLocalDataSource(preferences),
      random: Random(1),
      now: () => DateTime(2026, 10, 31, 15, 30),
    );
  });
  GameState state({List<List<int?>>? board, int combo = 0, int score = 0}) =>
      GameState(
        board: board ?? List.generate(8, (_) => List.filled(8, null)),
        dock: const [
          Piece([
            [1],
          ], 2),
          Piece([
            [1, 1],
          ], 3),
          null,
        ],
        score: score,
        combo: combo,
      );
  test('new game has an empty 8x8 board and three pieces', () async {
    final result = await repository.loadGame() as Success<GameState>;
    expect(result.data.board.length, 8);
    expect(result.data.board.expand((row) => row), everyElement(isNull));
    expect(result.data.dock.whereType<Piece>().length, 3);
  });
  test('crossing row and column clears union and scores both lines', () async {
    final board = List.generate(8, (_) => List<int?>.filled(8, null));
    for (var i = 1; i < 8; i++) {
      board[0][i] = 1;
      board[i][0] = 1;
    }
    final previous = state(board: board, combo: 1, score: 20);
    final result =
        await repository.placePiece(previous, 0, 0, 0) as Success<GameMove>;
    expect(result.data.flashCells.length, 15);
    expect(result.data.points, 81);
    expect(result.data.state.score, 101);
    expect(result.data.state.combo, 2);
    expect(result.data.state.bestScore, 101);
    expect(result.data.state.board.expand((row) => row), everyElement(isNull));
    expect(previous.board[0][0], isNull);
    expect(result.data.placedBoard[0][0], 2);
  });
  test('placing without clearing resets combo', () async {
    final result =
        await repository.placePiece(state(combo: 3), 0, 2, 2)
            as Success<GameMove>;
    expect(result.data.state.combo, 0);
    expect(result.data.points, 1);
    expect(result.data.state.dock[0], isNull);
  });
  test(
    'invalid and overlapping moves return failures without mutating state',
    () async {
      final original = state();
      expect(
        await repository.placePiece(original, 0, -1, 0),
        isA<Failure<GameMove>>(),
      );
      expect(
        await repository.placePiece(original, 5, 0, 0),
        isA<Failure<GameMove>>(),
      );
      final result =
          await repository.placePiece(original, 0, 0, 0) as Success<GameMove>;
      expect(
        await repository.placePiece(result.data.state, 1, 0, 0),
        isA<Failure<GameMove>>(),
      );
      expect(
        (await repository.canPlacePiece(
                  original,
                  const Piece([
                    [1, 1],
                  ], 0),
                  0,
                  7,
                )
                as Success<bool>)
            .data,
        isFalse,
      );
      expect(original.board[0][0], isNull);
    },
  );
  test('empty dock refills and game over records history once', () async {
    final result =
        await repository.placePiece(
              GameState(
                board: state().board,
                dock: const [
                  Piece([
                    [1],
                  ], 0),
                  null,
                  null,
                ],
              ),
              0,
              0,
              0,
            )
            as Success<GameMove>;
    expect(result.data.state.dock.whereType<Piece>().length, 3);
    final board = List.generate(
      8,
      (r) => List<int?>.generate(8, (c) => (r + c).isEven ? 0 : null),
    );
    final blocked = GameState(
      board: board,
      dock: const [
        Piece([
          [1],
        ], 0),
        Piece([
          [1, 1],
        ], 1),
        null,
      ],
    );
    final over =
        await repository.placePiece(blocked, 0, 0, 1) as Success<GameMove>;
    expect(over.data.isGameOver, isTrue);
    expect(over.data.state.history.length, 1);
    final restart =
        await repository.startNewGame(over.data.state) as Success<GameState>;
    expect(restart.data.history.length, 1);
  });
  test('legacy storage keys and payload restore unchanged', () async {
    final original = state(score: 42, combo: 2);
    final withHistory = GameState(
      board: original.board,
      dock: original.dock,
      score: original.score,
      combo: original.combo,
      bestScore: 100,
      history: const [GameHistoryEntry(score: 15, time: '2026-10-30 12:00')],
    );
    expect(await repository.saveGame(withHistory), isA<Success<void>>());
    final payload =
        jsonDecode(preferences.getString('bb_active')!) as Map<String, dynamic>;
    expect(payload.keys, unorderedEquals(['score', 'combo', 'board', 'dock']));
    expect((payload['dock'] as List<dynamic>).first, {
      'm': [
        [1],
      ],
      'c': 2,
    });
    final restored = (await repository.loadGame() as Success<GameState>).data;
    expect(restored.score, 42);
    expect(restored.combo, 2);
    expect(restored.bestScore, 100);
    expect(restored.dock[0]?.matrix, [
      [1],
    ]);
    expect(restored.history.single.score, 15);
  });
  test('corrupt history and board recover without losing best score', () async {
    await preferences.setInt('bb_best', 99);
    await preferences.setString('bb_history', 'not json');
    await preferences.setString('bb_active', '{"board": [], "dock": []}');
    final result = await repository.loadGame() as Success<GameState>;
    expect(result.data.bestScore, 99);
    expect(result.data.board.length, 8);
    expect(result.data.score, 0);
    expect(result.data.history, isEmpty);
  });
  test('reset preserves best and limits history to 25 entries', () async {
    final previous = state(score: 60);
    final result =
        await repository.startNewGame(
              GameState(
                board: previous.board,
                dock: previous.dock,
                score: 60,
                bestScore: 100,
                history: List.generate(
                  25,
                  (i) => GameHistoryEntry(score: i, time: 'old'),
                ),
              ),
            )
            as Success<GameState>;
    expect(result.data.history.length, 25);
    expect(result.data.history.first.score, 60);
    expect(result.data.score, 0);
    expect(result.data.bestScore, 100);
  });
}
