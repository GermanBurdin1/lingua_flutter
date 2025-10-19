// 📱 [MOBILE APP ONLY] Модель медиа-платформы
class MediaPlatform {
  final int id;
  final String userId;
  final String mediaType; // 'films', 'series', 'music', 'podcasts'
  final String name;
  final String? icon;
  final DateTime createdAt;

  MediaPlatform({
    required this.id,
    required this.userId,
    required this.mediaType,
    required this.name,
    this.icon,
    required this.createdAt,
  });

  factory MediaPlatform.fromJson(Map<String, dynamic> json) {
    return MediaPlatform(
      id: json['id'] as int,
      userId: json['userId'] as String,
      mediaType: json['mediaType'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mediaType': mediaType,
      'name': name,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Типы медиа-галактик
enum MediaGalaxyType {
  films('films', 'Films', '🎬'),
  series('series', 'Séries', '📺'),
  music('music', 'Musique', '🎵'),
  podcasts('podcasts', 'Podcasts', '🎙️');

  final String value;
  final String label;
  final String icon;

  const MediaGalaxyType(this.value, this.label, this.icon);
}

// Популярные платформы для каждого типа медиа
class PopularPlatforms {
  static const Map<String, List<PlatformSuggestion>> platforms = {
    'films': [
      PlatformSuggestion('Netflix', '📺'),
      PlatformSuggestion('Amazon Prime Video', '🎬'),
      PlatformSuggestion('Disney+', '✨'),
      PlatformSuggestion('HBO Max', '🎭'),
      PlatformSuggestion('Apple TV+', '🍎'),
      PlatformSuggestion('Paramount+', '⭐'),
      PlatformSuggestion('Hulu', '🟢'),
      PlatformSuggestion('Canal+', '📡'),
    ],
    'series': [
      PlatformSuggestion('Netflix', '📺'),
      PlatformSuggestion('HBO Max', '🎭'),
      PlatformSuggestion('Amazon Prime Video', '🎬'),
      PlatformSuggestion('Disney+', '✨'),
      PlatformSuggestion('Apple TV+', '🍎'),
      PlatformSuggestion('Hulu', '🟢'),
      PlatformSuggestion('Peacock', '🦚'),
      PlatformSuggestion('Paramount+', '⭐'),
    ],
    'music': [
      PlatformSuggestion('Spotify', '🎵'),
      PlatformSuggestion('Apple Music', '🍎'),
      PlatformSuggestion('YouTube Music', '🎥'),
      PlatformSuggestion('Deezer', '🎧'),
      PlatformSuggestion('Amazon Music', '🎶'),
      PlatformSuggestion('Tidal', '🌊'),
      PlatformSuggestion('SoundCloud', '☁️'),
      PlatformSuggestion('Pandora', '📻'),
    ],
    'podcasts': [
      PlatformSuggestion('Apple Podcasts', '🍎'),
      PlatformSuggestion('Spotify', '🎵'),
      PlatformSuggestion('Google Podcasts', '🔍'),
      PlatformSuggestion('Deezer', '🎧'),
      PlatformSuggestion('Amazon Music', '🎶'),
      PlatformSuggestion('Stitcher', '📻'),
      PlatformSuggestion('Podbean', '🫘'),
      PlatformSuggestion('Castbox', '📦'),
    ],
  };

  static List<PlatformSuggestion> getForMediaType(String mediaType) {
    return platforms[mediaType] ?? [];
  }
}

class PlatformSuggestion {
  final String name;
  final String icon;

  const PlatformSuggestion(this.name, this.icon);
}

