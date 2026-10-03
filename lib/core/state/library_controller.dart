import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import '../models/playlist_source.dart';
import '../models/program.dart';
import '../models/vod_item.dart';
import '../net/epg_parser.dart';
import '../net/m3u_parser.dart';
import '../net/xtream_api.dart';
import '../storage/local_store.dart';

class LibraryState {
  LibraryState({
    this.loading = false,
    this.channels = const [],
    this.vod = const [],
    this.groups = const ['All'],
    this.epg = const {},
    this.activeSourceId = '',
    this.error = '',
  });

  final bool loading;
  final List<Channel> channels;
  final List<VodItem> vod;
  final List<String> groups;
  final Map<String, List<Program>> epg;
  final String activeSourceId;
  final String error;

  LibraryState copy({
    bool? loading,
    List<Channel>? channels,
    List<VodItem>? vod,
    List<String>? groups,
    Map<String, List<Program>>? epg,
    String? activeSourceId,
    String? error,
  }) {
    return LibraryState(
      loading: loading ?? this.loading,
      channels: channels ?? this.channels,
      vod: vod ?? this.vod,
      groups: groups ?? this.groups,
      epg: epg ?? this.epg,
      activeSourceId: activeSourceId ?? this.activeSourceId,
      error: error ?? this.error,
    );
  }
}

final libraryProvider = StateNotifierProvider<LibraryStore, LibraryState>((ref) => LibraryStore());

class LibraryStore extends StateNotifier<LibraryState> {
  LibraryStore() : super(LibraryState());

  Future<void> loadFirstAvailable() async {
    await LocalStore.ensureOpen();
    if (LocalStore.sources.isEmpty) return;
    final first = PlaylistSource.fromMap(Map.from(LocalStore.sources.values.first));
    await loadSource(first);
  }

  Future<void> loadSource(PlaylistSource source) async {
    state = state.copy(loading: true, error: '', activeSourceId: source.id);
    try {
      if (source.kind == 'xtream') {
        await _loadXtream(source);
      } else {
        await _loadM3u(source);
      }
    } catch (e) {
      state = state.copy(loading: false, error: '$e');
      return;
    }
    state = state.copy(loading: false);
  }

  Future<void> _loadXtream(PlaylistSource source) async {
    final api = XtreamApi(server: source.server, username: source.username, password: source.password);
    final live = await api.liveStreams();
    final vodRaw = await api.vodStreams();
    final channels = live.map((e) {
      final id = '${e['stream_id']}';
      final name = '${e['name'] ?? 'Channel $id'}';
      final logo = '${e['stream_icon'] ?? ''}';
      final group = '${e['category_name'] ?? 'General'}';
      final tvg = '${e['epg_channel_id'] ?? ''}';
      return Channel(id: id, name: name, url: api.liveUrl(int.tryParse(id) ?? 0), logo: logo, group: group, tvgId: tvg);
    }).toList();
    final vod = vodRaw.map((e) {
      final id = '${e['stream_id']}';
      final name = '${e['name'] ?? 'Video $id'}';
      final logo = '${e['stream_icon'] ?? ''}';
      return VodItem(id: id, name: name, url: api.vodUrl(int.tryParse(id) ?? 0), logo: logo);
    }).toList();
    final groups = {'All', ...channels.map((c) => c.group)}.toList();
    Map<String, List<Program>> epg = {};
    try {
      final epgUrl = source.epgUrl.isNotEmpty ? source.epgUrl : api.epgUrl();
      final res = await http.get(Uri.parse(epgUrl));
      if (res.statusCode == 200 && res.body.contains('<programme')) {
        epg = EpgParser.parse(res.body);
      }
    } catch (_) {}
    state = state.copy(channels: channels, vod: vod, groups: groups, epg: epg);
  }

  Future<void> _loadM3u(PlaylistSource source) async {
    String content = '';
    if (source.m3uUrl.startsWith('http')) {
      final res = await http.get(Uri.parse(source.m3uUrl));
      content = res.body;
    }
    if (content.isEmpty) {
      state = state.copy(channels: [], vod: [], groups: ['All'], epg: {});
      return;
    }
    final channels = M3uParser.parse(content);
    final groups = {'All', ...channels.map((c) => c.group)}.toList();
    Map<String, List<Program>> epg = {};
    final epgUrl = source.epgUrl.isNotEmpty ? source.epgUrl : M3uParser.epgUrlFrom(content);
    if (epgUrl != null && epgUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(epgUrl));
        if (res.statusCode == 200) epg = EpgParser.parse(res.body);
      } catch (_) {}
    }
    state = state.copy(channels: channels, vod: [], groups: groups, epg: epg);
  }

  bool isFavorite(String id) {
    return LocalStore.favorites.containsKey(id);
  }

  Future<void> toggleFavorite(Channel channel) async {
    await LocalStore.ensureOpen();
    if (LocalStore.favorites.containsKey(channel.id)) {
      await LocalStore.favorites.delete(channel.id);
    } else {
      await LocalStore.favorites.put(channel.id, {'id': channel.id, 'name': channel.name, 'url': channel.url, 'logo': channel.logo});
    }
    state = state.copy();
  }
}
