import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Проверка авторизации при запуске
  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.loadTokens();
      
      // Проверяем есть ли токен
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null) {
        // Пытаемся получить профиль
        _currentUser = await _apiService.getProfile();
        _isAuthenticated = true;
        _error = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _error = null; // Не показываем ошибку при первой проверке
      await _apiService.clearTokens();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Вход
  Future<void> login(String email, String password) async {
    print('🔐 [AuthProvider] Login started');
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('🔐 [AuthProvider] Calling apiService.login...');
      final authResponse = await _apiService.login(email, password);
      print('🔐 [AuthProvider] API login successful');
      
      _currentUser = authResponse.user;
      _isAuthenticated = true;
      _error = null;
      
      print('🔐 [AuthProvider] User set: ${_currentUser?.email}');
      print('🔐 [AuthProvider] isAuthenticated: $_isAuthenticated');
      
      notifyListeners();
      print('🔐 [AuthProvider] Listeners notified');
    } catch (e) {
      print('❌ [AuthProvider] Login error: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🔐 [AuthProvider] Login completed, isLoading: $_isLoading');
    }
  }
  
  // Регистрация
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final authResponse = await _apiService.register(
        email: email,
        password: password,
        name: name,
        surname: surname,
        roles: ['student'],
      );
      _currentUser = authResponse.user;
      _isAuthenticated = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Выход
  Future<void> logout() async {
    await _apiService.clearTokens();
    _isAuthenticated = false;
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
  
  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
