import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadEntry {
  DownloadEntry({required this.id, required this.name, required this.url, this.path = '', this.progress = 0, this.status = 'queued'});

  final String id;
  final String name;
  final String url;
  final String path;
  final double progress;
  final String status;

  DownloadEntry copy({String? path, double? progress, String? status}) {
    return DownloadEntry(id: id, name: name, url: url, path: path ?? this.path, progress: progress ?? this.progress, status: status ?? this.status);
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'url': url, 'path': path};

  factory DownloadEntry.fromMap(Map map) => DownloadEntry(id: '${map['id']}', name: '${map['name']}', url: '${map['url']}', path: '${map['path'] ?? ''}', progress: 1, status: 'done');
}

final downloadProvider = StateNotifierProvider<DownloadStore, List<DownloadEntry>>((ref) => DownloadStore());

class DownloadStore extends StateNotifier<List<DownloadEntry>> {
  DownloadStore() : super([]) {
    restore();
  }

  Future<void> restore() async {
    if (!Hive.isBoxOpen('downloads')) await Hive.openBox('downloads');
    final box = Hive.box('downloads');
    state = box.values.map((e) => DownloadEntry.fromMap(Map.from(e))).toList();
  }

  bool get supportsUrl => true;

  Future<void> start(String name, String url) async {
    if (url.contains('.m3u8')) {
      final entry = DownloadEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, url: url, status: 'error');
      state = [...state, entry];
      return;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    var entry = DownloadEntry(id: id, name: name, url: url, status: 'running');
    state = [...state, entry];
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safe = name.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_').substring(0, name.length > 40 ? 40 : name.length);
      final filePath = p.join(dir.path, '$safe-$id.mp4');
      final req = http.Request('GET', Uri.parse(url));
      final res = await http.Client().send(req);
      final total = res.contentLength ?? 0;
      final file = File(filePath);
      final sink = file.openWrite();
      int done = 0;
      await for (final chunk in res.stream) {
        sink.add(chunk);
        done += chunk.length;
        final double progress = total > 0 ? done / total : 0.0;
        entry = entry.copy(progress: progress, status: 'running');
        state = state.map((e) => e.id == id ? entry : e).toList();
      }
      await sink.close();
      entry = entry.copy(path: filePath, progress: 1, status: 'done');
      state = state.map((e) => e.id == id ? entry : e).toList();
      await Hive.box('downloads').put(id, entry.toMap());
    } catch (_) {
      entry = entry.copy(status: 'error');
      state = state.map((e) => e.id == id ? entry : e).toList();
    }
  }

  Future<void> remove(String id) async {
    final target = state.where((e) => e.id == id).toList();
    if (target.isNotEmpty && target.first.path.isNotEmpty) {
      try {
        await File(target.first.path).delete();
      } catch (_) {}
    }
    await Hive.box('downloads').delete(id);
    state = state.where((e) => e.id != id).toList();
  }
}
