import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/storage/local_store.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  String query = '';
  String group = 'All';

  @override
  void initState() {
    super.initState();
    LocalStore.ensureOpen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV Player Free'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.listPlus),
            onPressed: () => context.push('/sources'),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('favorites').listenable(),
        builder: (context, favBox, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search channels',
                    prefixIcon: Icon(LucideIcons.search),
                  ),
                  onChanged: (v) => setState(() => query = v.toLowerCase()),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.tv, size: 48),
                      const SizedBox(height: 12),
                      Text('Add your playlist to start', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('Player only. Bring your own M3U or Xtream login.', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.push('/sources'),
                        icon: const Icon(LucideIcons.plus),
                        label: const Text('Add source'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
