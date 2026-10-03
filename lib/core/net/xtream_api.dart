import 'dart:convert';
import 'package:http/http.dart' as http;

class XtreamApi {
  XtreamApi({required this.server, required this.username, required this.password});

  final String server;
  final String username;
  final String password;

  String get base => server.endsWith('/') ? server.substring(0, server.length - 1) : server;

  Map<String, String> get auth => {'username': username, 'password': password};

  Future<Map<String, dynamic>> login() async {
    final uri = Uri.parse('$base/player_api.php').replace(queryParameters: auth);
    final res = await http.get(uri);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> liveStreams() async {
    final uri = Uri.parse('$base/player_api.php').replace(queryParameters: {...auth, 'action': 'get_live_streams'});
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    return data is List ? data : [];
  }

  Future<List<dynamic>> vodStreams() async {
    final uri = Uri.parse('$base/player_api.php').replace(queryParameters: {...auth, 'action': 'get_vod_streams'});
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    return data is List ? data : [];
  }

  Future<List<dynamic>> series() async {
    final uri = Uri.parse('$base/player_api.php').replace(queryParameters: {...auth, 'action': 'get_series'});
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    return data is List ? data : [];
  }

  String liveUrl(int streamId, {String extension = 'm3u8'}) {
    return '$base/live/$username/$password/$streamId.$extension';
  }

  String vodUrl(int streamId, {String extension = 'mp4'}) {
    return '$base/movie/$username/$password/$streamId.$extension';
  }

  String epgUrl() {
    return '$base/xmltv.php?username=$username&password=$password';
  }

  Future<List<dynamic>> shortEpg(int streamId, {int limit = 4}) async {
    final uri = Uri.parse('$base/player_api.php').replace(queryParameters: {
      ...auth,
      'action': 'get_short_epg',
      'stream_id': '$streamId',
      'limit': '$limit',
    });
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    if (data is Map && data['epg_listings'] is List) return data['epg_listings'] as List;
    return [];
  }
}
