class VodItem {
  VodItem({required this.id, required this.name, required this.url, this.logo = '', this.group = ''});

  final String id;
  final String name;
  final String url;
  final String logo;
  final String group;
}
