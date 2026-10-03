import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/state/library_controller.dart';

class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    final series = lib.vod.where((e) => e.group.toLowerCase().contains('series')).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Series')),
      body: series.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.layers, size: 48),
                  SizedBox(height: 12),
                  Text('No series yet'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: series.length,
              itemBuilder: (context, i) {
                final s = series[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(leading: const Icon(LucideIcons.layers), title: Text(s.name)),
                );
              },
            ),
    );
  }
}
