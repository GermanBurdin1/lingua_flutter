import 'dart:convert';

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
  // Дополнительные поля для медиа-контента
  final String? genre; // Жанр (films/series) - может быть JSON-строка с массивом
  List<String>? get genres {
    // Парсим genre как JSON если это массив, иначе возвращаем как список из одного элемента
    if (genre == null || genre!.isEmpty) return null;
    try {
      // Пробуем распарсить как JSON массив
      final decoded = jsonDecode(genre!);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      // Если не JSON, возвращаем как список из одного элемента
    }
    // Если не JSON массив, возвращаем как список из одного элемента (для обратной совместимости)
    return [genre!];
  }
  final int? year; // Год выпуска (films/series/music)
  final String? director; // Режиссер (films/series)
  final String? host; // Ведущий (podcasts)
  final String? guests; // Приглашенные (podcasts)
  final String? album; // Альбом (music)

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
    this.genre,
    this.year,
    this.director,
    this.host,
    this.guests,
    this.album,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    // Извлекаем перевод и языки из массива translations, если он есть
    String? translation;
    String sourceLang = 'fr'; // Default
    String targetLang = 'ru'; // Default
    
    // Сначала пробуем получить из прямого поля (для обратной совместимости)
    if (json['translation'] != null) {
      translation = json['translation'] as String?;
    }
    
    // Если есть массив translations, извлекаем оттуда
    if (json['translations'] != null && json['translations'] is List) {
      final translations = json['translations'] as List;
      if (translations.isNotEmpty && translations[0] is Map) {
        final firstTranslation = translations[0] as Map<String, dynamic>;
        
        // Извлекаем перевод
        if (translation == null) {
          translation = firstTranslation['target'] as String?;
        }
        
        // Извлекаем языки из первого перевода
        if (firstTranslation['sourceLang'] != null) {
          sourceLang = firstTranslation['sourceLang'] as String;
        }
        if (firstTranslation['targetLang'] != null) {
          targetLang = firstTranslation['targetLang'] as String;
        }
      }
    }
    
    // Если языки не найдены в translations, пробуем из корня (для обратной совместимости)
    if (json['sourceLang'] != null) {
      sourceLang = json['sourceLang'] as String;
    }
    if (json['targetLang'] != null) {
      targetLang = json['targetLang'] as String;
    }
    
    return Word(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      word: json['word'] as String,
      translation: translation,
      sourceLang: sourceLang,
      targetLang: targetLang,
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
      genre: json['genre'] as String?,
      year: json['year'] as int?,
      director: json['director'] as String?,
      host: json['host'] as String?,
      guests: json['guests'] as String?,
      album: json['album'] as String?,
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
      'genre': genre,
      'year': year,
      'director': director,
      'host': host,
      'guests': guests,
      'album': album,
    };
  }
}



