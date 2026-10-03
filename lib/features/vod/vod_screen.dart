import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/state/library_controller.dart';

class VodScreen extends ConsumerWidget {
  const VodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    if (lib.vod.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Movies')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.clapperboard, size: 48),
              SizedBox(height: 12),
              Text('No movies yet'),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: lib.vod.length,
        itemBuilder: (context, i) {
          final v = lib.vod[i];
          return GestureDetector(
            onTap: () => context.push('/player', extra: {'url': v.url, 'title': v.name}),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: v.logo.isEmpty
                        ? const Icon(LucideIcons.clapperboard, size: 40)
                        : CachedNetworkImage(imageUrl: v.logo, fit: BoxFit.cover, errorWidget: (_, _, _) => const Icon(LucideIcons.clapperboard)),
                  ),
                  Padding(padding: const EdgeInsets.all(8), child: Text(v.name, maxLines: 2, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
