import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/theme_mode_store.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('Auto'), icon: Icon(LucideIcons.monitorSmartphone)),
                      ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(LucideIcons.sun)),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(LucideIcons.moon)),
                    ],
                    selected: {mode},
                    onSelectionChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(LucideIcons.shieldCheck),
              title: Text('Player only'),
              subtitle: Text('You supply your own playlist. No channels included.'),
            ),
          ),
        ],
      ),
    );
  }
}
