import 'package:flutter/material.dart';

class ScorePopup {
  const ScorePopup({
    required this.points,
    required this.position,
    required this.id,
  });
  final int points;
  final Offset position; // screen (global) coords
  final int id;
}
