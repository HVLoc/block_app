import 'package:block/features/game/domain/entities/piece.dart';
import 'package:flutter/material.dart';

class DragInfo {
  const DragInfo({
    required this.slotIndex,
    required this.piece,
    required this.globalPos,
    this.hoverRow,
    this.hoverCol,
  });
  final int slotIndex;
  final Piece piece;
  final Offset globalPos;
  final int? hoverRow;
  final int? hoverCol;
}
