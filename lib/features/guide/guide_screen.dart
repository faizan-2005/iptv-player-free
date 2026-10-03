import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/library_controller.dart';

class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    final entries = lib.epg.entries.take(50).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Guide')),
      body: entries.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.calendarDays, size: 48),
                  SizedBox(height: 12),
                  Text('EPG will appear here'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final programs = entries[i].value.take(3).toList();
                final live = programs.where((p) => p.isLive).toList();
                final current = live.isNotEmpty ? live.first : (programs.isNotEmpty ? programs.first : null);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const Icon(LucideIcons.calendarDays),
                    title: Text(entries[i].key),
                    subtitle: Text(current?.title ?? 'No program info'),
                  ),
                );
              },
            ),
    );
  }
}
