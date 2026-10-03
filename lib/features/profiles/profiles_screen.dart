import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/profiles/profile_store.dart';

class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  final nameController = TextEditingController();
  final pinController = TextEditingController();
  bool isKids = false;

  @override
  void dispose() {
    nameController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> askPinAndEnter(String profileId, String name, bool locked) async {
    if (!locked) {
      ref.read(activeProfileIdProvider.notifier).state = profileId;
      if (mounted) context.pop();
      return;
    }
    final pin = TextEditingController();
    final ok = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock $name'),
        content: TextField(controller: pin, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '4-digit PIN')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, pin.text), child: const Text('Unlock')),
        ],
      ),
    );
    if (ok == null) return;
    final all = ref.read(profileProvider);
    final target = all.firstWhere((p) => p.id == profileId);
    final valid = ref.read(profileProvider.notifier).verify(target, ok);
    if (valid) {
      ref.read(activeProfileIdProvider.notifier).state = profileId;
      if (mounted) context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong PIN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profiles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => addSheet()),
        child: const Icon(LucideIcons.plus),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: profiles.length,
        itemBuilder: (context, i) {
          final p = profiles[i];
          final active = p.id == activeId;
          return Card(
            child: ListTile(
              leading: Icon(p.isKids ? LucideIcons.baby : LucideIcons.user, color: active ? Theme.of(context).colorScheme.primary : null),
              title: Text(p.name),
              subtitle: Text(p.locked ? 'Locked' : 'Open'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (p.locked) const Icon(LucideIcons.lock, size: 16),
                  if (active) const Icon(LucideIcons.check, size: 16),
                  IconButton(icon: const Icon(LucideIcons.trash2), onPressed: () => ref.read(profileProvider.notifier).remove(p.id)),
                ],
              ),
              onTap: () => askPinAndEnter(p.id, p.name, p.locked),
            ),
          );
        },
      ),
    );
  }

  Widget addSheet() {
    return StatefulBuilder(
      builder: (context, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Profile name')),
            const SizedBox(height: 8),
            TextField(controller: pinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'PIN optional')),
            SwitchListTile(value: isKids, onChanged: (v) => setSheet(() => isKids = v), title: const Text('Kids profile'), secondary: const Icon(LucideIcons.baby)),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(profileProvider.notifier).add(nameController.text, pin: pinController.text.trim(), isKids: isKids);
                nameController.clear();
                pinController.clear();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.check),
              label: const Text('Save'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

final activeProfileIdProvider = StateProvider<String>((ref) => 'main');
