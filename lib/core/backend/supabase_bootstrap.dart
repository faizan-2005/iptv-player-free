import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  static bool enabled = false;

  static Future<void> initOptional() async {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const publishable = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: '');
    const legacy = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    final key = publishable.isNotEmpty ? publishable : legacy;
    if (url.isEmpty || key.isEmpty) {
      enabled = false;
      return;
    }
    await Supabase.initialize(url: url, publishableKey: key);
    enabled = true;
  }

  static SupabaseClient? get client {
    if (!enabled) return null;
    return Supabase.instance.client;
  }
}
