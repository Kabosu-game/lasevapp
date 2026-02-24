import 'api_service.dart';

/// Modèle pour un plat (affichage page Cuisine)
class Dish {
  final int id;
  final String name;
  final String? imageUrl;

  Dish({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image']?.toString()?.replaceAll(r'\', '/');
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${ApiService.imageBaseUrl}/serve-storage/${imageUrl.trim()}';
    }
    return Dish(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: imageUrl,
    );
  }
}

/// Modèle pour un chef cuisinier
class Chef {
  final int id;
  final String name;
  final String? role;
  final String? imageUrl;

  Chef({
    required this.id,
    required this.name,
    this.role,
    this.imageUrl,
  });

  factory Chef.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image']?.toString()?.replaceAll(r'\', '/');
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${ApiService.imageBaseUrl}/serve-storage/${imageUrl.trim()}';
    }
    return Chef(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role']?.toString(),
      imageUrl: imageUrl,
    );
  }
}

/// Service pour récupérer plats et chefs depuis l'API
class CuisineService {
  Future<List<Dish>> getDishes() async {
    try {
      final response = await ApiService.get('dishes');
      if (response is List) {
        return response
            .map((json) => Dish.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((json) => Dish.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors du chargement des plats: $e');
    }
  }

  Future<List<Chef>> getChefs() async {
    try {
      final response = await ApiService.get('chefs');
      if (response is List) {
        return response
            .map((json) => Chef.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((json) => Chef.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors du chargement des chefs: $e');
    }
  }
}
