// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PieceModel _$PieceModelFromJson(Map<String, dynamic> json) => PieceModel(
  matrix: (json['m'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  colorIndex: (json['c'] as num).toInt(),
);

Map<String, dynamic> _$PieceModelToJson(PieceModel instance) =>
    <String, dynamic>{'m': instance.matrix, 'c': instance.colorIndex};
