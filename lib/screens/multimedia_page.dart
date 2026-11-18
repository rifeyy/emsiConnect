import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MultimediaPage extends StatefulWidget {
  const MultimediaPage({super.key});

  @override
  State<MultimediaPage> createState() => _MultimediaPageState();
}

class _MultimediaPageState extends State<MultimediaPage> {
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  Uint8List? _imageBytes;
  String? _imageName;
  String? _audioPath;

  bool _recording = false;
  bool _busy = false;
  bool _microphoneBlocked = false;

  bool get _isMobile {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text)),
      );
  }

  Future<void> _chooseImage(ImageSource source) async {
    if (_busy || _recording) return;

    setState(() {
      _busy = true;
    });

    try {
      final selected = await _picker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (selected == null) {
        _message('Sélection annulée.');
        return;
      }

      final bytes = await selected.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageName = selected.name;
      });
    } catch (error) {
      _message("Impossible de récupérer l'image : $error");
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _startRecording() async {
    if (_busy || _recording) return;

    if (!_isMobile) {
      _message(
        "Pour ce TP, teste l'enregistrement sur Android ou iOS.",
      );
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final permission = await Permission.microphone.request();

      if (!mounted) return;

      setState(() {
        _microphoneBlocked = permission.isPermanentlyDenied;
      });

      if (!permission.isGranted) {
        _message(
          permission.isPermanentlyDenied
              ? 'Microphone bloqué. Active-le dans les paramètres.'
              : 'Autorisation du microphone refusée.',
        );
        return;
      }

      if (!await _recorder.hasPermission()) {
        _message('Autorisation du microphone indisponible.');
        return;
      }

      await _player.stop();

      final directory = await getTemporaryDirectory();
      final fileName =
          'question_emsi_${DateTime.now().millisecondsSinceEpoch}.m4a';

      if (!mounted) return;

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
        ),
        path: '${directory.path}/$fileName',
      );

      if (!mounted) {
        await _recorder.stop();
        return;
      }

      setState(() {
        _recording = true;
        _audioPath = null;
      });

      _message('Enregistrement en cours...');
    } catch (error) {
      _message('Enregistrement impossible : $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_busy || !_recording) return;

    setState(() {
      _busy = true;
    });

    try {
      final path = await _recorder.stop();

      if (!mounted) return;

      setState(() {
        _recording = false;
        _audioPath = path;
      });

      _message(
        path == null
            ? 'Aucun fichier enregistré.'
            : 'Question vocale enregistrée.',
      );
    } catch (error) {
      _message("Erreur lors de l'arrêt : $error");
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _playAudio() async {
    final path = _audioPath;

    if (path == null || _busy || _recording) return;

    setState(() {
      _busy = true;
    });

    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
    } catch (error) {
      _message('Lecture impossible : $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    final opened = await openAppSettings();

    if (!opened) {
      _message("Impossible d'ouvrir les paramètres.");
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final imageBytes = _imageBytes;

    return PopScope(
      canPop: !_recording && !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Espace multimédia'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Prends une photo ou sélectionne une image '
                            'depuis la galerie.',
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _busy || _recording
                                    ? null
                                    : () => _chooseImage(
                                          ImageSource.camera,
                                        ),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Prendre une photo'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _busy || _recording
                                    ? null
                                    : () => _chooseImage(
                                          ImageSource.gallery,
                                        ),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Galerie'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (imageBytes != null) ...[
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  imageBytes,
                                  height: 240,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Fichier : ${_imageName ?? "Image"}'),
                            Text(
                              'Taille : ${imageBytes.lengthInBytes} octets',
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _busy || _recording
                                  ? null
                                  : () {
                                      setState(() {
                                        _imageBytes = null;
                                        _imageName = null;
                                      });
                                    },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text("Effacer l'image"),
                            ),
                          ] else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 64,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Aucune image sélectionnée'),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question vocale',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _recording
                                ? 'Enregistrement en cours. '
                                    'Arrête-le avant de quitter la page.'
                                : 'Enregistre une question puis écoute-la.',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _busy
                                ? null
                                : (_recording
                                    ? _stopRecording
                                    : _startRecording),
                            icon: Icon(
                              _recording ? Icons.stop : Icons.mic,
                            ),
                            label: Text(
                              _recording ? 'Arrêter' : 'Enregistrer',
                            ),
                          ),
                          if (_audioPath != null) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _busy || _recording
                                  ? null
                                  : _playAudio,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text(
                                "Écouter l'enregistrement",
                              ),
                            ),
                          ],
                          if (_microphoneBlocked) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Le microphone est bloqué. '
                              "Autorise son accès dans les paramètres "
                              "de l'application.",
                            ),
                            TextButton.icon(
                              onPressed: _openSettings,
                              icon: const Icon(Icons.settings),
                              label: const Text('Ouvrir les paramètres'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_busy) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Les enregistrements sont temporaires : '
                    'ils ne sont pas sauvegardés durablement.',
                    textAlign: TextAlign.center,
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