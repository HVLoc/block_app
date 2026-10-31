import 'dart:async';

import 'package:block/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebGameController extends GetxController {
  late final WebViewController webView;
  final errorMessage = RxnString();
  @override
  void onInit() {
    super.onInit();
    webView = WebViewController();
    unawaited(_loadGame());
  }

  Future<void> _loadGame() async {
    try {
      await webView.setJavaScriptMode(JavaScriptMode.unrestricted);
      await webView.setBackgroundColor(AppColors.webBackground);
      await webView.loadFlutterAsset('assets/block.html');
    } on Object {
      if (!isClosed) errorMessage.value = 'Không thể tải trò chơi.';
    }
  }
}
