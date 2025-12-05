class M1AUBotReply {
  final String message;
  final List<M1AUConcertCard> concerts;
  final Map<String, String> filters;
  final M1AUMeta meta;

  M1AUBotReply({
    required this.message,
    required this.concerts,
    required this.filters,
    required this.meta,
  });

  factory M1AUBotReply.fromJson(Map<String, dynamic> json) {
    return M1AUBotReply(
      message: json['message'] as String? ?? '',
      concerts: (json['concerts'] as List<dynamic>?)
          ?.map((e) => M1AUConcertCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      filters: Map<String, String>.from(json['filters'] as Map? ?? {}),
      meta: M1AUMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class M1AUConcertCard {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? formattedDate;
  final M1AUArtist? artist;
  final M1AUVenue? venue;
  final M1AUPlatform? platform;

  M1AUConcertCard({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.formattedDate,
    this.artist,
    this.venue,
    this.platform,
  });

  factory M1AUConcertCard.fromJson(Map<String, dynamic> json) {
    return M1AUConcertCard(
      id: json['id']?.toString() ?? '0',
      title: json['title'] as String? ?? 'Sin título',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      formattedDate: json['formattedDate'] as String?,
      artist: json['artist'] != null
          ? M1AUArtist.fromJson(json['artist'] as Map<String, dynamic>)
          : null,
      venue: json['venue'] != null
          ? M1AUVenue.fromJson(json['venue'] as Map<String, dynamic>)
          : null,
      platform: json['platform'] != null
          ? M1AUPlatform.fromJson(json['platform'] as Map<String, dynamic>)
          : null,
    );
  }
}

class M1AUArtist {
  final String? id;
  final String? name;
  final String? username;

  M1AUArtist({this.id, this.name, this.username});

  factory M1AUArtist.fromJson(Map<String, dynamic> json) {
    return M1AUArtist(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      username: json['username'] as String?,
    );
  }
}

class M1AUVenue {
  final String? id;
  final String? name;
  final String? address;

  M1AUVenue({this.id, this.name, this.address});

  factory M1AUVenue.fromJson(Map<String, dynamic> json) {
    return M1AUVenue(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      address: json['address'] as String?,
    );
  }
}

class M1AUPlatform {
  final String? id;
  final String? name;

  M1AUPlatform({this.id, this.name});

  factory M1AUPlatform.fromJson(Map<String, dynamic> json) {
    return M1AUPlatform(
      id: json['id']?.toString(),
      name: json['name'] as String?,
    );
  }
}

class M1AUMeta {
  final int total;
  final bool hasResults;

  M1AUMeta({required this.total, required this.hasResults});

  factory M1AUMeta.fromJson(Map<String, dynamic> json) {
    return M1AUMeta(
      total: json['total'] as int? ?? 0,
      hasResults: json['hasResults'] as bool? ?? false,
    );
  }
}