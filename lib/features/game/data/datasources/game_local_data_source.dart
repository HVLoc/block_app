import 'dart:convert';

import 'package:block/features/game/data/models/game_history_model.dart';
import 'package:block/features/game/data/models/game_state_model.dart';
import 'package:block/features/game/domain/entities/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLocalDataSource {
  const GameLocalDataSource(this._preferences);
  final SharedPreferences _preferences;
  int readBestScore() => _preferences.getInt('bb_best') ?? 0;
  List<GameHistoryModel> readHistory() {
    final raw = _preferences.getString('bb_history');
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((item) => GameHistoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  GameStateModel? readActiveGame() {
    final raw = _preferences.getString('bb_active');
    return raw == null
        ? null
        : GameStateModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveGame(GameState state) async {
    final results = [
      await _preferences.setInt('bb_best', state.bestScore),
      await _preferences.setString(
        'bb_active',
        jsonEncode(GameStateModel.fromEntity(state).toJson()),
      ),
      await _preferences.setString(
        'bb_history',
        jsonEncode(
          state.history
              .map(
                (entry) => GameHistoryModel(
                  score: entry.score,
                  time: entry.time,
                ).toJson(),
              )
              .toList(),
        ),
      ),
    ];
    if (results.contains(false)) throw StateError('Could not save game');
  }
}
