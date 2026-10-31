import 'package:block/features/game/domain/entities/game_history_entry.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_history_model.g.dart';

@JsonSerializable()
class GameHistoryModel {
  const GameHistoryModel({required this.score, required this.time});
  factory GameHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$GameHistoryModelFromJson(json);
  final int score;
  final String time;
  Map<String, dynamic> toJson() => _$GameHistoryModelToJson(this);
  GameHistoryEntry toEntity() => GameHistoryEntry(score: score, time: time);
}
