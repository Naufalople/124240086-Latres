class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episode;
  final List<String> characters;
  final String url;

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    required this.characters,
    required this.url,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown',
      airDate: json['air_date'] ?? 'Unknown',
      episode: json['episode'] ?? '',
      characters: json['characters'] != null && json['characters'] is List
          ? List<String>.from(json['characters'].map((e) => e.toString()))
          : [],
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'air_date': airDate,
      'episode': episode,
      'characters': characters,
      'url': url,
    };
  }
}
