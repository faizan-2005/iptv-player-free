class PlaylistSource {
  PlaylistSource({
    required this.id,
    required this.name,
    required this.kind,
    this.m3uUrl = '',
    this.server = '',
    this.username = '',
    this.password = '',
    this.epgUrl = '',
  });

  final String id;
  final String name;
  final String kind;
  final String m3uUrl;
  final String server;
  final String username;
  final String password;
  final String epgUrl;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'kind': kind,
        'm3uUrl': m3uUrl,
        'server': server,
        'username': username,
        'password': password,
        'epgUrl': epgUrl,
      };

  factory PlaylistSource.fromMap(Map map) => PlaylistSource(
        id: '${map['id']}',
        name: '${map['name']}',
        kind: '${map['kind']}',
        m3uUrl: '${map['m3uUrl'] ?? ''}',
        server: '${map['server'] ?? ''}',
        username: '${map['username'] ?? ''}',
        password: '${map['password'] ?? ''}',
        epgUrl: '${map['epgUrl'] ?? ''}',
      );
}
