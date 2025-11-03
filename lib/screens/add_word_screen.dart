import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/galaxy.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/cosmic_background.dart';

class AddWordScreen extends StatefulWidget {
  final String? initialWord;
  final String? initialTranslation;
  final String? initialGalaxy;
  final String? initialSubtopic;
  final String? mediaType;
  final String? mediaPlatform;
  final String? mediaContentTitle;
  final int? wordId; // ID для редактирования

  const AddWordScreen({
    super.key,
    this.initialWord,
    this.initialTranslation,
    this.initialGalaxy,
    this.initialSubtopic,
    this.mediaType,
    this.mediaPlatform,
    this.mediaContentTitle,
    this.wordId,
  });

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _seasonController = TextEditingController();
  final _episodeController = TextEditingController();
  final _timestampController = TextEditingController();

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
    print('🔍 AddWordScreen initState: wordId = ${widget.wordId}');
    print('🔍 AddWordScreen initState: initialWord = ${widget.initialWord}');
    print('🔍 AddWordScreen initState: initialTranslation = ${widget.initialTranslation}');
    _wordController.text = widget.initialWord ?? '';
    _translationController.text = widget.initialTranslation ?? '';
    if (widget.initialTranslation != null && widget.initialTranslation!.isNotEmpty) {
      _isManualTranslation = true;
    }
    _selectedGalaxy = widget.initialGalaxy;
    _selectedSubtopic = widget.initialSubtopic;
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _seasonController.dispose();
    _episodeController.dispose();
    _timestampController.dispose();
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

    // Проверяем galaxy/subtopic только если НЕ медиа-контент
    if (widget.mediaContentTitle == null) {
      if (_selectedGalaxy == null || _selectedSubtopic == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une galaxie et un sous-thème')),
        );
        return;
      }
    }

    // Проверка: если нет перевода, показываем предупреждение
    if (_translationController.text.trim().isEmpty) {
      final confirmed = await _showNoTranslationWarning();
      if (!confirmed) {
        return; // Пользователь отменил
      }
    }

    setState(() => _isLoading = true);

    // Отладка: проверяем wordId
    print('🔍 _saveWord: wordId = ${widget.wordId}');
    print('🔍 _saveWord: wordId type = ${widget.wordId.runtimeType}');

    try {
      // Если есть wordId, обновляем слово, иначе создаем новое
      if (widget.wordId != null) {
        print('🔍 Using updateWord for wordId: ${widget.wordId}');
        await context.read<VocabularyProvider>().updateWord(
              wordId: widget.wordId!,
              word: _wordController.text.trim(),
              sourceLang: _sourceLang,
              targetLang: _targetLang,
              galaxy: _selectedGalaxy,
              subtopic: _selectedSubtopic,
              translation: _translationController.text.trim().isNotEmpty
                  ? _translationController.text.trim()
                  : null,
              type: _selectedType, // 'word' or 'expression'
              mediaType: widget.mediaType,
              mediaPlatform: widget.mediaPlatform,
              mediaContentTitle: widget.mediaContentTitle,
              season: _seasonController.text.trim().isNotEmpty
                  ? int.tryParse(_seasonController.text.trim())
                  : null,
              episode: _episodeController.text.trim().isNotEmpty
                  ? int.tryParse(_episodeController.text.trim())
                  : null,
              timestamp: _timestampController.text.trim().isNotEmpty
                  ? _timestampController.text.trim()
                  : null,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Mot modifié avec succès!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        print('🔍 Using addWord (no wordId)');
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
              mediaType: widget.mediaType,
              mediaPlatform: widget.mediaPlatform,
              mediaContentTitle: widget.mediaContentTitle,
              season: _seasonController.text.trim().isNotEmpty
                  ? int.tryParse(_seasonController.text.trim())
                  : null,
              episode: _episodeController.text.trim().isNotEmpty
                  ? int.tryParse(_episodeController.text.trim())
                  : null,
              timestamp: _timestampController.text.trim().isNotEmpty
                  ? _timestampController.text.trim()
                  : null,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Mot ajouté avec succès!')),
          );
          Navigator.pop(context, true);
        }
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

  Future<bool> _showNoTranslationWarning() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = context.watch<ThemeProvider>();
        final isDark = themeProvider.isDarkMode;
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Attention',
                style: TextStyle(
                  color: isDark ? const Color(0xFF00F5FF) : const Color(0xFF0066FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Vous allez ajouter ce mot sans traduction.\n\nVous pourrez ajouter la traduction plus tard.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continuer sans traduction'),
            ),
          ],
        );
      },
    );
    return result ?? false;
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
            widget.wordId != null 
                ? 'Modifier ${_selectedType == "word" ? "le mot" : "l\'expression"}'
                : 'Ajouter ${_selectedType == "word" ? "un mot" : "une expression"}',
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

                  // Временные метки (опционально, только для медиа-контента)
                  if (widget.mediaContentTitle != null) ...[
                    // Для сериалов: сезон и серия
                    if (widget.mediaType == 'series') ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _seasonController,
                              decoration: InputDecoration(
                                labelText: 'Saison (optionnel)',
                                hintText: '1',
                                prefixIcon: const Icon(Icons.tv),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _episodeController,
                              decoration: InputDecoration(
                                labelText: 'Épisode (optionnel)',
                                hintText: '5',
                                prefixIcon: const Icon(Icons.video_library),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Для всех типов медиа: временная метка
                    TextFormField(
                      controller: _timestampController,
                      decoration: InputDecoration(
                        labelText: 'Minute:Seconde (optionnel)',
                        hintText: widget.mediaType == 'music' || widget.mediaType == 'podcasts'
                            ? '2:34'
                            : '12:34',
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Galaxy selector (только для контекста жизни, не для медиа)
                  if (widget.mediaContentTitle == null) ...[
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
                    const SizedBox(height: 16),
                  ],

                  // Информация о медиа-контенте (если это медиа)
                  if (widget.mediaContentTitle != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.movie, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Média',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Type: ${widget.mediaType}'),
                          Text('Plateforme: ${widget.mediaPlatform}'),
                          Text('Contenu: ${widget.mediaContentTitle}'),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Save/Update button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveWord,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(widget.wordId != null ? Icons.check : Icons.add),
                    label: Text(
                      widget.wordId != null ? 'Enregistrer' : 'Ajouter',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

