import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/media_platform.dart';
import '../providers/theme_provider.dart';
import '../widgets/cosmic_background.dart';

// 📱 [MOBILE APP ONLY] Экран выбора режима классификации для платформы
class MediaClassificationModeScreen extends StatelessWidget {
  final String mediaType;
  final String platformName;

  const MediaClassificationModeScreen({
    super.key,
    required this.mediaType,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final mediaTypeObj = MediaGalaxyType.values.firstWhere((t) => t.value == mediaType);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('$platformName - ${mediaTypeObj.label}'),
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Titre
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.isDarkMode
                          ? [
                              const Color(0xFF1A1F3A).withOpacity(0.7),
                              const Color(0xFF1A1F3A).withOpacity(0.5),
                            ]
                          : [Colors.white, Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              platformName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Comment classer vos mots?',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Deux modes
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ClassificationModeCard(
                        title: 'Par Thème',
                        subtitle: 'Érudition, Relations, etc.',
                        description: 'Classer par thèmes → sous-thèmes',
                        icon: Icons.category,
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [const Color(0xFF00F5FF), const Color(0xFF00C2FF)]
                              : [const Color(0xFF0066FF), const Color(0xFF0080FF)],
                        ),
                        isDark: themeProvider.isDarkMode,
                        onTap: () {
                          context.push(
                            '/media-themes/${Uri.encodeComponent(mediaType)}/'
                            '${Uri.encodeComponent(platformName)}',
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _ClassificationModeCard(
                        title: 'Par Contenu',
                        subtitle: 'Films/Séries spécifiques',
                        description: 'Dexter, Inception, etc.',
                        icon: Icons.movie_filter,
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [const Color(0xFFFF6B9D), const Color(0xFFFF3D71)]
                              : [const Color(0xFFFF1744), const Color(0xFFFF5252)],
                        ),
                        isDark: themeProvider.isDarkMode,
                        onTap: () {
                          context.push(
                            '/media-content-list/${Uri.encodeComponent(mediaType)}/'
                            '${Uri.encodeComponent(platformName)}',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassificationModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final bool isDark;
  final VoidCallback onTap;

  const _ClassificationModeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

