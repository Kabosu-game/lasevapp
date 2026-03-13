import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/models/meditation.dart';

void main() {
  group('Meditation.fromJson', () {
    test('parse API response with audio_url (full URL)', () {
      final json = {
        'id': 1,
        'title': 'Méditation calme',
        'description': 'Description',
        'duration': 10,
        'audio_url': 'https://api.example.com/storage/audios/meditations/test.mp3',
        'image_url': '',
        'category': '',
      };
      final m = Meditation.fromJson(json);
      expect(m.id, 1);
      expect(m.title, 'Méditation calme');
      expect(m.audioUrl, 'https://api.example.com/storage/audios/meditations/test.mp3');
      expect(m.duration, 10);
    });

    test('parse API response with media fallback (relative path)', () {
      final json = {
        'id': 2,
        'title': 'Respiration',
        'description': 'Desc',
        'duration': 5,
        'media': {
          'file_path': 'storage/audios/meditations/resp.mp3',
        },
      };
      final m = Meditation.fromJson(json);
      expect(m.audioUrl, 'storage/audios/meditations/resp.mp3');
      expect(m.title, 'Respiration');
    });

    test('parse API response with media as list (first item)', () {
      final json = {
        'id': 3,
        'title': 'Scan',
        'description': '',
        'duration': 15,
        'media': [
          {'file_path': 'storage/audios/scan.mp3'},
        ],
      };
      final m = Meditation.fromJson(json);
      expect(m.audioUrl, 'storage/audios/scan.mp3');
    });

    test('empty audio when no media', () {
      final json = {
        'id': 4,
        'title': 'Sans audio',
        'description': '',
        'duration': 0,
      };
      final m = Meditation.fromJson(json);
      expect(m.audioUrl, '');
    });
  });
}
