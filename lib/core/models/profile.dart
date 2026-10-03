class Profile {
  Profile({required this.id, required this.name, this.pinHash = '', this.lockedGroups = const [], this.isKids = false});

  final String id;
  final String name;
  final String pinHash;
  final List<String> lockedGroups;
  final bool isKids;

  bool get locked => pinHash.isNotEmpty;

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'pinHash': pinHash, 'lockedGroups': lockedGroups, 'isKids': isKids};

  factory Profile.fromMap(Map map) => Profile(
        id: '${map['id']}',
        name: '${map['name'] ?? 'Profile'}',
        pinHash: '${map['pinHash'] ?? ''}',
        lockedGroups: (map['lockedGroups'] as List? ?? []).map((e) => '$e').toList(),
        isKids: map['isKids'] == true,
      );
}
