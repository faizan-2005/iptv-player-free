import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/downloads/download_store.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(downloadProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.download, size: 48),
                  SizedBox(height: 12),
                  Text('No downloads yet'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final d = items[i];
                return Card(
                  child: ListTile(
                    leading: Icon(d.status == 'done' ? LucideIcons.fileVideo : d.status == 'error' ? LucideIcons.alertTriangle : LucideIcons.loader),
                    title: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: d.status == 'running'
                        ? LinearProgressIndicator(value: d.progress == 0 ? null : d.progress)
                        : Text(d.status == 'error' ? 'HLS streams cannot be saved. MP4 only.' : 'Saved'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (d.status == 'done' && d.path.isNotEmpty)
                          IconButton(icon: const Icon(LucideIcons.play), onPressed: () => context.push('/player', extra: {'url': File(d.path).uri.toString(), 'title': d.name})),
                        IconButton(icon: const Icon(LucideIcons.trash2), onPressed: () => ref.read(downloadProvider.notifier).remove(d.id)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
