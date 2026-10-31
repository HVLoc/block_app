import 'package:block/features/web_game/presentation/controllers/web_game_controller.dart';
import 'package:get/get.dart';

class WebGameBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(WebGameController.new);
}
