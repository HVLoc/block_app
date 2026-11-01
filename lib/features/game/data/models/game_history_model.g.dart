// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameHistoryModel _$GameHistoryModelFromJson(Map<String, dynamic> json) =>
    GameHistoryModel(
      score: (json['score'] as num).toInt(),
      time: json['time'] as String,
    );

Map<String, dynamic> _$GameHistoryModelToJson(GameHistoryModel instance) =>
    <String, dynamic>{'score': instance.score, 'time': instance.time};
