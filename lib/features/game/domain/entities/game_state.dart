import 'package:block/features/game/domain/entities/game_history_entry.dart';
import 'package:block/features/game/domain/entities/piece.dart';

class GameState {
  GameState({
    required List<List<int?>> board,
    required List<Piece?> dock,
    this.score = 0,
    this.combo = 0,
    this.bestScore = 0,
    List<GameHistoryEntry> history = const [],
  }) : board = List.unmodifiable(board.map(List<int?>.unmodifiable)),
       dock = List.unmodifiable(dock),
       history = List.unmodifiable(history);
  final List<List<int?>> board;
  final List<Piece?> dock;
  final int score;
  final int combo;
  final int bestScore;
  final List<GameHistoryEntry> history;
}
