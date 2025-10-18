import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/voice_recorder.dart';
import '../models/galaxy.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isVoiceActive = false;
  String? _selectedGalaxy;
  String? _selectedSubtopic;

  void _handleWordRecorded(String word) async {
    if (word.isEmpty) {
      _showManualInputDialog();
      return;
    }

    // Показываем диалог выбора галактики/подтемы
    await _showGalaxySubtopicSelector(word);
  }

  Future<void> _showGalaxySubtopicSelector(String word) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? tempGalaxy = _selectedGalaxy;
        String? tempSubtopic = _selectedSubtopic;

        return StatefulBuilder(
          builder: (context, setState) {
            final galaxy = tempGalaxy != null
                ? galaxiesData.firstWhere((g) => g.name == tempGalaxy)
                : null;

            return AlertDialog(
              title: Text('Ajouter: "$word"'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempGalaxy,
                    decoration: const InputDecoration(
                      labelText: 'Galaxie',
                      border: OutlineInputBorder(),
                    ),
                    items: galaxiesData.map((g) {
                      return DropdownMenuItem(
                        value: g.name,
                        child: Text(g.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        tempGalaxy = value;
                        tempSubtopic = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (galaxy != null)
                    DropdownButtonFormField<String>(
                      value: tempSubtopic,
                      decoration: const InputDecoration(
                        labelText: 'Sous-thème',
                        border: OutlineInputBorder(),
                      ),
                      items: galaxy.subtopics.map((s) {
                        return DropdownMenuItem(
                          value: s.name,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          tempSubtopic = value;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: tempGalaxy != null && tempSubtopic != null
                      ? () async {
                          Navigator.pop(context);
                          try {
                            await context.read<VocabularyProvider>().addWord(
                                  word: word,
                                  sourceLang: 'fr',
                                  targetLang: 'ru',
                                  galaxy: tempGalaxy,
                                  subtopic: tempSubtopic,
                                );
                            if (mounted) {
                              _selectedGalaxy = tempGalaxy;
                              _selectedSubtopic = tempSubtopic;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Mot "$word" ajouté!')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Erreur: $e')),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManualInputDialog() {
    String? manualWord;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Saisie manuelle'),
          content: TextField(
            onChanged: (value) {
              manualWord = value;
            },
            decoration: const InputDecoration(hintText: 'Entrez le mot'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (manualWord != null && manualWord!.isNotEmpty) {
                  Navigator.pop(context);
                  await _showGalaxySubtopicSelector(manualWord!);
                }
              },
              child: const Text('Suivant'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 [MainScreen] Building MainScreen widget');
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    print('🏠 [MainScreen] Current user: ${authProvider.currentUser?.email}');
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('LANG APP'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: themeProvider.isDarkMode 
                ? 'Mode clair' 
                : 'Mode sombre',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: Column(
          children: [
            // Voice Recorder Section
            VoiceRecorder(
              isActive: _isVoiceActive,
              onToggle: () {
                setState(() {
                  _isVoiceActive = !_isVoiceActive;
                });
              },
              onWordRecorded: _handleWordRecorded,
            ),
            // Main Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.language,
                        size: 120,
                        color: Theme.of(context).colorScheme.primary,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Application\nd\'apprentissage des langues',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          shadows: [
                            Shadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      _MenuButton(
                        icon: Icons.book,
                        label: 'Vocabulaire',
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [const Color(0xFF00F5FF), const Color(0xFF00C2FF)]
                              : [const Color(0xFF0066FF), const Color(0xFF0080FF)],
                        ),
                        onTap: () => context.push('/galaxies'),
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        icon: Icons.translate,
                        label: 'Traductions',
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [const Color(0xFFFF00FF), const Color(0xFFFF00AA)]
                              : [const Color(0xFF7C4DFF), const Color(0xFF9C4DFF)],
                        ),
                        onTap: () {
                          // TODO: Navigate to translations
                        },
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        icon: Icons.school,
                        label: 'Grammaire',
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [const Color(0xFF00FF88), const Color(0xFF00DD77)]
                              : [const Color(0xFF00C853), const Color(0xFF00E676)],
                        ),
                        onTap: () {
                          // TODO: Navigate to grammar
                        },
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        icon: Icons.person,
                        label: 'Profil',
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [const Color(0xFFFF6B9D), const Color(0xFFFF8BA0)]
                              : [const Color(0xFFFF1744), const Color(0xFFFF5252)],
                        ),
                        onTap: () {
                          // TODO: Navigate to profile
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
