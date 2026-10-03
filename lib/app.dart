import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/backend/supabase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_store.dart';
import 'features/downloads/downloads_screen.dart';
import 'features/guide/guide_screen.dart';
import 'features/home/home_shell.dart';
import 'features/live/live_screen.dart';
import 'features/player/player_screen.dart';
import 'features/playlist/playlist_sources_screen.dart';
import 'features/profiles/profiles_screen.dart';
import 'features/series/series_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/vod/vod_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/live',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/live', builder: (c, s) => const LiveScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/movies', builder: (c, s) => const VodScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/series', builder: (c, s) => const SeriesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/guide', builder: (c, s) => const GuideScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/sources', builder: (c, s) => const PlaylistSourcesScreen()),
      GoRoute(path: '/profiles', builder: (c, s) => const ProfilesScreen()),
      GoRoute(path: '/downloads', builder: (c, s) => const DownloadsScreen()),
      GoRoute(
        path: '/player',
        builder: (c, s) {
          final extra = s.extra as Map<String, String>?;
          return PlayerScreen(
            url: extra?['url'] ?? '',
            title: extra?['title'] ?? 'Now Playing',
          );
        },
      ),
    ],
  );
});

class IptvApp extends ConsumerStatefulWidget {
  const IptvApp({super.key});

  @override
  ConsumerState<IptvApp> createState() => _IptvAppState();
}

class _IptvAppState extends ConsumerState<IptvApp> {
  bool ready = false;

  @override
  void initState() {
    super.initState();
    SupabaseBootstrap.initOptional().whenComplete(() {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'IPTV Player Free',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: router,
    );
  }
}
