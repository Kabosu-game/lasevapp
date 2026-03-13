import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/services/blog_service.dart';

void main() {
  group('BlogService.parseBlogList', () {
    test('parse direct List from API', () {
      final response = [
        {
          'id': 1,
          'title': 'Article 1',
          'body': 'Body 1',
          'author_id': 1,
          'is_premium': false,
          'category': 'pouvoir-secret',
          'description': 'Desc 1',
        },
        {
          'id': 2,
          'title': 'Article 2',
          'body': 'Body 2',
          'author_id': 1,
          'is_premium': false,
          'category': 'pouvoir-secret',
        },
      ];
      final list = BlogService.parseBlogList(response);
      expect(list.length, 2);
      expect(list[0].title, 'Article 1');
      expect(list[0].category, 'pouvoir-secret');
      expect(list[1].title, 'Article 2');
    });

    test('parse wrapped in data', () {
      final response = {
        'data': [
          {
            'id': 1,
            'title': 'Wrapped',
            'body': 'B',
            'author_id': 1,
            'is_premium': false,
            'category': 'Pouvoir secret',
          },
        ],
      };
      final list = BlogService.parseBlogList(response);
      expect(list.length, 1);
      expect(list[0].title, 'Wrapped');
      expect(list[0].category, 'Pouvoir secret');
    });

    test('empty for invalid response', () {
      expect(BlogService.parseBlogList(null), isEmpty);
      expect(BlogService.parseBlogList({}), isEmpty);
      expect(BlogService.parseBlogList({'data': null}), isEmpty);
    });
  });
}
