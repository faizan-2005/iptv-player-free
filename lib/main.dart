import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/theme/theme_mode_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Hive.initFlutter();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IptvApp(),
    ),
  );
}
