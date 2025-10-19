import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/galaxy_selection_screen.dart';
import 'screens/subtopic_selection_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/word_detail_screen.dart';
import 'screens/add_word_screen.dart';
import 'screens/media_galaxy_selection_screen.dart';
import 'screens/media_platform_selection_screen.dart';
import 'screens/media_galaxy_themes_screen.dart';
import 'screens/media_subtopic_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Lang App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) {
          print('🏠 Building MainScreen...');
          return const MainScreen();
        },
      ),
      GoRoute(
        path: '/galaxies',
        builder: (context, state) => const GalaxySelectionScreen(),
      ),
      GoRoute(
        path: '/galaxy/:name',
        builder: (context, state) {
          final galaxyName = Uri.decodeComponent(state.pathParameters['name']!);
          return SubtopicSelectionScreen(galaxyName: galaxyName);
        },
      ),
      GoRoute(
        path: '/vocabulary/:galaxy/:subtopic',
        builder: (context, state) {
          final galaxy = Uri.decodeComponent(state.pathParameters['galaxy']!);
          final subtopic = Uri.decodeComponent(state.pathParameters['subtopic']!);
          return VocabularyScreen(
            galaxyName: galaxy,
            subtopicName: subtopic,
          );
        },
      ),
    GoRoute(
      path: '/word/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return WordDetailScreen(wordId: int.parse(id));
      },
    ),
      GoRoute(
        path: '/add-word',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AddWordScreen(
            initialWord: extra?['word'] as String?,
            initialTranslation: extra?['translation'] as String?,
            initialGalaxy: extra?['galaxy'] as String?,
            initialSubtopic: extra?['subtopic'] as String?,
            wordId: extra?['wordId'] as int?,
          );
        },
      ),
      // 📱 [MOBILE APP] Routes pour vocabulaire médias
      GoRoute(
        path: '/media-galaxies',
        builder: (context, state) => const MediaGalaxySelectionScreen(),
      ),
      GoRoute(
        path: '/media-platforms/:mediaType',
        builder: (context, state) {
          final mediaType = state.pathParameters['mediaType']!;
          return MediaPlatformSelectionScreen(mediaType: mediaType);
        },
      ),
      GoRoute(
        path: '/media-themes/:mediaType/:platform',
        builder: (context, state) {
          final mediaType = Uri.decodeComponent(state.pathParameters['mediaType']!);
          final platform = Uri.decodeComponent(state.pathParameters['platform']!);
          return MediaGalaxyThemesScreen(
            mediaType: mediaType,
            platformName: platform,
          );
        },
      ),
      GoRoute(
        path: '/media-vocabulary/:mediaType/:platform/:galaxy',
        builder: (context, state) {
          final mediaType = Uri.decodeComponent(state.pathParameters['mediaType']!);
          final platform = Uri.decodeComponent(state.pathParameters['platform']!);
          final galaxy = Uri.decodeComponent(state.pathParameters['galaxy']!);
          return MediaSubtopicSelectionScreen(
            mediaType: mediaType,
            platformName: platform,
            galaxyName: galaxy,
          );
        },
      ),
      GoRoute(
        path: '/media-words/:mediaType/:platform/:galaxy/:subtopic',
        builder: (context, state) {
          final mediaType = Uri.decodeComponent(state.pathParameters['mediaType']!);
          final platform = Uri.decodeComponent(state.pathParameters['platform']!);
          final galaxy = Uri.decodeComponent(state.pathParameters['galaxy']!);
          final subtopic = Uri.decodeComponent(state.pathParameters['subtopic']!);
          return VocabularyScreen(
            galaxyName: galaxy,
            subtopicName: subtopic,
            mediaType: mediaType,
            mediaPlatform: platform,
          );
        },
      ),
  ],
);

// Splash Screen для автоматической проверки авторизации
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      print('🔍 Checking auth...');
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuth();
      
      if (!mounted) return;
      
      setState(() {
        _isAuthenticated = authProvider.isAuthenticated;
        _isChecking = false;
      });
      
      print('✅ Auth check complete: $_isAuthenticated');
      
      // Навигация через небольшую задержку
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      
      if (_isAuthenticated) {
        print('🚀 Navigate to /main');
        context.go('/main');
      } else {
        print('🚀 Navigate to /login');
        context.go('/login');
      }
    } catch (e) {
      print('❌ Auth check error: $e');
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _isAuthenticated = false;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F5FF)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Lang App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00F5FF),
                  shadows: [
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 10.0,
                      color: Color(0xFF00F5FF),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isChecking ? 'Vérification...' : (_isAuthenticated ? 'Bienvenue!' : 'Redirection...'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF00FF88),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
