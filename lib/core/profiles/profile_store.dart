import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../theme/theme_mode_store.dart';

final profileProvider = StateNotifierProvider<ProfileStore, List<Profile>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileStore(prefs);
});

class ProfileStore extends StateNotifier<List<Profile>> {
  ProfileStore(this.prefs) : super([]) {
    load();
  }

  final SharedPreferences prefs;

  Future<void> load() async {
    if (!Hive.isBoxOpen('profiles')) await Hive.openBox('profiles');
    final box = Hive.box('profiles');
    if (box.isEmpty) {
      final main = Profile(id: 'main', name: 'Main');
      await box.put(main.id, main.toMap());
    }
    state = box.values.map((e) => Profile.fromMap(Map.from(e))).toList();
  }

  Future<Profile> add(String name, {String pin = '', bool isKids = false}) async {
    final profile = Profile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Profile ${state.length + 1}' : name.trim(),
      pinHash: pin.isEmpty ? '' : hashPin(pin),
      isKids: isKids,
    );
    await Hive.box('profiles').put(profile.id, profile.toMap());
    state = [...state, profile];
    return profile;
  }

  Future<void> remove(String id) async {
    if (state.length <= 1) return;
    await Hive.box('profiles').delete(id);
    state = state.where((p) => p.id != id).toList();
  }

  bool verify(Profile profile, String pin) {
    if (!profile.locked) return true;
    return profile.pinHash == hashPin(pin);
  }

  static String hashPin(String pin) {
    return sha256.convert(utf8.encode('iptv-free-$pin')).toString();
  }
}
