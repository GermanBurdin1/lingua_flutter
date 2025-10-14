import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/vocabulary_provider.dart';

class VoiceRecorder extends StatefulWidget {
  final bool isActive;
  final VoidCallback onToggle;
  final Function(String) onWordRecorded;

  const VoiceRecorder({
    super.key,
    required this.isActive,
    required this.onToggle,
    required this.onWordRecorded,
  });

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/recording.m4a';
        
        await _recorder.start(const RecordConfig(), path: path);
        
        setState(() {
          _isRecording = true;
        });
        
        _pulseController.repeat(reverse: true);
      }
    } catch (e) {
      print('Ошибка начала записи: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      
      setState(() {
        _isRecording = false;
      });
      
      _pulseController.stop();
      _pulseController.reset();

      if (path != null && mounted) {
        setState(() {
          _isProcessing = true;
        });

        // Отправляем на распознавание
        final recognizedText = await context
            .read<VocabularyProvider>()
            .recognizeSpeech(path);

        setState(() {
          _isProcessing = false;
        });

        // Удаляем временный файл
        try {
          await File(path).delete();
        } catch (e) {
          print('Ошибка удаления файла: $e');
        }

        widget.onWordRecorded(recognizedText);
      }
    } catch (e) {
      print('Ошибка остановки записи: $e');
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: InkWell(
          onTap: widget.onToggle,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.mic, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande vocale désactivée',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Appuyez pour activer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              const Text(
                '🎤 Commande vocale active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onToggle,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isProcessing)
                const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Reconnaissance vocale...'),
                ],
              )
            else
              Text(
                _isRecording
                    ? '🔴 Enregistrement... Relâchez le bouton quand vous avez fini'
                    : '👆 Maintenez le bouton pour enregistrer un mot',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            GestureDetector(
              onTapDown: (_) => _startRecording(),
              onTapUp: (_) => _stopRecording(),
              onTapCancel: () => _stopRecording(),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording
                        ? 1.0 + (_pulseController.value * 0.3)
                        : 1.0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : Colors.blue)
                                .withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isRecording ? 'Enregistrement...' : 'Maintenez pour enregistrer',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



