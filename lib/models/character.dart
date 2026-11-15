class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String originName;
  final String locationName;
  final String image;
  final List<String> episode;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
    required this.episode,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown',
      status: json['status'] ?? 'unknown',
      species: json['species'] ?? 'Unknown',
      type: json['type'] ?? '',
      gender: json['gender'] ?? 'Unknown',
      originName: json['origin'] != null && json['origin'] is Map
          ? (json['origin']['name'] ?? 'Unknown')
          : (json['originName'] ?? 'Unknown'),
      locationName: json['location'] != null && json['location'] is Map
          ? (json['location']['name'] ?? 'Unknown')
          : (json['locationName'] ?? 'Unknown'),
      image: json['image'] ?? '',
      episode: json['episode'] != null && json['episode'] is List
          ? List<String>.from(json['episode'].map((e) => e.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'originName': originName,
      'locationName': locationName,
      'image': image,
      'episode': episode,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
