import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../models/user.dart';

class ApiService {
  // Используем API Gateway для всех запросов
  static const String apiGatewayUrl = 'http://localhost:3011';
  static const String authBaseUrl = '$apiGatewayUrl/auth';
  
  // Обращаемся через API Gateway
  static const String vocabularyBaseUrl = '$apiGatewayUrl/vocabulary';
  
  String? _accessToken;
  String? _refreshToken;
  
  // Получить токен из SharedPreferences
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }
  
  // Сохранить токены в SharedPreferences
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }
  
  // Удалить токены
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // ============= AUTH ENDPOINTS =============
  
  // Логин
  Future<AuthResponse> login(String email, String password) async {
    final url = '$authBaseUrl/login';
    print('🔐 Login URL: $url');
    print('🔐 authBaseUrl: $authBaseUrl');
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body length: ${response.body.length}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      print('✅ Parsed response data');
      print('🔑 Has access_token: ${data['access_token'] != null}');
      print('🔑 Has user: ${data['user'] != null}');
      
      final authResponse = AuthResponse.fromJson(data);
      print('✅ AuthResponse created');
      print('👤 User email: ${authResponse.user.email}');
      
      await saveTokens(authResponse.accessToken, authResponse.refreshToken);
      print('💾 Tokens saved');
      
      return authResponse;
    } else {
      print('❌ Login failed with status: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Ошибка входа');
    }
  }
  
  // Регистрация
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String surname,
    List<String> roles = const ['student'],
  }) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
        'surname': surname,
        'roles': roles,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      await saveTokens(authResponse.accessToken, authResponse.refreshToken);
      return authResponse;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Ошибка регистрации');
    }
  }
  
  // Обновить токен
  Future<AuthResponse> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('Нет refresh токена');
    }
    
    final response = await http.post(
      Uri.parse('$authBaseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'refresh_token': _refreshToken,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      await saveTokens(authResponse.accessToken, authResponse.refreshToken);
      return authResponse;
    } else {
      await clearTokens();
      throw Exception('Ошибка обновления токена');
    }
  }
  
  // Получить профиль
  Future<User> getProfile() async {
    await loadTokens();
    final response = await http.get(
      Uri.parse('$authBaseUrl/profile'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      // Попытка обновить токен
      await refreshAccessToken();
      return getProfile(); // Повторная попытка
    } else {
      throw Exception('Ошибка получения профиля');
    }
  }

  // ============= VOCABULARY ENDPOINTS =============

  // Получить словарь
  Future<List<Word>> getLexicon({String? galaxy, String? subtopic}) async {
    await loadTokens();
    
    print('📚 getLexicon called');
    print('📚 galaxy: $galaxy, subtopic: $subtopic');
    print('📚 access_token present: ${_accessToken != null}');
    
    final queryParams = <String, String>{};
    if (galaxy != null) queryParams['galaxy'] = galaxy;
    if (subtopic != null) queryParams['subtopic'] = subtopic;
    
    final uri = Uri.parse('$vocabularyBaseUrl/lexicon')
        .replace(queryParameters: queryParams);
    
    print('📚 Request URL: $uri');
    print('📚 Headers: ${_headers.keys.join(", ")}');
    
    final response = await http.get(uri, headers: _headers);
    
    print('📚 Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('📚 Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      final responseData = json.decode(response.body);
      print('📚 Response structure: ${responseData.runtimeType}');
      
      // Сервер может вернуть либо массив напрямую, либо объект с ключом "data"
      List<dynamic> data;
      if (responseData is List) {
        print('📚 Response is List directly');
        data = responseData;
      } else if (responseData is Map && responseData.containsKey('data')) {
        print('📚 Response is Map with "data" key');
        data = responseData['data'];
      } else {
        print('❌ Unexpected response structure');
        throw Exception('Unexpected response structure');
      }
      
      print('📚 Number of words: ${data.length}');
      if (data.isNotEmpty) {
        print('📚 First word structure: ${data[0]}');
      }
      return data.map((json) => Word.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return getLexicon(galaxy: galaxy, subtopic: subtopic);
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
    String? translation,
    String? type,
  }) async {
    await loadTokens();

    // Формируем данные в формате, который ожидает бэкенд (как в Angular)
    final Map<String, dynamic> body = {
      'word': word,
      'galaxy': galaxy,
      'subtopic': subtopic,
      'type': type ?? 'word',
    };

    // Если есть перевод, добавляем массив translations (как в Angular)
    if (translation != null && translation.isNotEmpty) {
      body['translations'] = [
        {
          'id': 0,
          'lexiconId': 0,
          'source': word,
          'target': translation,
          'sourceLang': sourceLang,
          'targetLang': targetLang,
          'meaning': '',
          'example': null,
        }
      ];
    }

    final response = await http.post(
      Uri.parse('$vocabularyBaseUrl/lexicon'),
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Word.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return addWord(
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
        galaxy: galaxy,
        subtopic: subtopic,
        translation: translation,
        type: type,
      );
    } else {
      throw Exception('Ошибка добавления слова');
    }
  }
  
  // Запросить перевод
  Future<String> requestTranslation({
    required String word,
    required String sourceLang,
    required String targetLang,
  }) async {
    await loadTokens();

    final response = await http.post(
      Uri.parse('$vocabularyBaseUrl/translate'),
      headers: _headers,
      body: json.encode({
        'word': word,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['translations'] != null && data['translations'] is List) {
        final translations = data['translations'] as List;
        if (translations.isNotEmpty) {
          return translations[0].toString();
        }
      }
      return '';
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return requestTranslation(
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    } else {
      throw Exception('Ошибка перевода');
    }
  }

  // Удалить слово
  Future<void> deleteWord(int wordId) async {
    await loadTokens();

    final response = await http.delete(
      Uri.parse('$vocabularyBaseUrl/lexicon/$wordId'),
      headers: _headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return deleteWord(wordId);
    } else {
      throw Exception('Ошибка удаления слова');
    }
  }

  // 📱 [MOBILE APP] Получить статистику по подтемам
  Future<Map<String, Map<String, int>>> getSubtopicsStats(String galaxy) async {
    await loadTokens();

    final uri = Uri.parse('$vocabularyBaseUrl/lexicon/stats/subtopics')
        .replace(queryParameters: {'galaxy': galaxy});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<String, Map<String, int>> stats = {};
      
      for (var item in data) {
        stats[item['subtopic']] = {
          'totalWords': item['totalWords'] as int,
          'totalExpressions': item['totalExpressions'] as int,
          'total': item['total'] as int,
          'translatedWords': item['translatedWords'] as int? ?? 0,
          'untranslatedWords': item['untranslatedWords'] as int? ?? 0,
          'translatedExpressions': item['translatedExpressions'] as int? ?? 0,
          'untranslatedExpressions': item['untranslatedExpressions'] as int? ?? 0,
        };
      }
      
      return stats;
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return getSubtopicsStats(galaxy);
    } else {
      throw Exception('Ошибка получения статистики');
    }
  }

  // Распознать речь
  Future<String> recognizeSpeech(String audioPath) async {
    await loadTokens();
    
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$vocabularyBaseUrl/speech/recognize'),
      );
      
      // Добавляем заголовки с токеном
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['text'] ?? '';
      } else if (response.statusCode == 401) {
        await refreshAccessToken();
        return recognizeSpeech(audioPath);
      } else {
        throw Exception('Ошибка распознавания речи');
      }
    } catch (e) {
      print('Ошибка распознавания: $e');
      return '';
    }
  }
}



