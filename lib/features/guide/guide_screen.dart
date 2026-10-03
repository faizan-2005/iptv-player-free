import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guide')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.calendarDays, size: 48),
            SizedBox(height: 12),
            Text('EPG will appear here'),
          ],
        ),
      ),
    );
  }
}
