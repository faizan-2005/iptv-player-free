import '../models/channel.dart';

class M3uParser {
  static List<Channel> parse(String content) {
    final lines = content.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final out = <Channel>[];
    String name = '';
    String logo = '';
    String group = '';
    String tvgId = '';
    int auto = 0;
    for (final line in lines) {
      if (line.startsWith('#EXTINF')) {
        name = _displayName(line);
        logo = _attr(line, 'tvg-logo');
        group = _attr(line, 'group-title');
        tvgId = _attr(line, 'tvg-id');
      } else if (!line.startsWith('#')) {
        auto++;
        final label = name.isEmpty ? 'Channel $auto' : name;
        out.add(Channel.fromM3uEntry(
          id: tvgId.isNotEmpty ? tvgId : '$auto-$label',
          name: label,
          url: line,
          logo: logo,
          group: group.isEmpty ? 'General' : group,
          tvgId: tvgId,
        ));
        name = '';
        logo = '';
        group = '';
        tvgId = '';
      }
    }
    return out;
  }

  static String _displayName(String line) {
    final idx = line.lastIndexOf(',');
    if (idx < 0 || idx == line.length - 1) return '';
    return line.substring(idx + 1).trim();
  }

  static String _attr(String line, String key) {
    final needle = '$key="';
    final start = line.indexOf(needle);
    if (start < 0) return '';
    final rest = line.substring(start + needle.length);
    final end = rest.indexOf('"');
    if (end < 0) return '';
    return rest.substring(0, end);
  }

  static String? epgUrlFrom(String content) {
    for (final raw in content.split('\n')) {
      final line = raw.trim();
      if (line.startsWith('#EXTM3U')) {
        final url = _attr(line, 'x-tvg-url');
        if (url.isNotEmpty) return url;
      }
    }
    return null;
  }
}
