import 'api_service.dart';

/// Modèle pour un plan de retraite
class RetreatPlan {
  final int id;
  final String title;
  final String description;
  final int durationDays;
  final String? coverImage;
  final List<String>? features;
  final List<String>? tags;
  final List<String>? services;
  final String status;
  final double? price;

  RetreatPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    this.coverImage,
    this.features,
    this.tags,
    this.services,
    required this.status,
    this.price,
  });

  factory RetreatPlan.fromJson(Map<String, dynamic> json) {
    return RetreatPlan(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      coverImage: json['cover_image'],
      features: json['features'] != null 
          ? (json['features'] is List 
              ? (json['features'] as List).map((e) => e.toString()).toList()
              : [])
          : null,
      tags: json['tags'] != null
          ? (json['tags'] is List
              ? (json['tags'] as List).map((e) => e.toString()).toList()
              : [])
          : null,
      services: json['services'] != null
          ? (json['services'] is List
              ? (json['services'] as List).map((e) => e.toString()).toList()
              : [])
          : null,
      status: json['status'] ?? 'available',
      price: json['price'] != null ? (json['price'] is double ? json['price'] : double.tryParse(json['price'].toString())) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_days': durationDays,
      'cover_image': coverImage,
      'features': features,
      'tags': tags,
      'services': services,
      'status': status,
      'price': price,
    };
  }

  // Méthodes utilitaires pour l'affichage
  String get duration => '$durationDays jours';
  String get priceDisplay => price != null ? '${price!.toStringAsFixed(2)} €' : 'Sur demande';
  bool get isAvailable => status == 'available';
  bool get isOnRequest => status == 'on_request';
  bool get isComingSoon => status == 'coming_soon';
}

/// Service pour récupérer les plans de retraite depuis l'API Laravel
class RetreatPlanService {
  /// Récupérer tous les plans de retraite
  Future<List<RetreatPlan>> getRetreatPlans({String? status}) async {
    try {
      final endpoint = status != null ? 'retreat-plans?status=$status' : 'retreat-plans';
      final response = await ApiService.get(endpoint);
      
      if (response is List) {
        return response
            .map((json) => RetreatPlan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        return (response['data'] as List<dynamic>)
            .map((json) => RetreatPlan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des plans de retraite: $e');
    }
  }

  /// Récupérer uniquement les plans disponibles (publiés)
  Future<List<RetreatPlan>> getAvailableRetreatPlans() async {
    return await getRetreatPlans(status: 'available');
  }

  /// Récupérer un plan de retraite par ID
  Future<RetreatPlan> getRetreatPlanById(int id) async {
    try {
      final response = await ApiService.get('retreat-plans/$id');
      
      if (response is Map) {
        // Si la réponse contient une clé 'data', utiliser celle-ci
        if (response.containsKey('data')) {
          return RetreatPlan.fromJson(response['data'] as Map<String, dynamic>);
        }
        return RetreatPlan.fromJson(response as Map<String, dynamic>);
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du plan de retraite: $e');
    }
  }
}

