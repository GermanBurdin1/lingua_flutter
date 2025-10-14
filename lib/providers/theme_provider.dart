import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
  
  // Космическая темная тема
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0E27),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00F5FF), // Cyan néon
      secondary: Color(0xFFFF00FF), // Magenta néon
      tertiary: Color(0xFF00FF88), // Vert néon
      surface: Color(0xFF1A1F3A),
      background: Color(0xFF0A0E27),
      error: Color(0xFFFF6B9D),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1F3A).withOpacity(0.7),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF00F5FF).withOpacity(0.3),
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00F5FF),
        foregroundColor: const Color(0xFF0A0E27),
        elevation: 8,
        shadowColor: const Color(0xFF00F5FF).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1F3A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF00F5FF),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFF00F5FF), fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Color(0xFF00F5FF), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
  
  // Cosmique thème clair
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F4FF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0066FF), // Bleu cosmique
      secondary: Color(0xFF7C4DFF), // Violet
      tertiary: Color(0xFF00C853), // Vert
      surface: Colors.white,
      background: Color(0xFFF0F4FF),
      error: Color(0xFFFF1744),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF0066FF).withOpacity(0.2),
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0066FF),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0xFF0066FF).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF0066FF),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      iconTheme: IconThemeData(color: Color(0xFF0066FF)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFF1A1F3A)),
      bodyMedium: TextStyle(color: Color(0xFF4A5568)),
    ),
  );
}

