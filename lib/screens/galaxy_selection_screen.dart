import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/galaxy.dart';
import '../providers/theme_provider.dart';
import '../widgets/cosmic_background.dart';

class GalaxySelectionScreen extends StatelessWidget {
  const GalaxySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('GALAXIES'),
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: galaxiesData.length,
              itemBuilder: (context, index) {
                final galaxy = galaxiesData[index];
                return _GalaxyCard(galaxy: galaxy, isDark: themeProvider.isDarkMode);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GalaxyCard extends StatelessWidget {
  final Galaxy galaxy;
  final bool isDark;

  const _GalaxyCard({
    required this.galaxy,
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
                  const Color(0xFF1A1F3A).withOpacity(0.8),
                  const Color(0xFF0A0E27).withOpacity(0.6),
                ]
              : [Colors.white, Colors.white.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/galaxy/${Uri.encodeComponent(galaxy.name)}');
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                  shadows: [
                    Shadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  galaxy.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    shadows: [
                      Shadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${galaxy.subtopics.length} sous-thèmes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
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

