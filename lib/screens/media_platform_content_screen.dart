import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/galaxy.dart';
import '../models/word.dart';
import '../providers/theme_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/cosmic_background.dart';

// 📱 [MOBILE APP ONLY] Объединённый экран для платформы с тогглером режимов
class MediaPlatformContentScreen extends StatefulWidget {
  final String mediaType;
  final String platformName;

  const MediaPlatformContentScreen({
    super.key,
    required this.mediaType,
    required this.platformName,
  });

  @override
  State<MediaPlatformContentScreen> createState() => _MediaPlatformContentScreenState();
}

class _MediaPlatformContentScreenState extends State<MediaPlatformContentScreen> {
  bool _isThemeMode = true; // true = Par Thème, false = Par Contenu
  List<String> _customThemes = []; // Пользовательские темы
  List<String> _contentList = []; // Список контента (фильмы/сериалы и т.д.)
  bool _isLoadingContent = false;
  List<Word> _allWordsForFilters = []; // Все слова для заполнения фильтров
  
  // Фильтры для контента
  String? _selectedGenre;
  int? _selectedYear;
  String? _selectedDirector;
  String? _selectedHost;
  String? _selectedAlbum;
  
  // Списки жанров
  static const List<String> _filmGenres = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary',
    'Drama', 'Fantasy', 'Horror', 'Musical', 'Mystery', 'Romance',
    'Sci-Fi', 'Thriller', 'War', 'Western',
  ];
  
  static const List<String> _seriesGenres = [
    'Action', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Fantasy',
    'Horror', 'Mystery', 'Romance', 'Sci-Fi', 'Thriller', 'Western',
    'Animation', 'Adventure', 'Historical', 'Legal',
  ];
  
  static const List<String> _musicGenres = [
    'Pop', 'Rock', 'Hip-Hop', 'Rap', 'Jazz', 'Classical', 'Electronic',
    'R&B', 'Country', 'Folk', 'Blues', 'Reggae', 'Metal', 'Indie',
    'Alternative', 'Latin',
  ];
  
  static const List<String> _podcastGenres = [
    'True Crime', 'Educational', 'Comedy', 'News', 'Technology', 'Business',
    'Health', 'History', 'Science', 'Politics', 'Entertainment', 'Sports',
    'Self-Improvement', 'Storytelling', 'Interview', 'Documentary',
  ];
  
  List<String> get _availableGenres {
    switch (widget.mediaType) {
      case 'films':
        return _filmGenres;
      case 'series':
        return _seriesGenres;
      case 'music':
        return _musicGenres;
      case 'podcasts':
        return _podcastGenres;
      default:
        return [];
    }
  }

  void _toggleMode() {
    setState(() {
      _isThemeMode = !_isThemeMode;
    });
    
    // При переключении на режим "par contenu" загружаем список контентов
    if (!_isThemeMode) {
      Future.microtask(() {
        _loadAllWordsForFilters();
        _loadContentList();
      });
    }
  }
  
  Future<void> _loadAllWordsForFilters() async {
    if (!mounted) return;
    
    try {
      // Загружаем все слова без фильтров для заполнения dropdown'ов фильтров
      await context.read<VocabularyProvider>().fetchWords(
        mediaType: widget.mediaType,
        mediaPlatform: widget.platformName,
      );
      
      if (mounted) {
        setState(() {
          _allWordsForFilters = context.read<VocabularyProvider>().words;
        });
      }
    } catch (e) {
      // Игнорируем ошибки, фильтры просто будут пустыми
    }
  }

  @override
  void initState() {
    super.initState();
    // Если режим "par contenu" уже выбран, загружаем данные
    // Иначе загрузится при переключении через _toggleMode
    if (!_isThemeMode) {
      Future.microtask(() {
        _loadAllWordsForFilters();
        _loadContentList();
      });
    }
  }

  void _addNew() {
    if (_isThemeMode) {
      _showAddThemeDialog();
    } else {
      // В режиме "par contenu" открываем форму добавления слова с дополнительными полями
      _openAddWordForm();
    }
  }
  
  void _openAddWordForm() async {
    final result = await context.push<bool>(
      '/add-word',
      extra: {
        'mediaType': widget.mediaType,
        'mediaPlatform': widget.platformName,
        // mediaContentTitle будет null, так как контент еще не выбран
        // Пользователь может выбрать контент или добавить новое слово для конкретного контента
      },
    );
    
    // Если слово добавлено, обновляем список контентов и фильтры
    if (result == true && mounted && !_isThemeMode) {
      _loadAllWordsForFilters();
      _loadContentList();
    }
  }
  
  Future<void> _loadContentList() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingContent = true;
    });
    
    try {
      // Загружаем все слова для данной платформы и типа медиа с фильтрами
      await context.read<VocabularyProvider>().fetchWords(
        mediaType: widget.mediaType,
        mediaPlatform: widget.platformName,
        genre: _selectedGenre,
        year: _selectedYear,
        director: _selectedDirector,
        host: _selectedHost,
        album: _selectedAlbum,
      );
      
      // Извлекаем уникальные названия контентов из загруженных слов
      // Используем Set для гарантии уникальности, нормализуем названия
      final words = context.read<VocabularyProvider>().words;
      final Set<String> uniqueContentsSet = {};
      
      print('📱 Загружено слов: ${words.length}');
      
      for (final word in words) {
        final title = word.mediaContentTitle?.trim();
        if (title != null && title.isNotEmpty) {
          print('📱 Найден контент: "$title" (до нормализации: "${word.mediaContentTitle}")');
          // Используем Set для автоматической уникальности
          final wasAdded = uniqueContentsSet.add(title);
          if (!wasAdded) {
            print('⚠️ Дубликат контента игнорирован: "$title"');
          }
        }
      }
      
      print('📱 Уникальных контентов: ${uniqueContentsSet.length}');
      
      // Преобразуем в список и сортируем
      final uniqueContents = uniqueContentsSet.toList()..sort();
      
      if (mounted) {
        setState(() {
          _contentList = uniqueContents;
          _isLoadingContent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingContent = false;
        });
      }
    }
  }
  
  // Получить уникальные значения из всех слов для фильтров
  List<String> _getUniqueValues(List<Word> words, String? Function(Word) getter) {
    return words
        .where((word) {
          final value = getter(word);
          return value != null && value.isNotEmpty;
        })
        .map((word) => getter(word)!)
        .toSet()
        .toList()
      ..sort();
  }
  
  List<int> _getUniqueYears(List<Word> words) {
    return words
        .where((word) => word.year != null)
        .map((word) => word.year!)
        .toSet()
        .toList()
      ..sort();
  }
  
  Future<void> _showContentDetails(BuildContext context, String contentTitle) async {
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    // Находим первое слово этого контента для получения общей информации
    final contentWords = _allWordsForFilters.where((word) =>
        word.mediaContentTitle?.trim() == contentTitle &&
        word.mediaType == widget.mediaType &&
        word.mediaPlatform == widget.platformName).toList();
    
    if (contentWords.isEmpty) {
      return; // Нет слов для отображения информации
    }
    
    // Берем первое слово для общей информации
    final firstWord = contentWords.first;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.movie,
                color: isDark ? const Color(0xFF00F5FF) : const Color(0xFF0066FF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  contentTitle,
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
                // Платформа
                if (firstWord.mediaPlatform != null && firstWord.mediaPlatform!.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.play_circle_outline,
                    label: 'Plateforme',
                    value: firstWord.mediaPlatform!,
                    isDark: isDark,
                  ),
                ],
                
                // Опциональные поля медиа-контента
                // Жанры
                if (firstWord.genres != null && firstWord.genres!.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.category,
                    label: 'Genres',
                    value: firstWord.genres!.join(', '),
                    isDark: isDark,
                  ),
                ],
                
                // Год
                if (firstWord.year != null) ...[
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Année',
                    value: firstWord.year.toString(),
                    isDark: isDark,
                  ),
                ],
                
                // Режиссер (для films/series)
                if (firstWord.director != null && firstWord.director!.isNotEmpty && 
                    (firstWord.mediaType == 'films' || firstWord.mediaType == 'series')) ...[
                  _buildDetailRow(
                    icon: Icons.person,
                    label: 'Réalisateur',
                    value: firstWord.director!,
                    isDark: isDark,
                  ),
                ],
                
                // Альбом (для music)
                if (firstWord.album != null && firstWord.album!.isNotEmpty && firstWord.mediaType == 'music') ...[
                  _buildDetailRow(
                    icon: Icons.album,
                    label: 'Album',
                    value: firstWord.album!,
                    isDark: isDark,
                  ),
                ],
                
                // Ведущий (для podcasts)
                if (firstWord.host != null && firstWord.host!.isNotEmpty && firstWord.mediaType == 'podcasts') ...[
                  _buildDetailRow(
                    icon: Icons.mic,
                    label: 'Animateur',
                    value: firstWord.host!,
                    isDark: isDark,
                  ),
                ],
                
                // Приглашенные (для podcasts)
                if (firstWord.guests != null && firstWord.guests!.isNotEmpty && firstWord.mediaType == 'podcasts') ...[
                  _buildDetailRow(
                    icon: Icons.people,
                    label: 'Invités',
                    value: firstWord.guests!,
                    isDark: isDark,
                  ),
                ],
                
                // Количество слов
                _buildDetailRow(
                  icon: Icons.book,
                  label: 'Nombre de mots',
                  value: '${contentWords.length} ${contentWords.length == 1 ? 'mot' : 'mots'}',
                  isDark: isDark,
                ),
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

  Future<void> _confirmDeleteContent(BuildContext context, String contentTitle, int wordsCount) async {
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
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red[400],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Supprimer le contenu',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Êtes-vous sûr de vouloir supprimer "$contentTitle" ?',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red[400], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tous les $wordsCount ${wordsCount == 1 ? 'mot ou expression' : 'mots et expressions'} associés seront également supprimés.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action est irréversible !',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
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
      await _deleteContent(contentTitle);
    }
  }
  
  Future<void> _deleteContent(String contentTitle) async {
    try {
      // Показываем индикатор загрузки
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Suppression en cours...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      
      final deletedCount = await context.read<VocabularyProvider>().deleteContent(
        mediaType: widget.mediaType,
        mediaPlatform: widget.platformName,
        mediaContentTitle: contentTitle,
      );
      
      // Обновляем список контентов и фильтров
      await _loadAllWordsForFilters();
      await _loadContentList();
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "$contentTitle" supprimé ($deletedCount ${deletedCount == 1 ? 'mot supprimé' : 'mots supprimés'})'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _showAddThemeDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un thème'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom du thème',
            hintText: 'Ex: Vocabulaire technique',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
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
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _customThemes.add(result);
      });
    }
  }

  Future<void> _showAddContentDialog() async {
    final controller = TextEditingController();
    String contentLabel = 'contenu';
    
    switch (widget.mediaType) {
      case 'films':
        contentLabel = 'film';
        break;
      case 'series':
        contentLabel = 'série';
        break;
      case 'music':
        contentLabel = 'chanson/album';
        break;
      case 'podcasts':
        contentLabel = 'podcast/épisode';
        break;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un $contentLabel'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Titre',
            hintText: 'Ex: ${_getExampleTitle()}',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
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
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _contentList.add(result);
      });
      // TODO: Сохранить в backend через API
    }
  }

  String _getExampleTitle() {
    switch (widget.mediaType) {
      case 'films':
        return 'Inception';
      case 'series':
        return 'Dexter';
      case 'music':
        return 'Bohemian Rhapsody';
      case 'podcasts':
        return 'Tech Talk Ep.1';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.platformName.toUpperCase()),
        actions: [
          // Кнопка добавления
          if (_isThemeMode)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: _addNew,
              tooltip: 'Ajouter un thème',
          ),
        ],
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: SafeArea(
          child: Column(
            children: [
              // Тогглер режимов
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isThemeMode) _toggleMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isThemeMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category,
                                  color: _isThemeMode
                                      ? Colors.white
                                      : (themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Par Thème',
                                  style: TextStyle(
                                    color: _isThemeMode
                                        ? Colors.white
                                        : (themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                                    fontWeight: _isThemeMode ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_isThemeMode) _toggleMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isThemeMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie_filter,
                                  color: !_isThemeMode
                                      ? Colors.white
                                      : (themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Par Contenu',
                                  style: TextStyle(
                                    color: !_isThemeMode
                                        ? Colors.white
                                        : (themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                                    fontWeight: !_isThemeMode ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Контент в зависимости от режима
              Expanded(
                child: _isThemeMode ? _buildThemeMode() : _buildContentMode(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeMode() {
    final allThemes = [...galaxiesData, ..._customThemes.map((name) => Galaxy(name: name, icon: '✨', subtopics: []))];
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: allThemes.length,
      itemBuilder: (context, index) {
        final theme = allThemes[index];
        final isCustom = index >= galaxiesData.length;
        
        return _ThemeCard(
          galaxy: theme,
          mediaType: widget.mediaType,
          platformName: widget.platformName,
          isCustom: isCustom,
        );
      },
    );
  }

  Widget _buildContentMode() {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      children: [
        // Кнопка добавления слова
        Padding(
          padding: const EdgeInsets.all(16.0),
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
              label: const Text('Ajouter un mot ou une expression par contenu'),
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
        
        // Фильтры для контента
        Builder(
          builder: (context) {
            // Используем все слова для фильтров (загружены без фильтров)
            final uniqueDirectors = _getUniqueValues(_allWordsForFilters, (w) => w.director);
            final uniqueHosts = _getUniqueValues(_allWordsForFilters, (w) => w.host);
            final uniqueAlbums = _getUniqueValues(_allWordsForFilters, (w) => w.album);
            final uniqueYears = _getUniqueYears(_allWordsForFilters);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtres de contenu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode 
                          ? Colors.white70 
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Фильтры для films/series
                  if (widget.mediaType == 'films' || widget.mediaType == 'series') ...[
                    // Жанр
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButton<String>(
                          value: _selectedGenre,
                          hint: const Text('Genre'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tous les genres'),
                            ),
                            ..._availableGenres.map((genre) => DropdownMenuItem<String>(
                              value: genre,
                              child: Text(genre),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGenre = value;
                            });
                            _loadContentList();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Год
                    if (uniqueYears.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            hint: const Text('Année'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Toutes les années'),
                              ),
                              ...uniqueYears.map((year) => DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                              _loadContentList();
                            },
                          ),
                        ),
                      ),
                    
                    if (uniqueYears.isNotEmpty) const SizedBox(height: 8),
                    
                    // Режиссер (только для films)
                    if (widget.mediaType == 'films' && uniqueDirectors.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<String>(
                            value: _selectedDirector,
                            hint: const Text('Réalisateur'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Tous les réalisateurs'),
                              ),
                              ...uniqueDirectors.map((director) => DropdownMenuItem<String>(
                                value: director,
                                child: Text(director),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDirector = value;
                              });
                              _loadContentList();
                            },
                          ),
                        ),
                      ),
                  ],
                  
                  // Фильтры для music
                  if (widget.mediaType == 'music') ...[
                    // Жанр
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButton<String>(
                          value: _selectedGenre,
                          hint: const Text('Genre'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tous les genres'),
                            ),
                            ..._availableGenres.map((genre) => DropdownMenuItem<String>(
                              value: genre,
                              child: Text(genre),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGenre = value;
                            });
                            _loadContentList();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Год
                    if (uniqueYears.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            hint: const Text('Année'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Toutes les années'),
                              ),
                              ...uniqueYears.map((year) => DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                              _loadContentList();
                            },
                          ),
                        ),
                      ),
                    
                    if (uniqueYears.isNotEmpty) const SizedBox(height: 8),
                    
                    // Альбом
                    if (uniqueAlbums.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<String>(
                            value: _selectedAlbum,
                            hint: const Text('Album'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Tous les albums'),
                              ),
                              ...uniqueAlbums.map((album) => DropdownMenuItem<String>(
                                value: album,
                                child: Text(album),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedAlbum = value;
                              });
                              _loadContentList();
                            },
                          ),
                        ),
                      ),
                  ],
                  
                  // Фильтры для podcasts
                  if (widget.mediaType == 'podcasts') ...[
                    // Жанр
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButton<String>(
                          value: _selectedGenre,
                          hint: const Text('Genre'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tous les genres'),
                            ),
                            ..._availableGenres.map((genre) => DropdownMenuItem<String>(
                              value: genre,
                              child: Text(genre),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGenre = value;
                            });
                            _loadContentList();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Ведущий
                    if (uniqueHosts.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<String>(
                            value: _selectedHost,
                            hint: const Text('Animateur'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Tous les animateurs'),
                              ),
                              ...uniqueHosts.map((host) => DropdownMenuItem<String>(
                                value: host,
                                child: Text(host),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedHost = value;
                              });
                              _loadContentList();
                            },
                          ),
                        ),
                      ),
                  ],
                  
                  // Кнопка очистки фильтров
                  if (_selectedGenre != null || 
                      _selectedYear != null || 
                      _selectedDirector != null || 
                      _selectedHost != null || 
                      _selectedAlbum != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedGenre = null;
                            _selectedYear = null;
                            _selectedDirector = null;
                            _selectedHost = null;
                            _selectedAlbum = null;
                          });
                          _loadContentList();
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Effacer les filtres'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        
        // Список контента или пустое состояние
        Expanded(
          child: _isLoadingContent
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _contentList.isEmpty
                  ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun contenu ajouté',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
                        ],
                      ),
                    )
                  : Builder(
                      builder: (context) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _contentList.length,
                          itemBuilder: (context, index) {
                            final content = _contentList[index];
                            // Считаем количество слов для этого контента из всех загруженных слов
                            final wordsCount = _allWordsForFilters.where((word) =>
                                word.mediaContentTitle?.trim() == content &&
                                word.mediaType == widget.mediaType &&
                                word.mediaPlatform == widget.platformName).length;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(Icons.movie, size: 32),
                                title: Text(content, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: wordsCount > 0 
                                    ? Text('$wordsCount ${wordsCount == 1 ? 'mot' : 'mots'}')
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (wordsCount > 0) ...[
                                      IconButton(
                                        icon: const Icon(Icons.info_outline, size: 20),
                                        color: Theme.of(context).colorScheme.primary,
                                        onPressed: () => _showContentDetails(context, content),
                                        tooltip: 'Détails',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        color: Colors.red,
                                        onPressed: () => _confirmDeleteContent(context, content, wordsCount),
                                        tooltip: 'Supprimer le contenu',
                                      ),
                                    ],
                                    const Icon(Icons.arrow_forward_ios, size: 16),
                                  ],
                                ),
                                onTap: () {
                                  // Navigate to vocabulary screen for this content
                                  context.push(
                                    '/media-content-words/${Uri.encodeComponent(widget.mediaType)}/'
                                    '${Uri.encodeComponent(widget.platformName)}/'
                                    '${Uri.encodeComponent(content)}',
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final Galaxy galaxy;
  final String mediaType;
  final String platformName;
  final bool isCustom;

  const _ThemeCard({
    required this.galaxy,
    required this.mediaType,
    required this.platformName,
    required this.isCustom,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.isDarkMode
              ? [
                  const Color(0xFF1A1F3A).withOpacity(0.7),
                  const Color(0xFF1A1F3A).withOpacity(0.5),
                ]
              : [Colors.white, Colors.white.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(15),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(
              '/media-vocabulary/${Uri.encodeComponent(mediaType)}/'
              '${Uri.encodeComponent(platformName)}/'
              '${Uri.encodeComponent(galaxy.name)}',
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  galaxy.icon,
                  style: const TextStyle(fontSize: 50),
                ),
                const SizedBox(height: 12),
                Text(
                  galaxy.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCustom)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Perso',
                      style: TextStyle(fontSize: 10, color: Colors.green),
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

