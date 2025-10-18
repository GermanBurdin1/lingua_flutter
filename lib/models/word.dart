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
    };
  }
}



