import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/services/attachment_service.dart';
import 'package:purenote/features/audio/widgets/audio_player_widget.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/l10n/app_localizations.dart';

class AudioRecorderScreen extends ConsumerStatefulWidget {
  final String noteId;
  const AudioRecorderScreen({super.key, required this.noteId});

  @override
  ConsumerState<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends ConsumerState<AudioRecorderScreen> with WidgetsBindingObserver {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  String? _recordedPath;
  final _amplitudes = <double>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _ampTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRecording) {
      if (_isPaused) return;
      _pauseRecording();
    }
  }

  Future<bool> _hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.microphonePermissionRequired)),
        );
      }
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, 'recordings', '${const Uuid().v4()}.m4a');
    await Directory(p.dirname(filePath)).create(recursive: true);

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordDuration++);
    });

    _ampTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      try {
        final amp = await _recorder.getAmplitude();
        final normalized = min(1.0, max(0.0, (amp.current + 60) / 60));
        if (mounted && _isRecording) {
          setState(() {
            _amplitudes.add(normalized);
            if (_amplitudes.length > 60) _amplitudes.removeAt(0);
          });
        }
      } catch (_) {}
    });

    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordDuration = 0;
      _amplitudes.clear();
    });
  }

  Future<void> _pauseRecording() async {
    await _recorder.pause();
    _timer?.cancel();
    _ampTimer?.cancel();
    setState(() => _isPaused = true);
  }

  Future<void> _resumeRecording() async {
    await _recorder.resume();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordDuration++);
    });
    _ampTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      try {
        final amp = await _recorder.getAmplitude();
        final normalized = min(1.0, max(0.0, (amp.current + 60) / 60));
        if (mounted && _isRecording) {
          setState(() {
            _amplitudes.add(normalized);
            if (_amplitudes.length > 60) _amplitudes.removeAt(0);
          });
        }
      } catch (_) {}
    });
    setState(() => _isPaused = false);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordedPath = path;
      _amplitudes.clear();
    });
  }

  Future<void> _saveRecording() async {
    if (_recordedPath == null) return;
    final file = File(_recordedPath!);

    final service = AttachmentService(ref.read(attachmentDaoProvider));
    final result = await service.attachFile(
      noteId: widget.noteId,
      sourceFile: file,
      mimeType: 'audio/m4a',
    );

    if (result is Ok && mounted) {
      context.pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedToSaveRecording)),
      );
    }
  }

  Future<void> _discard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteRecording),
        content: Text(AppLocalizations.of(context)!.deleteRecordingContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context)!.discard)),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_recordedPath != null) {
      final file = File(_recordedPath!);
      if (await file.exists()) await file.delete();
    }
    if (mounted) context.pop(false);
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recordAudioTitle),
        actions: [
          if (_recordedPath != null && !_isRecording)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveRecording,
              tooltip: AppLocalizations.of(context)!.save,
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 80,
              color: _isRecording ? colors.accentDanger : theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _formatDuration(_recordDuration),
              style: theme.textTheme.displaySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w300,
              ),
            ),
            if (_isRecording && _amplitudes.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width * 0.6, 40),
                  painter: _WaveformPainter(_amplitudes, theme.colorScheme.primary),
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRecording && _recordedPath == null)
                  FloatingActionButton.large(
                    onPressed: _startRecording,
                    child: const Icon(Icons.mic),
                  ),
                if (_isRecording && !_isPaused)
                  FloatingActionButton.large(
                    onPressed: _pauseRecording,
                    backgroundColor: colors.accentWarm,
                    child: const Icon(Icons.pause),
                  ),
                if (_isRecording && _isPaused)
                  FloatingActionButton.large(
                    onPressed: _resumeRecording,
                    child: const Icon(Icons.mic),
                  ),
                if (_recordedPath != null && !_isRecording) ...[
                  FloatingActionButton.large(
                    onPressed: _startRecording,
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ],
            ),
            if (_recordedPath != null && !_isRecording) ...[
              const SizedBox(height: 16),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                child: NoteAudioPlayer(filePath: _recordedPath!, dense: true),
              ),
            ],
            if (_isRecording || _recordedPath != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _isRecording ? _stopRecording : _discard,
                icon: Icon(Icons.stop, color: colors.accentDanger),
                label: Text(
                  _isRecording ? AppLocalizations.of(context)!.stop : AppLocalizations.of(context)!.discard,
                  style: TextStyle(color: colors.accentDanger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  _WaveformPainter(this.amplitudes, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / amplitudes.length;
    for (var i = 0; i < amplitudes.length; i++) {
      final barHeight = max(2.0, amplitudes[i] * size.height);
      final x = i * barWidth;
      final y = (size.height - barHeight) / 2;
      canvas.drawLine(Offset(x, y + barHeight), Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => true;
}
