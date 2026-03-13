import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meditation.dart';
import '../screens/timer_screen.dart';
import '../services/api_service.dart';
import '../widgets/video_background.dart';

class MeditationDetailScreen extends StatefulWidget {
  final Meditation meditation;

  const MeditationDetailScreen({
    super.key,
    required this.meditation,
  });

  @override
  State<MeditationDetailScreen> createState() => _MeditationDetailScreenState();
}

class _MeditationDetailScreenState extends State<MeditationDetailScreen> {
  static const Color primaryColor = Color(0xFF265533);
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String get _fullAudioUrl {
    final u = widget.meditation.audioUrl;
    if (u.isEmpty) return '';
    return ApiService.mediaUrl(u) ?? u;
  }

  @override
  void initState() {
    super.initState();
    // Sur le Web, le mode mediaPlayer améliore la compatibilité avec les URLs distantes
    if (kIsWeb) {
      _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    }
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() => _duration = d);
      }
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final url = _fullAudioUrl;
    if (url.isEmpty) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setSource(UrlSource(url));
        await _audioPlayer.resume();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lecture impossible: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Ouvrir dans le navigateur',
              textColor: Colors.white,
              onPressed: () => _openAudioInBrowser(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openAudioInBrowser() async {
    final url = _fullAudioUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meditation = widget.meditation;
    final hasAudio = _fullAudioUrl.isNotEmpty;

    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(meditation.title),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image ou placeholder
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meditation.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        meditation.duration > 0
                            ? '${meditation.duration} min'
                            : (_duration.inMinutes > 0
                                ? '${_duration.inMinutes} min'
                                : 'Durée inconnue'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  meditation.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                if (hasAudio) ...[
                  const SizedBox(height: 24),
                  _buildAudioPlayer(),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimerScreen(meditation: meditation),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text(
                          'Commencer la méditation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildAudioPlayer() {
    final totalSeconds =
        _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 0.0;
    final positionSeconds =
        _position.inSeconds.clamp(0, _duration.inSeconds).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.audiotrack, color: primaryColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio de méditation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPlaying ? 'Lecture en cours...' : 'Appuyez pour lire',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: _toggleAudio,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
                style: IconButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (totalSeconds > 0)
            Column(
              children: [
                Slider(
                  min: 0,
                  max: totalSeconds,
                  value: positionSeconds,
                  activeColor: primaryColor,
                  onChanged: (value) async {
                    final newPosition = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(newPosition);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _openAudioInBrowser,
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('Ouvrir l\'audio dans le navigateur'),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
