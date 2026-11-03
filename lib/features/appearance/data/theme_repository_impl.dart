import 'package:block/core/theme/block_theme.dart';
import 'package:block/features/appearance/domain/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._preferences);
  final SharedPreferences _preferences;
  static const preferenceKey = 'blocks_theme';

  @override
  BlockTheme readTheme() {
    final stored = _preferences.get(preferenceKey);
    return BlockTheme.fromName(stored is String ? stored : null);
  }

  @override
  Future<bool> saveTheme(BlockTheme theme) =>
      _preferences.setString(preferenceKey, theme.name);
}
