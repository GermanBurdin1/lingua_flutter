import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/cosmic_background.dart';
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
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _audioPath;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isVoiceActive) {
      // Остановить запись
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isVoiceActive = false;
          _audioPath = path;
        });
        // Распознать речь
        final word = await context.read<VocabularyProvider>().recognizeSpeech(path);
        if (word.isNotEmpty) {
          _openAddWordForm(initialWord: word);
        } else {
          _openAddWordForm();
        }
      }
    } else {
      // Начать запись
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isVoiceActive = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission microphone refusée')),
          );
        }
      }
    }
  }
  
  void _openAddWordForm({String? initialWord}) {
    context.push('/add-word', extra: {
      'word': initialWord,
      'galaxy': _selectedGalaxy,
      'subtopic': _selectedSubtopic,
    });
  }

  /* Старые методы больше не используются
  void _handleWordRecorded(String word) async {
    if (word.isEmpty) {
      _openAddWordForm();
      return;
    }
    _openAddWordForm(initialWord: word);
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
  } */

  /* Старый метод больше не используется
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
  } */

  @override
  Widget build(BuildContext context) {
    print('🏠 [MainScreen] Building MainScreen widget');
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;
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
            // Voice Recorder and Add Word Button Section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Voice Recorder (compact)
                    Container(
                      width: 200, // Маленькая ширина
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark 
                            ? const Color(0xFF00F5FF).withOpacity(0.3)
                            : Colors.blueAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _toggleVoiceRecording,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mic,
                              color: _isVoiceActive 
                                  ? (isDark ? const Color(0xFF00FF88) : Colors.green)
                                  : (isDark ? Colors.white70 : Colors.black54),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isVoiceActive ? 'Enregistr...' : 'Commande vocale',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Add Word Button
                  ElevatedButton.icon(
                    onPressed: _openAddWordForm,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Ajouter un mot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark 
                          ? const Color(0xFF00F5FF) 
                          : const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
                ),
              ),
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
                        icon: Icons.movie,
                        label: 'Médias',
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [const Color(0xFFFF6B9D), const Color(0xFFFF3D71)]
                              : [const Color(0xFFFF1744), const Color(0xFFFF5252)],
                        ),
                        onTap: () {
                          context.push('/media-galaxies');
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
