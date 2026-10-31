import 'package:block/features/game/domain/entities/game_state.dart';

class GameMove {
  const GameMove({
    required this.state,
    required this.placedBoard,
    required this.flashCells,
    required this.points,
    required this.isGameOver,
  });
  final GameState state;
  final List<List<int?>> placedBoard;
  final Set<String> flashCells;
  final int points;
  final bool isGameOver;
}
