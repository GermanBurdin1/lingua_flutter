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
  final String? mediaContentTitle; // Pour contenu spécifique (Dexter, Inception...)

  const VocabularyScreen({
    super.key,
    this.galaxyName,
    this.subtopicName,
    this.mediaType,
    this.mediaPlatform,
    this.mediaContentTitle,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  bool _isVoiceActive = false;
  String? _selectedSourceLang;
  String? _selectedTargetLang;
  
  // Фильтры для слов внутри контента
  String? _selectedSubtopic;
  String? _selectedSortBy; // 'date', 'subtopic', 'word'
  
  // Функция для получения названия языка
  String _getLangName(String? langCode) {
    switch (langCode) {
      case 'fr':
        return '🇫🇷 Français';
      case 'ru':
        return '🇷🇺 Русский';
      case 'en':
        return '🇬🇧 English';
      default:
        return langCode ?? 'Tous';
    }
  }
  
  // Получить уникальные подтемы из слов
  List<String> _getUniqueSubtopics(List<Word> words) {
    return words
        .where((word) => word.subtopic != null && word.subtopic!.isNotEmpty)
        .map((word) => word.subtopic!)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchWords();
    });
  }
  
  Future<void> _fetchWords() async {
    await context.read<VocabularyProvider>().fetchWords(
      galaxy: widget.galaxyName,
      subtopic: _selectedSubtopic ?? widget.subtopicName,
      mediaType: widget.mediaType,
      mediaPlatform: widget.mediaPlatform,
      mediaContentTitle: widget.mediaContentTitle,
      sourceLang: _selectedSourceLang,
      targetLang: _selectedTargetLang,
    );
  }
  
  // Сортировка слов
  List<Word> _sortWords(List<Word> words) {
    final sorted = List<Word>.from(words);
    
    switch (_selectedSortBy) {
      case 'date':
        // Сортировка по дате (новые сначала) - используем порядок загрузки (новые в конце списка, поэтому реверсируем)
        return sorted.reversed.toList();
      case 'subtopic':
        // Слова с подтемами сначала, потом без подтем
        sorted.sort((a, b) {
          final aHasSubtopic = a.subtopic != null && a.subtopic!.isNotEmpty;
          final bHasSubtopic = b.subtopic != null && b.subtopic!.isNotEmpty;
          if (aHasSubtopic && !bHasSubtopic) return -1;
          if (!aHasSubtopic && bHasSubtopic) return 1;
          if (aHasSubtopic && bHasSubtopic) {
            return a.subtopic!.compareTo(b.subtopic!);
          }
          return 0;
        });
        break;
      case 'word':
      default:
        // Сортировка по слову (алфавитная)
        sorted.sort((a, b) => a.word.compareTo(b.word));
        break;
    }
    
    return sorted;
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
        'mediaContentTitle': widget.mediaContentTitle,
      },
    );

    // Если слово добавлено, обновляем список
    if (result == true && mounted) {
      _fetchWords();
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
        'mediaContentTitle': widget.mediaContentTitle,
      },
    );

    // Если слово добавлено, обновляем список
    if (result == true && mounted) {
      _fetchWords();
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
                // Отображение языков
                Row(
                  children: [
                    Text(
                      'Langues: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF00F5FF).withOpacity(0.2)
                            : const Color(0xFF0066FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF00F5FF).withOpacity(0.3)
                              : const Color(0xFF0066FF).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getLangName(word.sourceLang),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF00F5FF)
                                  : const Color(0xFF0066FF),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: isDark
                                ? const Color(0xFF00F5FF)
                                : const Color(0xFF0066FF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getLangName(word.targetLang),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF00F5FF)
                                  : const Color(0xFF0066FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                if (word.galaxy != null && word.galaxy!.isNotEmpty) ...[
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
                if (word.subtopic != null && word.subtopic!.isNotEmpty) ...[
                  Text(
                    'Sous-thème',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      // Переход к подтеме
                      context.push(
                        '/vocabulary/${Uri.encodeComponent(word.galaxy ?? '')}/'
                        '${Uri.encodeComponent(word.subtopic ?? '')}',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${word.galaxy} > ${word.subtopic}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Информация о медиа-контенте (если есть)
                if (word.mediaContentTitle != null && word.mediaContentTitle!.isNotEmpty) ...[
                  Text(
                    'Média',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      // Переход к списку контента
                      context.push(
                        '/media-content-words/${Uri.encodeComponent(word.mediaType ?? '')}/'
                        '${Uri.encodeComponent(word.mediaPlatform ?? '')}/'
                        '${Uri.encodeComponent(word.mediaContentTitle ?? '')}',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.movie,
                            size: 16,
                            color: Colors.purple[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.mediaContentTitle ?? '',
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (word.mediaPlatform != null && word.mediaPlatform!.isNotEmpty)
                                  Text(
                                    word.mediaPlatform ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.purple[700],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Уникальные поля для конкретного слова (не общие для контента)
                  // Сезон и серия (для series) - могут отличаться для разных слов
                  if (word.mediaType == 'series') ...[
                    if (word.season != null) ...[
                      _buildDetailRow(
                        icon: Icons.tv,
                        label: 'Saison',
                        value: word.season.toString(),
                        isDark: isDark,
                      ),
                    ],
                    if (word.episode != null) ...[
                      _buildDetailRow(
                        icon: Icons.video_library,
                        label: 'Épisode',
                        value: word.episode.toString(),
                        isDark: isDark,
                      ),
                    ],
                  ],
                  
                  // Временная метка - уникальна для каждого слова
                  if (word.timestamp != null && word.timestamp!.isNotEmpty) ...[
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'Minute:Seconde',
                      value: word.timestamp!,
                      isDark: isDark,
                    ),
                  ],
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
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFF00F5FF) : const Color(0xFF0066FF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        'mediaContentTitle': word.mediaContentTitle ?? widget.mediaContentTitle,
        'wordId': word.id, // Передаем ID для редактирования
      },
    );

    // Если изменения сохранены, обновляем список
    if (result == true && mounted) {
      _fetchWords();
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
          widget.mediaContentTitle != null
              ? widget.mediaContentTitle!.toUpperCase()
              : (widget.subtopicName != null
                  ? widget.subtopicName!.toUpperCase()
                  : 'VOCABULAIRE'),
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
              
              // Фильтры по языкам
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<String>(
                            value: _selectedSourceLang,
                            hint: const Text('De'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Toutes les langues'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'fr',
                                child: Text('🇫🇷 Français'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'ru',
                                child: Text('🇷🇺 Русский'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'en',
                                child: Text('🇬🇧 English'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSourceLang = value;
                              });
                              _fetchWords();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<String>(
                            value: _selectedTargetLang,
                            hint: const Text('Vers'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Toutes les langues'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'fr',
                                child: Text('🇫🇷 Français'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'ru',
                                child: Text('🇷🇺 Русский'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'en',
                                child: Text('🇬🇧 English'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTargetLang = value;
                              });
                              _fetchWords();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Фильтры для слов внутри контента (только если открыт конкретный контент)
              if (widget.mediaContentTitle != null)
                Consumer<VocabularyProvider>(
                  builder: (context, provider, child) {
                    final words = provider.words;
                    final uniqueSubtopics = _getUniqueSubtopics(words);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          // Фильтр по подтемам
                          if (uniqueSubtopics.isNotEmpty) ...[
                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: DropdownButton<String>(
                                    value: _selectedSubtopic,
                                    hint: const Text('Sous-thème'),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Toutes les sous-thèmes'),
                                      ),
                                      ...uniqueSubtopics.map((subtopic) => DropdownMenuItem<String>(
                                        value: subtopic,
                                        child: Text(subtopic),
                                      )),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSubtopic = value;
                                      });
                                      _fetchWords();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          
                          // Сортировка
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: DropdownButton<String>(
                                  value: _selectedSortBy,
                                  hint: const Text('Trier par'),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem<String>(
                                      value: 'date',
                                      child: Text('Date d\'ajout'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'subtopic',
                                      child: Text('Sous-thème'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'word',
                                      child: Text('Mot (A-Z)'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSortBy = value;
                                    });
                                    // Не нужно перезагружать слова, только сортировать
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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

                    final sortedWords = _sortWords(provider.words);
                    
                    return RefreshIndicator(
                      onRefresh: () => _fetchWords(),
                      child: ListView.builder(
                        itemCount: sortedWords.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final word = sortedWords[index];
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
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                word.word,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            // Пометка что слово из медиа (если есть mediaContentTitle)
                                            if (word.mediaContentTitle != null && 
                                                widget.galaxyName != null && 
                                                widget.subtopicName != null)
                                              GestureDetector(
                                                onTap: () {
                                                  // Переход к списку контента
                                                  context.push(
                                                    '/media-content-words/${Uri.encodeComponent(word.mediaType ?? '')}/'
                                                    '${Uri.encodeComponent(word.mediaPlatform ?? '')}/'
                                                    '${Uri.encodeComponent(word.mediaContentTitle ?? '')}',
                                                  );
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.purple.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: Colors.purple.withOpacity(0.5),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.movie,
                                                        size: 14,
                                                        color: Colors.purple[700],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        word.mediaContentTitle ?? '',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.purple[700],
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            // Пометка что слово связано с подтемой (если есть galaxy/subtopic и мы в режиме контента)
                                            if (word.galaxy != null && 
                                                word.subtopic != null &&
                                                widget.mediaContentTitle != null)
                                              GestureDetector(
                                                onTap: () {
                                                  // Переход к подтеме
                                                  context.push(
                                                    '/vocabulary/${Uri.encodeComponent(word.galaxy ?? '')}/'
                                                    '${Uri.encodeComponent(word.subtopic ?? '')}',
                                                  );
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: Colors.blue.withOpacity(0.5),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.category,
                                                        size: 14,
                                                        color: Colors.blue[700],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        word.subtopic ?? '',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.blue[700],
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        // Отображение языков
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: themeProvider.isDarkMode
                                                ? const Color(0xFF00F5FF).withOpacity(0.2)
                                                : const Color(0xFF0066FF).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: themeProvider.isDarkMode
                                                  ? const Color(0xFF00F5FF).withOpacity(0.3)
                                                  : const Color(0xFF0066FF).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _getLangName(word.sourceLang).split(' ')[0],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: themeProvider.isDarkMode
                                                      ? const Color(0xFF00F5FF)
                                                      : const Color(0xFF0066FF),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 12,
                                                color: themeProvider.isDarkMode
                                                    ? const Color(0xFF00F5FF)
                                                    : const Color(0xFF0066FF),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getLangName(word.targetLang).split(' ')[0],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: themeProvider.isDarkMode
                                                      ? const Color(0xFF00F5FF)
                                                      : const Color(0xFF0066FF),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: word.translation != null
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
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, size: 20),
                                    onPressed: () => _showWordDetailsModal(word),
                                    tooltip: 'Détails',
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
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
