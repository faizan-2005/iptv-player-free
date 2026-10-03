import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/playlist_source.dart';
import '../../core/state/library_controller.dart';
import '../../core/storage/local_store.dart';

class PlaylistSourcesScreen extends ConsumerStatefulWidget {
  const PlaylistSourcesScreen({super.key});

  @override
  ConsumerState<PlaylistSourcesScreen> createState() => _PlaylistSourcesScreenState();
}

class _PlaylistSourcesScreenState extends ConsumerState<PlaylistSourcesScreen> {
  final nameController = TextEditingController();
  final m3uController = TextEditingController();
  final serverController = TextEditingController();
  final userController = TextEditingController();
  final passController = TextEditingController();
  final epgController = TextEditingController();
  bool isXtream = false;

  @override
  void dispose() {
    nameController.dispose();
    m3uController.dispose();
    serverController.dispose();
    userController.dispose();
    passController.dispose();
    epgController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    await LocalStore.ensureOpen();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final source = PlaylistSource(
      id: id,
      name: nameController.text.trim().isEmpty ? 'My playlist' : nameController.text.trim(),
      kind: isXtream ? 'xtream' : 'm3u',
      m3uUrl: m3uController.text.trim(),
      server: serverController.text.trim(),
      username: userController.text.trim(),
      password: passController.text.trim(),
      epgUrl: epgController.text.trim(),
    );
    await LocalStore.sources.put(id, source.toMap());
    await ref.read(libraryProvider.notifier).loadSource(source);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sources')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => addSheet()),
        child: const Icon(LucideIcons.plus),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('sources').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.listVideo, size: 48),
                  SizedBox(height: 12),
                  Text('No sources yet'),
                ],
              ),
            );
          }
          final items = box.values.map((e) => PlaylistSource.fromMap(Map.from(e))).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final s = items[i];
              return Card(
                child: ListTile(
                  leading: Icon(s.kind == 'xtream' ? LucideIcons.server : LucideIcons.link),
                  title: Text(s.name),
                  subtitle: Text(s.kind == 'xtream' ? s.server : s.m3uUrl),
                  trailing: IconButton(
                    icon: const Icon(LucideIcons.trash2),
                    onPressed: () => box.delete(s.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget addSheet() {
    return StatefulBuilder(
      builder: (context, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('M3U'), icon: Icon(LucideIcons.link)),
                  ButtonSegment(value: true, label: Text('Xtream'), icon: Icon(LucideIcons.server)),
                ],
                selected: {isXtream},
                onSelectionChanged: (v) => setSheet(() => isXtream = v.first),
              ),
              const SizedBox(height: 12),
              TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Name')),
              const SizedBox(height: 8),
              if (!isXtream) TextField(controller: m3uController, decoration: const InputDecoration(hintText: 'M3U URL or file path')),
              if (isXtream) ...[
                TextField(controller: serverController, decoration: const InputDecoration(hintText: 'Server URL')),
                const SizedBox(height: 8),
                TextField(controller: userController, decoration: const InputDecoration(hintText: 'Username')),
                const SizedBox(height: 8),
                TextField(controller: passController, decoration: const InputDecoration(hintText: 'Password'), obscureText: true),
              ],
              const SizedBox(height: 8),
              TextField(controller: epgController, decoration: const InputDecoration(hintText: 'EPG URL optional')),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: save, icon: const Icon(LucideIcons.check), label: const Text('Save')),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
