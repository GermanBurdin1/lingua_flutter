import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/galaxy.dart';
import '../providers/theme_provider.dart';
import '../widgets/cosmic_background.dart';
import '../services/api_service.dart';

class SubtopicSelectionScreen extends StatefulWidget {
  final String galaxyName;

  const SubtopicSelectionScreen({
    super.key,
    required this.galaxyName,
  });

  @override
  State<SubtopicSelectionScreen> createState() => _SubtopicSelectionScreenState();
}

class _SubtopicSelectionScreenState extends State<SubtopicSelectionScreen> {
  final ApiService _apiService = ApiService();
  Map<String, Map<String, int>> _stats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _apiService.getSubtopicsStats(widget.galaxyName);
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки статистики: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final galaxy = galaxiesData.firstWhere(
      (g) => g.name == widget.galaxyName,
      orElse: () => galaxiesData[0],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(galaxy.name.toUpperCase()),
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Titre
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.isDarkMode
                          ? [
                              const Color(0xFF1A1F3A).withOpacity(0.7),
                              const Color(0xFF1A1F3A).withOpacity(0.5),
                            ]
                          : [Colors.white, Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              galaxy.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choisissez un sous-thème',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Grille de sous-thèmes
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: galaxy.subtopics.length,
                    itemBuilder: (context, index) {
                      final subtopic = galaxy.subtopics[index];
                      final stats = _stats[subtopic.name];
                      return _SubtopicCard(
                        subtopic: subtopic,
                        galaxyName: galaxy.name,
                        isDark: themeProvider.isDarkMode,
                        totalWords: stats?['totalWords'] ?? 0,
                        totalExpressions: stats?['totalExpressions'] ?? 0,
                        translatedWords: stats?['translatedWords'] ?? 0,
                        untranslatedWords: stats?['untranslatedWords'] ?? 0,
                        translatedExpressions: stats?['translatedExpressions'] ?? 0,
                        untranslatedExpressions: stats?['untranslatedExpressions'] ?? 0,
                        isLoadingStats: _isLoadingStats,
                      );
                    },
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

class _SubtopicCard extends StatefulWidget {
  final Subtopic subtopic;
  final String galaxyName;
  final bool isDark;
  final int totalWords;
  final int totalExpressions;
  final int translatedWords;
  final int untranslatedWords;
  final int translatedExpressions;
  final int untranslatedExpressions;
  final bool isLoadingStats;

  const _SubtopicCard({
    required this.subtopic,
    required this.galaxyName,
    required this.isDark,
    required this.totalWords,
    required this.totalExpressions,
    required this.translatedWords,
    required this.untranslatedWords,
    required this.translatedExpressions,
    required this.untranslatedExpressions,
    required this.isLoadingStats,
  });

  @override
  State<_SubtopicCard> createState() => _SubtopicCardState();
}

class _SubtopicCardState extends State<_SubtopicCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.totalWords + widget.totalExpressions;
    final hasStats = totalCount > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
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
              context.push('/vocabulary/${Uri.encodeComponent(widget.galaxyName)}/${Uri.encodeComponent(widget.subtopic.name)}');
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Иконка подтемы
                  Text(
                    widget.subtopic.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 12),
                  
                  // Название подтемы
                  Text(
                    widget.subtopic.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Статистика (показывается всегда на мобильном, при hover на десктопе)
                  if (!widget.isLoadingStats && hasStats)
                    AnimatedOpacity(
                      opacity: _isHovered || MediaQuery.of(context).size.width < 600 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            if (widget.totalWords > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '📚 ${widget.totalWords}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: widget.isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  if (widget.translatedWords > 0 || widget.untranslatedWords > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '(✓${widget.translatedWords}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: widget.isDark ? const Color(0xFF00FF88) : Colors.green,
                                      ),
                                    ),
                                    if (widget.untranslatedWords > 0)
                                      Text(
                                        '/✗${widget.untranslatedWords})',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: widget.isDark ? Colors.orange : Colors.deepOrange,
                                        ),
                                      )
                                    else
                                      const Text(
                                        ')',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                  ],
                                ],
                              ),
                            if (widget.totalExpressions > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '💬 ${widget.totalExpressions}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: widget.isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  if (widget.translatedExpressions > 0 || widget.untranslatedExpressions > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '(✓${widget.translatedExpressions}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: widget.isDark ? const Color(0xFF00FF88) : Colors.green,
                                      ),
                                    ),
                                    if (widget.untranslatedExpressions > 0)
                                      Text(
                                        '/✗${widget.untranslatedExpressions})',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: widget.isDark ? Colors.orange : Colors.deepOrange,
                                        ),
                                      )
                                    else
                                      const Text(
                                        ')',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                  ],
                                ],
                              ),
                          ],
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

