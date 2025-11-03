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
  // Контроллеры для дополнительных полей медиа-контента
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();
  final _directorController = TextEditingController();
  final _hostController = TextEditingController();
  final _guestsController = TextEditingController();
  final _albumController = TextEditingController();
  final _contentTitleController = TextEditingController(); // Для ввода названия контента

  String _selectedType = 'word'; // 'word' or 'expression'
  String? _selectedGalaxy;
  String? _selectedSubtopic;
  String _sourceLang = 'fr';
  String _targetLang = 'ru';
  bool _isLoading = false;
  bool _isManualTranslation = false;
  bool _hasContentTitle = false; // Для динамического показа дополнительных полей
  
  // Списки жанров для каждого типа медиа
  static const List<String> _filmGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Fantasy',
    'Horror',
    'Musical',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western',
  ];
  
  static const List<String> _seriesGenres = [
    'Action',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Western',
    'Animation',
    'Adventure',
    'Historical',
    'Legal',
  ];
  
  static const List<String> _musicGenres = [
    'Pop',
    'Rock',
    'Hip-Hop',
    'Rap',
    'Jazz',
    'Classical',
    'Electronic',
    'R&B',
    'Country',
    'Folk',
    'Blues',
    'Reggae',
    'Metal',
    'Indie',
    'Alternative',
    'Latin',
  ];
  
  static const List<String> _podcastGenres = [
    'True Crime',
    'Educational',
    'Comedy',
    'News',
    'Technology',
    'Business',
    'Health',
    'History',
    'Science',
    'Politics',
    'Entertainment',
    'Sports',
    'Self-Improvement',
    'Storytelling',
    'Interview',
    'Documentary',
  ];
  
  List<String> _availableGenres = [];
  String? _selectedGenre;

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
    
    // Инициализируем список жанров в зависимости от типа медиа
    _updateGenreList();
  }
  
  void _updateGenreList() {
    switch (widget.mediaType) {
      case 'films':
        _availableGenres = List.from(_filmGenres);
        break;
      case 'series':
        _availableGenres = List.from(_seriesGenres);
        break;
      case 'music':
        _availableGenres = List.from(_musicGenres);
        break;
      case 'podcasts':
        _availableGenres = List.from(_podcastGenres);
        break;
      default:
        _availableGenres = [];
    }
  }
  
  Future<void> _addCustomGenre() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = context.watch<ThemeProvider>();
        final isDark = themeProvider.isDarkMode;
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          title: Text(
            'Ajouter un genre',
            style: TextStyle(
              color: isDark ? const Color(0xFF00F5FF) : const Color(0xFF0066FF),
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nom du genre',
              hintText: 'Ex: Nouveau genre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
    
    if (result != null && mounted && result.trim().isNotEmpty) {
      setState(() {
        _availableGenres.add(result.trim());
        _selectedGenre = result.trim();
      });
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _seasonController.dispose();
    _episodeController.dispose();
    _timestampController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _directorController.dispose();
    _hostController.dispose();
    _guestsController.dispose();
    _albumController.dispose();
    _contentTitleController.dispose();
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
  
  String _getContentTitleLabel() {
    switch (widget.mediaType) {
      case 'films':
        return 'Titre du film';
      case 'series':
        return 'Titre de la série';
      case 'music':
        return 'Titre de la chanson/album';
      case 'podcasts':
        return 'Titre du podcast/épisode';
      default:
        return 'Titre du contenu';
    }
  }
  
  String _getContentTitleHint() {
    switch (widget.mediaType) {
      case 'films':
        return 'Ex: Inception';
      case 'series':
        return 'Ex: Dexter';
      case 'music':
        return 'Ex: Bohemian Rhapsody';
      case 'podcasts':
        return 'Ex: Tech Talk Ep.1';
      default:
        return 'Ex: ...';
    }
  }

  Future<void> _requestAutoTranslation() async {
    if (_wordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un mot')),
      );
      return;
    }

    if (!mounted) return;
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

    // Проверяем galaxy/subtopic только если НЕ медиа-контент И НЕ режим "par contenu"
    // В режиме "par contenu" galaxy/subtopic опциональны
    if (widget.mediaContentTitle == null && 
        widget.initialGalaxy != null && 
        widget.initialSubtopic != null) {
      // Это режим "par thème" - galaxy/subtopic обязательны
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

    if (!mounted) return;
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
              mediaContentTitle: widget.mediaContentTitle ?? (_contentTitleController.text.trim().isNotEmpty ? _contentTitleController.text.trim() : null),
              season: _seasonController.text.trim().isNotEmpty
                  ? int.tryParse(_seasonController.text.trim())
                  : null,
              episode: _episodeController.text.trim().isNotEmpty
                  ? int.tryParse(_episodeController.text.trim())
                  : null,
              timestamp: _timestampController.text.trim().isNotEmpty
                  ? _timestampController.text.trim()
                  : null,
              genre: _selectedGenre != null && _selectedGenre!.isNotEmpty
                  ? _selectedGenre
                  : (_genreController.text.trim().isNotEmpty ? _genreController.text.trim() : null),
              year: _yearController.text.trim().isNotEmpty
                  ? int.tryParse(_yearController.text.trim())
                  : null,
              director: _directorController.text.trim().isNotEmpty
                  ? _directorController.text.trim()
                  : null,
              host: _hostController.text.trim().isNotEmpty
                  ? _hostController.text.trim()
                  : null,
              guests: _guestsController.text.trim().isNotEmpty
                  ? _guestsController.text.trim()
                  : null,
              album: _albumController.text.trim().isNotEmpty
                  ? _albumController.text.trim()
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
              mediaContentTitle: widget.mediaContentTitle ?? (_contentTitleController.text.trim().isNotEmpty ? _contentTitleController.text.trim() : null),
              season: _seasonController.text.trim().isNotEmpty
                  ? int.tryParse(_seasonController.text.trim())
                  : null,
              episode: _episodeController.text.trim().isNotEmpty
                  ? int.tryParse(_episodeController.text.trim())
                  : null,
              timestamp: _timestampController.text.trim().isNotEmpty
                  ? _timestampController.text.trim()
                  : null,
              genre: _selectedGenre != null && _selectedGenre!.isNotEmpty
                  ? _selectedGenre
                  : (_genreController.text.trim().isNotEmpty ? _genreController.text.trim() : null),
              year: _yearController.text.trim().isNotEmpty
                  ? int.tryParse(_yearController.text.trim())
                  : null,
              director: _directorController.text.trim().isNotEmpty
                  ? _directorController.text.trim()
                  : null,
              host: _hostController.text.trim().isNotEmpty
                  ? _hostController.text.trim()
                  : null,
              guests: _guestsController.text.trim().isNotEmpty
                  ? _guestsController.text.trim()
                  : null,
              album: _albumController.text.trim().isNotEmpty
                  ? _albumController.text.trim()
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
                              if (!mounted) return;
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

                  // Поле для названия контента (если mediaType есть, но mediaContentTitle нет)
                  if (widget.mediaType != null && widget.mediaContentTitle == null && widget.wordId == null) ...[
                    TextFormField(
                      controller: _contentTitleController,
                      decoration: InputDecoration(
                        labelText: _getContentTitleLabel(),
                        hintText: _getContentTitleHint(),
                        prefixIcon: const Icon(Icons.movie),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer le titre du contenu';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          _hasContentTitle = value.trim().isNotEmpty;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

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
                      if (!mounted) return;
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
                            if (value != null && mounted) {
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
                            if (value != null && mounted) {
                              setState(() => _targetLang = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Для сериалов: сезон и серия (главные поля для всех серий)
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
                  
                  // Временные метки (опционально, только для медиа-контента)
                  if (widget.mediaContentTitle != null) ...[
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
                  
                  // Дополнительные поля для режима "par contenu" (только при добавлении нового слова)
                  // Показываем если mediaContentTitle передан ИЛИ если введен в поле contentTitle
                  if (widget.mediaType != null && widget.wordId == null && 
                      (widget.mediaContentTitle != null || _hasContentTitle)) ...[
                    // Дополнительные поля в зависимости от типа медиа
                    // Для films и series: жанр (выпадающий список), год, режиссер
                    if (widget.mediaType == 'films' || widget.mediaType == 'series') ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGenre,
                              decoration: InputDecoration(
                                labelText: 'Genre (optionnel)',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: [
                                ..._availableGenres.map((genre) => DropdownMenuItem(
                                  value: genre,
                                  child: Text(genre),
                                )),
                                const DropdownMenuItem(
                                  value: '__custom__',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, size: 18),
                                      SizedBox(width: 8),
                                      Text('Ajouter un genre...'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (!mounted) return;
                                if (value == '__custom__') {
                                  _addCustomGenre();
                                } else {
                                  setState(() {
                                    _selectedGenre = value;
                                    if (value != null) {
                                      _genreController.text = value;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              decoration: InputDecoration(
                                labelText: 'Année (optionnel)',
                                hintText: '2023',
                                prefixIcon: const Icon(Icons.calendar_today),
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
                              controller: _directorController,
                              decoration: InputDecoration(
                                labelText: 'Réalisateur (optionnel)',
                                hintText: 'Christopher Nolan',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Для podcasts: жанр (выпадающий список), ведущий, приглашенные
                    if (widget.mediaType == 'podcasts') ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGenre,
                              decoration: InputDecoration(
                                labelText: 'Genre (optionnel)',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: [
                                ..._availableGenres.map((genre) => DropdownMenuItem(
                                  value: genre,
                                  child: Text(genre),
                                )),
                                const DropdownMenuItem(
                                  value: '__custom__',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, size: 18),
                                      SizedBox(width: 8),
                                      Text('Ajouter un genre...'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (!mounted) return;
                                if (value == '__custom__') {
                                  _addCustomGenre();
                                } else {
                                  setState(() {
                                    _selectedGenre = value;
                                    if (value != null) {
                                      _genreController.text = value;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hostController,
                        decoration: InputDecoration(
                          labelText: 'Animateur (optionnel)',
                          hintText: 'Nom de l\'animateur',
                          prefixIcon: const Icon(Icons.mic),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _guestsController,
                        decoration: InputDecoration(
                          labelText: 'Invités (optionnel)',
                          hintText: 'Noms des invités (séparés par des virgules)',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: 'Année (optionnel)',
                          hintText: '2023',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Для music: жанр (выпадающий список), альбом, год
                    if (widget.mediaType == 'music') ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGenre,
                              decoration: InputDecoration(
                                labelText: 'Genre (optionnel)',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: [
                                ..._availableGenres.map((genre) => DropdownMenuItem(
                                  value: genre,
                                  child: Text(genre),
                                )),
                                const DropdownMenuItem(
                                  value: '__custom__',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, size: 18),
                                      SizedBox(width: 8),
                                      Text('Ajouter un genre...'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (!mounted) return;
                                if (value == '__custom__') {
                                  _addCustomGenre();
                                } else {
                                  setState(() {
                                    _selectedGenre = value;
                                    if (value != null) {
                                      _genreController.text = value;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _albumController,
                        decoration: InputDecoration(
                          labelText: 'Album (optionnel)',
                          hintText: 'Nom de l\'album',
                          prefixIcon: const Icon(Icons.album),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: 'Année (optionnel)',
                          hintText: '2023',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Galaxy и Subtopic selector
                  // Показываем если:
                  // 1. Это режим "par thème" (есть initialGalaxy/initialSubtopic в widget) - обязательные поля
                  // 2. Это режим "par contenu" (есть mediaType) - опциональные поля для связи контента с темой
                  // Показываем для всех типов медиа (films, series, music, podcasts)
                  if ((widget.initialGalaxy != null && widget.initialSubtopic != null) || 
                      (widget.mediaType != null)) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedGalaxy,
                      decoration: InputDecoration(
                        labelText: widget.initialGalaxy != null && widget.initialSubtopic != null 
                            ? 'Galaxie' 
                            : 'Galaxie (optionnel - pour lier à un thème)',
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
                        if (!mounted) return;
                        setState(() {
                          _selectedGalaxy = value;
                          _selectedSubtopic = null; // Reset subtopic
                        });
                      },
                      validator: (value) {
                        // Galaxy обязательна только в режиме "par thème"
                        if (value == null && widget.initialGalaxy != null && widget.initialSubtopic != null) {
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
                          labelText: widget.initialGalaxy != null && widget.initialSubtopic != null 
                              ? 'Sous-thème' 
                              : 'Sous-thème (optionnel)',
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
                          if (!mounted) return;
                          setState(() {
                            _selectedSubtopic = value;
                          });
                        },
                        validator: (value) {
                          // Subtopic обязательна только в режиме "par thème"
                          // В режиме "par contenu" это опционально
                          if (value == null && widget.initialGalaxy != null && widget.initialSubtopic != null) {
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

