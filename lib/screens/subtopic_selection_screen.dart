import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/galaxy.dart';
import '../providers/theme_provider.dart';
import '../widgets/cosmic_background.dart';

class SubtopicSelectionScreen extends StatelessWidget {
  final String galaxyName;

  const SubtopicSelectionScreen({
    super.key,
    required this.galaxyName,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final galaxy = galaxiesData.firstWhere(
      (g) => g.name == galaxyName,
      orElse: () => galaxiesData[0],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(galaxy.name.toUpperCase()),
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
                        Icons.public,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              galaxy.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choisissez un sous-thème',
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
                const SizedBox(height: 20),
                
                // Grille de sous-thèmes
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: galaxy.subtopics.length,
                    itemBuilder: (context, index) {
                      final subtopic = galaxy.subtopics[index];
                      return _SubtopicCard(
                        subtopic: subtopic,
                        galaxyName: galaxy.name,
                        isDark: themeProvider.isDarkMode,
                      );
                    },
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

class _SubtopicCard extends StatelessWidget {
  final Subtopic subtopic;
  final String galaxyName;
  final bool isDark;

  const _SubtopicCard({
    required this.subtopic,
    required this.galaxyName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1F3A).withOpacity(0.7),
                  const Color(0xFF1A1F3A).withOpacity(0.5),
                ]
              : [Colors.white, Colors.white.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/vocabulary/${Uri.encodeComponent(galaxyName)}/${Uri.encodeComponent(subtopic.name)}');
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  size: 50,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: [
                    Shadow(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  subtopic.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

