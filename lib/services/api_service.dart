import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  // TODO: Добавить настоящую авторизацию
  // Временно используем тестовый токен или работаем без авторизации
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    // Временно: используйте токен из Angular приложения (откройте DevTools → Application → Local Storage)
    // Или добавьте авторизацию во Flutter
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Получить словарь
  Future<List<Word>> getLexicon({String? galaxy, String? subtopic}) async {
    final queryParams = <String, String>{};
    if (galaxy != null) queryParams['galaxy'] = galaxy;
    if (subtopic != null) queryParams['subtopic'] = subtopic;
    
    final uri = Uri.parse('$baseUrl/lexicon')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Word.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки словаря');
    }
  }

  // Добавить слово
  Future<Word> addWord({
    required String word,
    required String sourceLang,
    required String targetLang,
    String? galaxy,
    String? subtopic,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lexicon'),
      headers: _headers,
      body: json.encode({
        'word': word,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'galaxy': galaxy,
        'subtopic': subtopic,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Word.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ошибка добавления слова');
    }
  }

  // Распознать речь
  Future<String> recognizeSpeech(String audioPath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/speech/recognize'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['text'] ?? '';
      } else {
        throw Exception('Ошибка распознавания речи');
      }
    } catch (e) {
      print('Ошибка распознавания: $e');
      return '';
    }
  }
}



