import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../models/user.dart';

class ApiService {
  // Используем API Gateway для всех запросов
  static const String apiGatewayUrl = 'http://localhost:3011';
  static const String authBaseUrl = '$apiGatewayUrl/auth';
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
    
    final queryParams = <String, String>{};
    if (galaxy != null) queryParams['galaxy'] = galaxy;
    if (subtopic != null) queryParams['subtopic'] = subtopic;
    
    final uri = Uri.parse('$vocabularyBaseUrl/lexicon')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
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
  }) async {
    await loadTokens();
    
    final response = await http.post(
      Uri.parse('$vocabularyBaseUrl/lexicon'),
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
    } else if (response.statusCode == 401) {
      await refreshAccessToken();
      return addWord(
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
        galaxy: galaxy,
        subtopic: subtopic,
      );
    } else {
      throw Exception('Ошибка добавления слова');
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



