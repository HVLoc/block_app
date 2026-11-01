import 'package:block/features/game/domain/entities/piece.dart';
import 'package:json_annotation/json_annotation.dart';

part 'piece_model.g.dart';

@JsonSerializable()
class PieceModel {
  const PieceModel({required this.matrix, required this.colorIndex});
  PieceModel.fromEntity(Piece piece)
    : matrix = piece.matrix,
      colorIndex = piece.colorIndex;
  factory PieceModel.fromJson(Map<String, dynamic> json) =>
      _$PieceModelFromJson(json);
  @JsonKey(name: 'm')
  final List<List<int>> matrix;
  @JsonKey(name: 'c')
  final int colorIndex;
  Map<String, dynamic> toJson() => _$PieceModelToJson(this);
  Piece toEntity() => Piece(matrix, colorIndex);
}
