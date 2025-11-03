import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/galaxy.dart';
import '../providers/theme_provider.dart';
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

  void _toggleMode() {
    setState(() {
      _isThemeMode = !_isThemeMode;
    });
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
        
        // Список контента или пустое состояние
        Expanded(
          child: _contentList.isEmpty
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contentList.length,
                  itemBuilder: (context, index) {
                    final content = _contentList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.movie, size: 32),
                        title: Text(content, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

