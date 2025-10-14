import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/voice_recorder.dart';
import '../widgets/cosmic_background.dart';

class VocabularyScreen extends StatefulWidget {
  final String? galaxyName;
  final String? subtopicName;

  const VocabularyScreen({
    super.key,
    this.galaxyName,
    this.subtopicName,
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
    if (word.isEmpty) {
      _showManualInputDialog();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reconnu'),
        content: Text('Mot: "$word"\n\nAjouter au vocabulaire?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              _showManualInputDialog(initialValue: word);
            },
            child: const Text('Modifier'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<VocabularyProvider>().addWord(
              word: word,
              sourceLang: 'fr',
              targetLang: 'ru',
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mot "$word" ajouté!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur d\'ajout du mot')),
          );
        }
      }
    }
  }

  void _showManualInputDialog({String? initialValue}) {
    final controller = TextEditingController(text: initialValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un mot'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Entrez le mot',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final word = controller.text.trim();
              if (word.isEmpty) return;
              
              Navigator.pop(context);
              
              try {
                await context.read<VocabularyProvider>().addWord(
                      word: word,
                      sourceLang: 'fr',
                      targetLang: 'ru',
                      galaxy: widget.galaxyName ?? '',
                      subtopic: widget.subtopicName ?? '',
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mot "$word" ajouté!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur d\'ajout du mot')),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
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
                    onPressed: _showManualInputDialog,
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
                                  : null,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.push('/word/${word.id}');
                              },
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
