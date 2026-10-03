import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  static bool enabled = false;

  static Future<void> initOptional() async {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (url.isEmpty || key.isEmpty) {
      enabled = false;
      return;
    }
    await Supabase.initialize(url: url, anonKey: key);
    enabled = true;
  }

  static SupabaseClient? get client {
    if (!enabled) return null;
    return Supabase.instance.client;
  }
}
