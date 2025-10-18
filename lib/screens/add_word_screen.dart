import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/galaxy.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/cosmic_background.dart';

class AddWordScreen extends StatefulWidget {
  final String? initialWord;
  final String? initialGalaxy;
  final String? initialSubtopic;

  const AddWordScreen({
    super.key,
    this.initialWord,
    this.initialGalaxy,
    this.initialSubtopic,
  });

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();

  String _selectedType = 'word'; // 'word' or 'expression'
  String? _selectedGalaxy;
  String? _selectedSubtopic;
  String _sourceLang = 'fr';
  String _targetLang = 'ru';
  bool _isLoading = false;
  bool _isManualTranslation = false;

  @override
  void initState() {
    super.initState();
    _wordController.text = widget.initialWord ?? '';
    _selectedGalaxy = widget.initialGalaxy;
    _selectedSubtopic = widget.initialSubtopic;
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  List<Subtopic> _getSubtopics() {
    if (_selectedGalaxy == null) return [];
    final galaxy = galaxiesData.firstWhere(
      (g) => g.name == _selectedGalaxy,
      orElse: () => galaxiesData.first,
    );
    return galaxy.subtopics;
  }

  Future<void> _requestAutoTranslation() async {
    if (_wordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un mot')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vocabularyProvider = context.read<VocabularyProvider>();
      final translation = await vocabularyProvider.requestTranslation(
        word: _wordController.text.trim(),
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );

      if (mounted) {
        setState(() {
          _translationController.text = translation;
          _isManualTranslation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de traduction: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGalaxy == null || _selectedSubtopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une galaxie et un sous-thème')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<VocabularyProvider>().addWord(
            word: _wordController.text.trim(),
            sourceLang: _sourceLang,
            targetLang: _targetLang,
            galaxy: _selectedGalaxy,
            subtopic: _selectedSubtopic,
            translation: _translationController.text.trim().isNotEmpty
                ? _translationController.text.trim()
                : null,
            type: _selectedType, // 'word' or 'expression'
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Mot ajouté avec succès!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ajouter ${_selectedType == "word" ? "un mot" : "une expression"}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                shadows: isDark
                    ? [
                        const Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 10.0,
                          color: Color(0xFF00F5FF),
                        ),
                      ]
                    : [],
              ),
        ),
      ),
      body: CosmicBackground(
        isDark: isDark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type selector (Word/Expression)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'word',
                                label: Text('Mot'),
                                icon: Icon(Icons.text_fields),
                              ),
                              ButtonSegment(
                                value: 'expression',
                                label: Text('Expression'),
                                icon: Icon(Icons.chat_bubble_outline),
                              ),
                            ],
                            selected: {_selectedType},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _selectedType = newSelection.first;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Word input
                  TextFormField(
                    controller: _wordController,
                    decoration: InputDecoration(
                      labelText: _selectedType == 'word' ? 'Mot' : 'Expression',
                      hintText: _selectedType == 'word'
                          ? 'Entrer le mot'
                          : 'Entrer l\'expression',
                      prefixIcon: const Icon(Icons.edit),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ce champ est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Auto-translate button
                  if (!_isManualTranslation && _translationController.text.isEmpty)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _requestAutoTranslation,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.translate),
                      label: Text(_isLoading
                          ? 'Traduction...'
                          : 'Trouver la traduction automatiquement'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Translation input
                  TextFormField(
                    controller: _translationController,
                    decoration: InputDecoration(
                      labelText: 'Traduction',
                      hintText: 'Entrer la traduction manuellement',
                      prefixIcon: const Icon(Icons.language),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isManualTranslation = value.trim().isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Language selectors
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sourceLang,
                          decoration: InputDecoration(
                            labelText: 'Depuis',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
                            DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Russe')),
                            DropdownMenuItem(value: 'en', child: Text('🇬🇧 Anglais')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sourceLang = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _targetLang,
                          decoration: InputDecoration(
                            labelText: 'Vers',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
                            DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Russe')),
                            DropdownMenuItem(value: 'en', child: Text('🇬🇧 Anglais')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _targetLang = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Galaxy selector
                  DropdownButtonFormField<String>(
                    value: _selectedGalaxy,
                    decoration: InputDecoration(
                      labelText: 'Galaxie',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: galaxiesData.map((galaxy) {
                      return DropdownMenuItem(
                        value: galaxy.name,
                        child: Text('${galaxy.icon} ${galaxy.name}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGalaxy = value;
                        _selectedSubtopic = null; // Reset subtopic
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner une galaxie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subtopic selector
                  if (_selectedGalaxy != null)
                    DropdownButtonFormField<String>(
                      value: _selectedSubtopic,
                      decoration: InputDecoration(
                        labelText: 'Sous-thème',
                        prefixIcon: const Icon(Icons.label),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _getSubtopics().map((subtopic) {
                        return DropdownMenuItem(
                          value: subtopic.name,
                          child: Text('${subtopic.icon} ${subtopic.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubtopic = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un sous-thème';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Ajouter',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

