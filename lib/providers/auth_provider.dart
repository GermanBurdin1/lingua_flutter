import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
  
  void logout() {
    _token = null;
    notifyListeners();
  }
}



