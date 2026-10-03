import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
  static Box get sources => Hive.box('sources');
  static Box get favorites => Hive.box('favorites');
  static Box get watchHistory => Hive.box('history');

  static Future<void> ensureOpen() async {
    for (final name in ['sources', 'favorites', 'history']) {
      if (!Hive.isBoxOpen(name)) {
        await Hive.openBox(name);
      }
    }
  }
}
