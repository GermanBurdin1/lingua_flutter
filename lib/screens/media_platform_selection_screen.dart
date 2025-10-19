import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/media_platform.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../widgets/cosmic_background.dart';

// 📱 [MOBILE APP ONLY] Экран выбора/добавления платформ
class MediaPlatformSelectionScreen extends StatefulWidget {
  final String mediaType;

  const MediaPlatformSelectionScreen({
    super.key,
    required this.mediaType,
  });

  @override
  State<MediaPlatformSelectionScreen> createState() => _MediaPlatformSelectionScreenState();
}

class _MediaPlatformSelectionScreenState extends State<MediaPlatformSelectionScreen> {
  final ApiService _apiService = ApiService();
  List<MediaPlatform> _platforms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlatforms();
  }

  Future<void> _loadPlatforms() async {
    try {
      final platforms = await _apiService.getMediaPlatformsByType(widget.mediaType);
      if (mounted) {
        setState(() {
          _platforms = platforms;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки платформ: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addPlatform() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AddPlatformDialog(mediaType: widget.mediaType),
    );

    if (result != null && mounted) {
      try {
        await _apiService.createMediaPlatform(
          mediaType: widget.mediaType,
          name: result['name']!,
          icon: result['icon'],
        );
        _loadPlatforms();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final mediaTypeObj = MediaGalaxyType.values.firstWhere((t) => t.value == widget.mediaType);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${mediaTypeObj.icon} ${mediaTypeObj.label}'),
      ),
      body: CosmicBackground(
        isDark: themeProvider.isDarkMode,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: _addPlatform,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une plateforme'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _platforms.isEmpty
                          ? Center(
                              child: Text(
                                'Aucune plateforme.\nAjoutez-en une!',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _platforms.length,
                              itemBuilder: (context, index) {
                                final platform = _platforms[index];
                                return Card(
                                  child: ListTile(
                                    leading: Text(
                                      platform.icon ?? '📱',
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                    title: Text(platform.name),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await _apiService.deleteMediaPlatform(platform.id);
                                        _loadPlatforms();
                                      },
                                    ),
                                    onTap: () {
                                      // Navigate to platform content screen with toggler
                                      context.push(
                                        '/platform-content/${Uri.encodeComponent(widget.mediaType)}/'
                                        '${Uri.encodeComponent(platform.name)}',
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

class _AddPlatformDialog extends StatefulWidget {
  final String mediaType;

  const _AddPlatformDialog({required this.mediaType});

  @override
  State<_AddPlatformDialog> createState() => _AddPlatformDialogState();
}

class _AddPlatformDialogState extends State<_AddPlatformDialog> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  
  bool _isCustomPlatform = false;
  PlatformSuggestion? _selectedPlatform;
  List<PlatformSuggestion> _popularPlatforms = [];

  @override
  void initState() {
    super.initState();
    _popularPlatforms = PopularPlatforms.getForMediaType(widget.mediaType);
    // По умолчанию устанавливаем режим "Populaire"
    _isCustomPlatform = false;
    
    // Слушатели для live preview
    _nameController.addListener(() {
      if (_isCustomPlatform && mounted) {
        setState(() {});
      }
    });
    _iconController.addListener(() {
      if (_isCustomPlatform && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _selectPlatform(PlatformSuggestion? platform) {
    if (platform == null) return;
    setState(() {
      _selectedPlatform = platform;
      _nameController.text = platform.name;
      _iconController.text = platform.icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une plateforme'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Choix: Liste ou Custom
              RadioListTile<bool>(
                title: const Text('Choisir dans la liste'),
                value: false,
                groupValue: _isCustomPlatform,
                onChanged: (value) {
                  setState(() {
                    _isCustomPlatform = value!;
                    if (!_isCustomPlatform) {
                      _nameController.clear();
                      _iconController.clear();
                      _selectedPlatform = null;
                    }
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<bool>(
                title: const Text('Ajouter une autre plateforme'),
                value: true,
                groupValue: _isCustomPlatform,
                onChanged: (value) {
                  setState(() {
                    _isCustomPlatform = value!;
                    if (_isCustomPlatform) {
                      _selectedPlatform = null;
                      _nameController.clear();
                      _iconController.clear();
                    }
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Dropdown pour plateformes populaires
              if (!_isCustomPlatform) ...[
                DropdownButtonFormField<PlatformSuggestion>(
                  value: _selectedPlatform,
                  decoration: const InputDecoration(
                    labelText: 'Choisir une plateforme',
                    border: OutlineInputBorder(),
                  ),
                  items: _popularPlatforms.map((platform) {
                    return DropdownMenuItem(
                      value: platform,
                      child: Text('${platform.icon}  ${platform.name}'),
                    );
                  }).toList(),
                  onChanged: _selectPlatform,
                  hint: const Text('Sélectionnez...'),
                  isExpanded: true,
                ),
              ],

              // Champs personnalisés
              if (_isCustomPlatform) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la plateforme',
                    hintText: 'Ma plateforme',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icône (émoji)',
                    hintText: '📱',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 2,
                ),
              ],

              // Aperçu
              if ((_selectedPlatform != null || (_isCustomPlatform && _nameController.text.isNotEmpty)))
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Aperçu: ${_iconController.text.isEmpty ? '📱' : _iconController.text}  ${_nameController.text.isEmpty ? '...' : _nameController.text}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final icon = _iconController.text.trim();
            
            if (name.isNotEmpty) {
              Navigator.pop(context, {
                'name': name,
                'icon': icon.isEmpty ? '📱' : icon,
              });
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

