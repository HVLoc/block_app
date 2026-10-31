import 'package:block/features/game/data/models/piece_model.dart';
import 'package:block/features/game/domain/entities/game_history_entry.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_state_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GameStateModel {
  const GameStateModel({
    required this.board,
    required this.dock,
    this.score = 0,
    this.combo = 0,
  });
  GameStateModel.fromEntity(GameState state)
    : board = state.board,
      dock = state.dock
          .map((piece) => piece == null ? null : PieceModel.fromEntity(piece))
          .toList(),
      score = state.score,
      combo = state.combo;
  factory GameStateModel.fromJson(Map<String, dynamic> json) =>
      _$GameStateModelFromJson(json);
  final List<List<int?>> board;
  final List<PieceModel?> dock;
  final int score;
  final int combo;
  Map<String, dynamic> toJson() => _$GameStateModelToJson(this);
  GameState toEntity({
    required int bestScore,
    required List<GameHistoryEntry> history,
  }) => GameState(
    board: board,
    dock: dock.map((p) => p?.toEntity()).toList(),
    score: score,
    combo: combo,
    bestScore: bestScore,
    history: history,
  );
}
