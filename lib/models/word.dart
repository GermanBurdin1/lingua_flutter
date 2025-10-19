class Word {
  final int id;
  final String word;
  final String? translation;
  final String sourceLang;
  final String targetLang;
  final String? galaxy;
  final String? subtopic;
  final String? status;
  final String? type;
  final String? mediaType; // 'films', 'series', 'music', 'podcasts'
  final String? mediaPlatform; // 'Netflix', 'Spotify', etc.
  final String? mediaContentTitle; // 'Dexter', 'Inception', etc.
  final int? season; // Сезон (для сериалов)
  final int? episode; // Серия (для сериалов)
  final String? timestamp; // Временная метка: "12:34"

  Word({
    required this.id,
    required this.word,
    this.translation,
    this.sourceLang = 'fr', // Default value
    this.targetLang = 'ru', // Default value
    this.galaxy,
    this.subtopic,
    this.status,
    this.type,
    this.mediaType,
    this.mediaPlatform,
    this.mediaContentTitle,
    this.season,
    this.episode,
    this.timestamp,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      word: json['word'] as String,
      translation: json['translation'] as String?,
      sourceLang: json['sourceLang'] as String? ?? 'fr',
      targetLang: json['targetLang'] as String? ?? 'ru',
      galaxy: json['galaxy'] as String?,
      subtopic: json['subtopic'] as String?,
      status: json['status'] as String?,
      type: json['type'] as String?,
      mediaType: json['mediaType'] as String?,
      mediaPlatform: json['mediaPlatform'] as String?,
      mediaContentTitle: json['mediaContentTitle'] as String?,
      season: json['season'] as int?,
      episode: json['episode'] as int?,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'galaxy': galaxy,
      'subtopic': subtopic,
      'status': status,
      'type': type,
      'mediaType': mediaType,
      'mediaPlatform': mediaPlatform,
      'mediaContentTitle': mediaContentTitle,
      'season': season,
      'episode': episode,
      'timestamp': timestamp,
    };
  }
}



