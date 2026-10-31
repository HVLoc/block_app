import 'package:block/routes/app_pages.dart';
import 'package:block/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockBlastLiteApp extends StatelessWidget {
  const BlockBlastLiteApp({
    required this.preferences,
    this.initialRoute = Routes.game,
    super.key,
  });
  final SharedPreferences preferences;
  final String initialRoute;
  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Block Blast Lite',
    initialRoute: initialRoute,
    getPages: AppPages.pages(preferences),
  );
}
