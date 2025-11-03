import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/api_service.dart';

class VocabularyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Word> _words = [];
  bool _isLoading = false;
  String? _error;
  
  List<Word> get words => _words;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchWords({
    String? galaxy,
    String? subtopic,
    String? mediaType,
    String? mediaPlatform,
    String? mediaContentTitle,
    String? sourceLang,
    String? targetLang,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final allWords = await _apiService.getLexicon(
        galaxy: galaxy,
        subtopic: subtopic,
        mediaType: mediaType,
        mediaPlatform: mediaPlatform,
        mediaContentTitle: mediaContentTitle,
      );
      
      // Фильтруем по языкам на клиенте (если параметры переданы)
      if (sourceLang != null || targetLang != null) {
        _words = allWords.where((word) {
          final matchesSource = sourceLang == null || word.sourceLang == sourceLang;
          final matchesTarget = targetLang == null || word.targetLang == targetLang;
          return matchesSource && matchesTarget;
        }).toList();
      } else {
        _words = allWords;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addWord({
    required String word,
    required String sourceLang,
    required String targetLang,
    String? galaxy,
    String? subtopic,
    String? translation,
    String? type,
    String? mediaType,
    String? mediaPlatform,
    String? mediaContentTitle,
    int? season,
    int? episode,
    String? timestamp,
  }) async {
    try {
      final newWord = await _apiService.addWord(
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
        galaxy: galaxy,
        subtopic: subtopic,
        translation: translation,
        type: type,
        mediaType: mediaType,
        mediaPlatform: mediaPlatform,
        mediaContentTitle: mediaContentTitle,
        season: season,
        episode: episode,
        timestamp: timestamp,
      );
      _words.insert(0, newWord);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateWord({
    required int wordId,
    String? word,
    String? sourceLang,
    String? targetLang,
    String? galaxy,
    String? subtopic,
    String? translation,
    String? type,
    String? mediaType,
    String? mediaPlatform,
    String? mediaContentTitle,
    int? season,
    int? episode,
    String? timestamp,
  }) async {
    try {
      final updatedWord = await _apiService.updateWord(
        wordId: wordId,
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
        galaxy: galaxy,
        subtopic: subtopic,
        translation: translation,
        type: type,
        mediaType: mediaType,
        mediaPlatform: mediaPlatform,
        mediaContentTitle: mediaContentTitle,
        season: season,
        episode: episode,
        timestamp: timestamp,
      );
      // Обновляем слово в списке
      final index = _words.indexWhere((w) => w.id == wordId);
      if (index != -1) {
        _words[index] = updatedWord;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<String> requestTranslation({
    required String word,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      return await _apiService.requestTranslation(
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> deleteWord(int wordId) async {
    try {
      await _apiService.deleteWord(wordId);
      _words.removeWhere((word) => word.id == wordId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<String> recognizeSpeech(String audioPath) async {
    try {
      return await _apiService.recognizeSpeech(audioPath);
    } catch (e) {
      return '';
    }
  }
}



