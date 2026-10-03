class Channel {
  Channel({
    required this.id,
    required this.name,
    required this.url,
    this.logo = '',
    this.group = '',
    this.tvgId = '',
  });

  final String id;
  final String name;
  final String url;
  final String logo;
  final String group;
  final String tvgId;

  factory Channel.fromM3uEntry({
    required String id,
    required String name,
    required String url,
    String logo = '',
    String group = '',
    String tvgId = '',
  }) =>
      Channel(id: id, name: name, url: url, logo: logo, group: group, tvgId: tvgId);
}
