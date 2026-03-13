import 'api_service.dart';

/// Modèle pour un blog
class Blog {
  final int id;
  final String title;
  final String? slug;
  final String? description;
  final String body;
  final int authorId;
  final String? authorName;
  final bool isPremium;
  final String? category;
  final List<Map<String, dynamic>>? media;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Blog({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    required this.body,
    required this.authorId,
    this.authorName,
    required this.isPremium,
    this.category,
    this.media,
    this.createdAt,
    this.updatedAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Blog(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      slug: json['slug'],
      description: json['description'],
      body: json['body'] ?? '',
      authorId: _toInt(json['author_id']),
      authorName: json['author']?['name'] ?? json['author_name'],
      isPremium: json['is_premium'] is bool 
          ? json['is_premium'] as bool
          : (json['is_premium'] == 1 || json['is_premium'] == '1' || json['is_premium'] == true),
      category: json['category'],
      media: json['media'] != null && json['media'] is List
          ? (json['media'] as List)
              .where((m) => m is Map)
              .map((m) => m as Map<String, dynamic>)
              .toList()
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'body': body,
      'author_id': authorId,
      'author_name': authorName,
      'is_premium': isPremium,
      'category': category,
      'media': media,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day.toString().padLeft(2, '0')}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
  }
}

/// Service pour récupérer les blogs depuis l'API Laravel
class BlogService {
  /// Récupérer tous les blogs, optionnellement filtrés par catégorie (ex: pouvoir-secret)
  Future<List<Blog>> getBlogs({String? category}) async {
    try {
      final endpoint = category != null && category.isNotEmpty
          ? 'blogs?category=${Uri.encodeComponent(category)}'
          : 'blogs';
      final response = await ApiService.get(endpoint);

      List<Blog> list = BlogService.parseBlogList(response);
      if (category != null && category.isNotEmpty && list.isEmpty) {
        // Fallback : charger tous les blogs et filtrer côté client (si l’API a un autre format de catégorie)
        final all = await ApiService.get('blogs');
        list = BlogService.parseBlogList(all);
        final catLower = category.toLowerCase().replaceAll(RegExp(r'[\s_]+'), '-');
        list = list.where((b) {
          final c = (b.category ?? '').toLowerCase().replaceAll(RegExp(r'[\s_]+'), '-');
          return c == catLower || c.contains('pouvoir');
        }).toList();
      }
      return list;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des blogs: $e');
    }
  }

  /// Exposé pour les tests. Parse la réponse API (List ou { data: List }).
  static List<Blog> parseBlogList(dynamic response) {
    if (response is List) {
      return response
          .map((json) => Blog.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    if (response is Map && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) {
        return data
            .map((json) => Blog.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Récupérer un blog par son ID
  Future<Blog> getBlogById(int id) async {
    try {
      final response = await ApiService.get('blogs/$id');
      
      if (response is Map) {
        if (response.containsKey('data')) {
          return Blog.fromJson(response['data'] as Map<String, dynamic>);
        }
        return Blog.fromJson(response as Map<String, dynamic>);
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du blog: $e');
    }
  }
}

