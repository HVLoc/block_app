import 'package:block/core/theme/block_theme.dart';
import 'package:block/features/appearance/domain/theme_repository.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  ThemeController(this._repository) : theme = _repository.readTheme().obs;
  final ThemeRepository _repository;
  final Rx<BlockTheme> theme;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  Future<void> selectTheme(BlockTheme selected) async {
    if (isSaving.value || selected == theme.value) return;
    isSaving.value = true;
    errorMessage.value = null;
    try {
      if (await _repository.saveTheme(selected)) {
        theme.value = selected;
      } else {
        errorMessage.value = 'Chưa lưu được chủ đề. Bạn hãy thử lại.';
      }
    } on Exception {
      errorMessage.value = 'Chưa lưu được chủ đề. Bạn hãy thử lại.';
    } finally {
      isSaving.value = false;
    }
  }
}
