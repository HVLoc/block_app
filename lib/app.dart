import 'package:block/core/theme/app_theme.dart';
import 'package:block/routes/app_pages.dart';
import 'package:block/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlocksApp extends StatelessWidget {
  const BlocksApp({
    required this.preferences,
    this.initialRoute = Routes.game,
    super.key,
  });
  final SharedPreferences preferences;
  final String initialRoute;
  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Blocks',
    theme: AppTheme.dark,
    builder: (_, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: child ?? const SizedBox.shrink(),
    ),
    initialRoute: initialRoute,
    getPages: AppPages.pages(preferences),
  );
}
