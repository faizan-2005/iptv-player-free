class Program {
  Program({required this.channelId, required this.title, required this.desc, required this.start, required this.stop});

  final String channelId;
  final String title;
  final String desc;
  final DateTime start;
  final DateTime stop;

  bool get isLive {
    final now = DateTime.now().toUtc();
    return now.isAfter(start) && now.isBefore(stop);
  }
}
