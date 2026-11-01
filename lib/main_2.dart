import 'package:block/app.dart';
import 'package:block/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Alternative entry point that keeps the original WebView game available.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final preferences = await SharedPreferences.getInstance();
  runApp(
    BlockBlastLiteApp(preferences: preferences, initialRoute: Routes.webGame),
  );
}
