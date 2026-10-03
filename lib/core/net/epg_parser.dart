import 'package:xml/xml.dart';
import '../models/program.dart';

class EpgParser {
  static Map<String, List<Program>> parse(String content) {
    final doc = XmlDocument.parse(content);
    final out = <String, List<Program>>{};
    for (final node in doc.findAllElements('programme')) {
      final channel = node.getAttribute('channel') ?? '';
      final start = _toDate(node.getAttribute('start'));
      final stop = _toDate(node.getAttribute('stop'));
      String title = '';
      String desc = '';
      for (final child in node.childElements) {
        if (child.name.local == 'title' && title.isEmpty) title = child.innerText.trim();
        if (child.name.local == 'desc' && desc.isEmpty) desc = child.innerText.trim();
      }
      if (channel.isEmpty) continue;
      out.putIfAbsent(channel, () => []);
      out[channel]!.add(Program(channelId: channel, title: title, desc: desc, start: start, stop: stop));
    }
    for (final list in out.values) {
      list.sort((a, b) => a.start.compareTo(b.start));
    }
    return out;
  }

  static DateTime _toDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    final clean = raw.split(' ').first;
    try {
      final y = int.parse(clean.substring(0, 4));
      final m = int.parse(clean.substring(4, 6));
      final d = int.parse(clean.substring(6, 8));
      final h = int.parse(clean.substring(8, 10));
      final min = int.parse(clean.substring(10, 12));
      final s = clean.length >= 14 ? int.parse(clean.substring(12, 14)) : 0;
      return DateTime.utc(y, m, d, h, min, s);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
