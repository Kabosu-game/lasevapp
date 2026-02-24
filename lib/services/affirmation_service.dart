import 'api_service.dart';

/// Modèle pour une affirmation
class Affirmation {
  final int id;
  final String title;
  final String body;
  final int? categoryId;
  final String? categoryName;

  Affirmation({
    required this.id,
    required this.title,
    required this.body,
    this.categoryId,
    this.categoryName,
  });

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      categoryId: json['category_id'],
      categoryName: json['category']?['name'] ?? json['category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category_id': categoryId,
      'category_name': categoryName,
    };
  }
}

/// Service pour récupérer les affirmations depuis l'API Laravel
class AffirmationService {
  /// Récupérer toutes les affirmations
  Future<List<Affirmation>> getAffirmations({int? categoryId}) async {
    try {
      final endpoint = categoryId != null 
          ? 'affirmations?category_id=$categoryId' 
          : 'affirmations';
      final response = await ApiService.get(endpoint);
      
      if (response is List) {
        return response
            .map((json) => Affirmation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((json) => Affirmation.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des affirmations: $e');
    }
  }

  /// Récupérer une affirmation par son ID
  Future<Affirmation> getAffirmationById(int id) async {
    try {
      final response = await ApiService.get('affirmations/$id');
      
      if (response is Map) {
        if (response.containsKey('data')) {
          return Affirmation.fromJson(response['data'] as Map<String, dynamic>);
        }
        return Affirmation.fromJson(response as Map<String, dynamic>);
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'affirmation: $e');
    }
  }
}

