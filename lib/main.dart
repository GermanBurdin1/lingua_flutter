import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'screens/galaxy_selection_screen.dart';
import 'screens/subtopic_selection_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/word_detail_screen.dart';

void main() {
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
  initialLocation: '/main',
  routes: [
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreen(),
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
  ],
);
