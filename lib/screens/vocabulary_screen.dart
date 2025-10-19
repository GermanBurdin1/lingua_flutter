import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/voice_recorder.dart';
import '../widgets/cosmic_background.dart';
import '../models/word.dart';

class VocabularyScreen extends StatefulWidget {
  final String? galaxyName;
  final String? subtopicName;
  final String? mediaType; // Pour vocabulaire médias
  final String? mediaPlatform; // Pour vocabulaire médias

  const VocabularyScreen({
    super.key,
    this.galaxyName,
    this.subtopicName,
    this.mediaType,
    this.mediaPlatform,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  bool _isVoiceActive = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VocabularyProvider>().fetchWords(
        galaxy: widget.galaxyName,
        subtopic: widget.subtopicName,
      );
    });
  }

  void _handleWordRecorded(String word) async {
    // Открываем форму add_word с предзаполненным словом
    final result = await context.push<bool>(
      '/add-word',
      extra: {
        'word': word,
        'galaxy': widget.galaxyName,
        'subtopic': widget.subtopicName,
        'mediaType': widget.mediaType,
        'mediaPlatform': widget.mediaPlatform,
      },
    );

    // Если слово добавлено, обновляем список
    if (result == true && mounted) {
      context.read<VocabularyProvider>().fetchWords(
        galaxy: widget.galaxyName,
        subtopic: widget.subtopicName,
      );
    }
  }

  void _openAddWordForm() async {
    // Открываем форму add_word
    final result = await context.push<bool>(
      '/add-word',
      extra: {
        'galaxy': widget.galaxyName,
        'subtopic': widget.subtopicName,
        'mediaType': widget.mediaType,
        'mediaPlatform': widget.mediaPlatform,
      },
    );

    // Если слово добавлено, обновляем список
    if (result == true && mounted) {
      context.read<VocabularyProvider>().fetchWords(
        galaxy: widget.galaxyName,
        subtopic: widget.subtopicName,
      );
    }
  }

  void _showWordDetailsModal(Word word) {
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.book,
                color: isDark ? const Color(0xFF00F5FF) : const Color(0xFF0066FF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  word.word,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF00F5FF) : const Color(0xFF0066FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (word.translation != null) ...[
                  Text(
                    'Traduction',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.translation!,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Text(
                    '⚠️ Pas de traduction',
                    style: TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (word.galaxy != null) ...[
                  Text(
                    'Galaxie',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    word.galaxy!,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (word.subtopic != null) ...[
                  Text(
                    'Sous-thème',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    word.subtopic!,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _editWord(word);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Modifier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF00F5FF) : const Color(0xFF0066FF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _editWord(Word word) async {
    // Открываем форму редактирования с предзаполненными данными
    final result = await context.push<bool>(
      '/add-word',
      extra: {
        'word': word.word,
        'translation': word.translation,
        'galaxy': word.galaxy ?? widget.galaxyName,
        'subtopic': word.subtopic ?? widget.subtopicName,
        'mediaType': word.mediaType ?? widget.mediaType,
        'mediaPlatform': word.mediaPlatform ?? widget.mediaPlatform,
        'wordId': word.id, // Передаем ID для редактирования
      },
    );

    // Если изменения сохранены, обновляем список
    if (result == true && mounted) {
      context.read<VocabularyProvider>().fetchWords(
        galaxy: widget.galaxyName,
        subtopic: widget.subtopicName,
      );
    }
  }

  void _deleteWord(Word word) async {
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                'Confirmer',
                style: TextStyle(
                  color: isDark ? const Color(0xFFFF6B9D) : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Voulez-vous vraiment supprimer le mot "${word.word}" ?',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<VocabularyProvider>().deleteWord(word.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Mot supprimé!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.subtopicName != null
              ? widget.subtopicName!.toUpperCase()
              : 'VOCABULAIRE',
        ),
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: SafeArea(
          child: Column(
            children: [
              VoiceRecorder(
                isActive: _isVoiceActive,
                onToggle: () {
                  setState(() {
                    _isVoiceActive = !_isVoiceActive;
                  });
                },
                onWordRecorded: _handleWordRecorded,
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.isDarkMode
                          ? [const Color(0xFF00F5FF), const Color(0xFF00C2FF)]
                          : [const Color(0xFF0066FF), const Color(0xFF0080FF)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _openAddWordForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un mot manuellement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: Consumer<VocabularyProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur: ${provider.error}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.words.isEmpty) {
                      return const Center(
                        child: Text(
                          'Vocabulaire vide',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.fetchWords(),
                      child: ListView.builder(
                        itemCount: provider.words.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final word = provider.words[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: themeProvider.isDarkMode
                                    ? [
                                        const Color(0xFF1A1F3A).withOpacity(0.7),
                                        const Color(0xFF1A1F3A).withOpacity(0.5),
                                      ]
                                    : [Colors.white, Colors.white],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                word.word,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: word.translation != null
                                  ? Text(word.translation!)
                                  : Text(
                                      'Pas de traduction',
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.orange.withOpacity(0.7)
                                            : Colors.orange,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editWord(word),
                                    tooltip: 'Modifier',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _deleteWord(word),
                                    tooltip: 'Supprimer',
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              onTap: () => _showWordDetailsModal(word),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
