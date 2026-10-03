import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Series')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.layers, size: 48),
            SizedBox(height: 12),
            Text('No series yet'),
          ],
        ),
      ),
    );
  }
}
