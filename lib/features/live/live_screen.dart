import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/library_controller.dart';
import '../../core/storage/local_store.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  String query = '';
  String group = 'All';
  bool onlyFav = false;

  @override
  void initState() {
    super.initState();
    LocalStore.ensureOpen();
    Future.microtask(() => ref.read(libraryProvider.notifier).loadFirstAvailable());
  }

  @override
  Widget build(BuildContext context) {
    final lib = ref.watch(libraryProvider);
    final favBox = Hive.box('favorites');
    final channels = lib.channels.where((c) {
      final matchGroup = group == 'All' || c.group == group;
      final matchQuery = query.isEmpty || c.name.toLowerCase().contains(query);
      final matchFav = !onlyFav || favBox.containsKey(c.id);
      return matchGroup && matchQuery && matchFav;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV Player Free'),
        actions: [
          IconButton(icon: Icon(onlyFav ? LucideIcons.heart : LucideIcons.heartCrack), onPressed: () => setState(() => onlyFav = !onlyFav)),
          IconButton(icon: const Icon(LucideIcons.listPlus), onPressed: () => context.push('/sources')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Search channels', prefixIcon: Icon(LucideIcons.search)),
              onChanged: (v) => setState(() => query = v.toLowerCase()),
            ),
          ),
          if (lib.groups.length > 1)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: lib.groups.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final g = lib.groups[i];
                  final selected = g == group;
                  return ChoiceChip(label: Text(g), selected: selected, onSelected: (_) => setState(() => group = g));
                },
              ),
            ),
          if (lib.loading) const LinearProgressIndicator(),
          Expanded(
            child: lib.channels.isEmpty && !lib.loading
                ? emptyState(context)
                : ListView.builder(
                    itemCount: channels.length,
                    itemBuilder: (context, i) {
                      final c = channels[i];
                      final fav = favBox.containsKey(c.id);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: c.logo.isEmpty
                              ? const Icon(LucideIcons.tv)
                              : CachedNetworkImage(imageUrl: c.logo, width: 40, height: 40, errorWidget: (_, _, _) => const Icon(LucideIcons.tv)),
                          title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(c.group, maxLines: 1),
                          trailing: IconButton(
                            icon: Icon(fav ? LucideIcons.heart : LucideIcons.heartCrack),
                            onPressed: () => ref.read(libraryProvider.notifier).toggleFavorite(c),
                          ),
                          onTap: () => context.push('/player', extra: {'url': c.url, 'title': c.name}),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.tv, size: 48),
          const SizedBox(height: 12),
          Text('Add your playlist to start', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Player only. Bring your own M3U or Xtream login.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () => context.push('/sources'), icon: const Icon(LucideIcons.plus), label: const Text('Add source')),
        ],
      ),
    );
  }
}
