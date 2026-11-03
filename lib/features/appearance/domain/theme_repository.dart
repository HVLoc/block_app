import 'package:block/core/theme/block_theme.dart';

abstract interface class ThemeRepository {
  BlockTheme readTheme();
  Future<bool> saveTheme(BlockTheme theme);
}
