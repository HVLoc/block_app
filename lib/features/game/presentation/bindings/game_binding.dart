import 'package:block/features/game/data/datasources/game_local_data_source.dart';
import 'package:block/features/game/data/repositories/game_repository_impl.dart';
import 'package:block/features/game/domain/repositories/game_repository.dart';
import 'package:block/features/game/domain/usecases/can_place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/load_game_use_case.dart';
import 'package:block/features/game/domain/usecases/place_piece_use_case.dart';
import 'package:block/features/game/domain/usecases/save_game_use_case.dart';
import 'package:block/features/game/domain/usecases/start_new_game_use_case.dart';
import 'package:block/features/game/presentation/controllers/game_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameBinding extends Bindings {
  GameBinding(this._preferences);
  final SharedPreferences _preferences;
  @override
  void dependencies() {
    Get
      ..lazyPut(() => GameLocalDataSource(_preferences))
      ..lazyPut<GameRepository>(
        () => GameRepositoryImpl(Get.find<GameLocalDataSource>()),
      )
      ..lazyPut(() => LoadGameUseCase(Get.find<GameRepository>()))
      ..lazyPut(() => SaveGameUseCase(Get.find<GameRepository>()))
      ..lazyPut(() => StartNewGameUseCase(Get.find<GameRepository>()))
      ..lazyPut(() => PlacePieceUseCase(Get.find<GameRepository>()))
      ..lazyPut(() => CanPlacePieceUseCase(Get.find<GameRepository>()))
      ..lazyPut(
        () => GameController(
          Get.find<LoadGameUseCase>(),
          Get.find<SaveGameUseCase>(),
          Get.find<StartNewGameUseCase>(),
          Get.find<PlacePieceUseCase>(),
          Get.find<CanPlacePieceUseCase>(),
        ),
      );
  }
}
