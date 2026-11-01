import 'package:block/core/theme/app_colors.dart';
import 'package:block/features/web_game/presentation/controllers/web_game_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebGamePage extends GetView<WebGameController> {
  const WebGamePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.webBackground,
    body: SafeArea(
      child: Obx(() {
        final message = controller.errorMessage.value;
        return message == null
            ? WebViewWidget(controller: controller.webView)
            : Center(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.scoreText),
                ),
              );
      }),
    ),
  );
}
