import 'package:block/features/game/presentation/bindings/game_binding.dart';
import 'package:block/features/game/presentation/pages/block_blast_game_page.dart';
import 'package:block/features/web_game/presentation/bindings/web_game_binding.dart';
import 'package:block/features/web_game/presentation/pages/web_game_page.dart';
import 'package:block/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppPages {
  static List<GetPage<dynamic>> pages(SharedPreferences preferences) => [
    GetPage(
      name: Routes.game,
      page: () => const BlockBlastGamePage(),
      binding: GameBinding(preferences),
    ),
    GetPage(
      name: Routes.webGame,
      page: () => const WebGamePage(),
      binding: WebGameBinding(),
    ),
  ];
}
