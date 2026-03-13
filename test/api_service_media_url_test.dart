import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/services/api_service.dart';

void main() {
  group('ApiService.mediaUrl', () {
    test('returns null for null or empty', () {
      expect(ApiService.mediaUrl(null), isNull);
      expect(ApiService.mediaUrl(''), isNull);
      expect(ApiService.mediaUrl('   '), isNull);
    });

    test('returns as-is for full URL', () {
      const url = 'https://example.com/file.jpg';
      expect(ApiService.mediaUrl(url), url);
    });

    test('builds storage URL for relative path', () {
      final r = ApiService.mediaUrl('retreat-plans/abc.jpg');
      expect(r, isNotNull);
      expect(r!.contains('storage/retreat-plans/abc.jpg'), isTrue);
      expect(r.startsWith('https://'), isTrue);
    });

    test('keeps storage/ path when building URL', () {
      final r = ApiService.mediaUrl('storage/events/gallery/xyz.png');
      expect(r, isNotNull);
      expect(r!.contains('storage/events/gallery/xyz.png'), isTrue);
      expect(r!.contains('storage/storage/'), isFalse);
    });
  });
}
