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
  
  Future<void> fetchWords({String? galaxy, String? subtopic}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _words = await _apiService.getLexicon(galaxy: galaxy, subtopic: subtopic);
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
  }) async {
    try {
      final newWord = await _apiService.addWord(
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
        galaxy: galaxy,
        subtopic: subtopic,
        translation: translation,
      );
      _words.insert(0, newWord);
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
  
  Future<String> recognizeSpeech(String audioPath) async {
    try {
      return await _apiService.recognizeSpeech(audioPath);
    } catch (e) {
      return '';
    }
  }
}



