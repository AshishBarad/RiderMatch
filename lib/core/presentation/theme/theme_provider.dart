import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _boxName = 'settings';
  static const String _themeKey = 'themeMode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_boxName);
    final themeIndex = box.get(_themeKey, defaultValue: 0);
    state = ThemeMode.values[themeIndex];
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, state.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, state.index);
  }
}
