import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeModeProvider = StateNotifierProvider<ThemeModeStore, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeStore(prefs);
});

class ThemeModeStore extends StateNotifier<ThemeMode> {
  ThemeModeStore(this.prefs) : super(_load(prefs));

  final SharedPreferences prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    final raw = prefs.getString('theme_mode') ?? 'system';
    if (raw == 'light') return ThemeMode.light;
    if (raw == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final raw = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
    await prefs.setString('theme_mode', raw);
  }
}
