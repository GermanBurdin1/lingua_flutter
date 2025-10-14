import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/cosmic_background.dart';

class WordDetailScreen extends StatelessWidget {
  final int wordId;

  const WordDetailScreen({super.key, required this.wordId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VocabularyProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final word = provider.words.firstWhere(
      (w) => w.id == wordId,
      orElse: () => provider.words.first,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('DÉTAILS DU MOT'),
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mot',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          shadows: [
                            Shadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (word.translation != null) ...[
                        Text(
                          'Traduction',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          word.translation!,
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text('${word.sourceLang} → ${word.targetLang}'),
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ),
                          if (word.status != null)
                            Chip(
                              label: Text(_getStatusText(word.status!)),
                              backgroundColor: _getStatusColor(word.status!, themeProvider.isDarkMode),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (word.galaxy != null || word.subtopic != null)
                  Container(
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catégorie',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (word.galaxy != null)
                          Text(
                            'Galaxie: ${word.galaxy}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        if (word.subtopic != null)
                          Text(
                            'Sous-thème: ${word.subtopic}',
                            style: const TextStyle(fontSize: 16),
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

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'learned':
        return 'Appris';
      case 'learning':
        return 'En cours';
      case 'review':
        return 'À réviser';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'learned':
        return isDark ? const Color(0xFF00FF88).withOpacity(0.3) : Colors.green[100]!;
      case 'learning':
        return isDark ? const Color(0xFFFF00FF).withOpacity(0.3) : Colors.orange[100]!;
      case 'review':
        return isDark ? const Color(0xFFFF6B9D).withOpacity(0.3) : Colors.red[100]!;
      default:
        return isDark ? const Color(0xFF1A1F3A) : Colors.grey[200]!;
    }
  }
}
