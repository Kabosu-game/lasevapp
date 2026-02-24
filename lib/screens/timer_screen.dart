import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/video_background.dart';
import '../models/meditation.dart';

class TimerScreen extends StatefulWidget {
  final Meditation meditation;

  const TimerScreen({
    super.key,
    required this.meditation,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _remainingSeconds = 0;
  bool _isPlaying = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Couleur principale du projet
  static const Color primaryColor = Color(0xFF265533);

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.meditation.duration * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isPlaying) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeMeditation();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _remainingSeconds = widget.meditation.duration * 60;
    });
  }

  void _completeMeditation() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Méditation terminée!'),
        content: const Text(
          'Félicitations! Vous avez complété votre session de méditation.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.meditation.title),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation ou icône de méditation
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF265533), Color(0xFF4CAF50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF265533).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Timer
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Contrôles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bouton Play/Pause
                    ElevatedButton(
                      onPressed: _toggleTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(20),
                        shape: const CircleBorder(),
                        minimumSize: const Size(80, 80),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                      ),
                    ),
                    
                    // Bouton Reset
                    ElevatedButton(
                      onPressed: _resetTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black54,
                        padding: const EdgeInsets.all(20),
                        shape: const CircleBorder(),
                        minimumSize: const Size(80, 80),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Message inspirant
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Respirez profondément et concentrez-vous sur le moment présent.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
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
}
