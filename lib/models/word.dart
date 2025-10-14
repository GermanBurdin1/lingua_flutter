class Word {
  final int id;
  final String word;
  final String? translation;
  final String sourceLang;
  final String targetLang;
  final String? galaxy;
  final String? subtopic;
  final String? status;

  Word({
    required this.id,
    required this.word,
    this.translation,
    required this.sourceLang,
    required this.targetLang,
    this.galaxy,
    this.subtopic,
    this.status,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      sourceLang: json['sourceLang'],
      targetLang: json['targetLang'],
      galaxy: json['galaxy'],
      subtopic: json['subtopic'],
      status: json['status'],
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
    };
  }
}



