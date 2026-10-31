// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameStateModel _$GameStateModelFromJson(Map<String, dynamic> json) =>
    GameStateModel(
      board: (json['board'] as List<dynamic>)
          .map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num?)?.toInt()).toList(),
          )
          .toList(),
      dock: (json['dock'] as List<dynamic>)
          .map(
            (e) => e == null
                ? null
                : PieceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      combo: (json['combo'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GameStateModelToJson(GameStateModel instance) =>
    <String, dynamic>{
      'board': instance.board,
      'dock': instance.dock.map((e) => e?.toJson()).toList(),
      'score': instance.score,
      'combo': instance.combo,
    };
