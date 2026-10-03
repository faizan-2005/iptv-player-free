import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.tv), label: 'Live'),
          NavigationDestination(icon: Icon(LucideIcons.clapperboard), label: 'Movies'),
          NavigationDestination(icon: Icon(LucideIcons.layers), label: 'Series'),
          NavigationDestination(icon: Icon(LucideIcons.calendarDays), label: 'Guide'),
          NavigationDestination(icon: Icon(LucideIcons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
