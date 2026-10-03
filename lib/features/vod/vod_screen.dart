import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VodScreen extends StatelessWidget {
  const VodScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}
