import '../models/meditation.dart';
import 'api_service.dart';

class MeditationService {
  /// Récupérer toutes les méditations depuis l'API Laravel
  Future<List<Meditation>> getMeditations() async {
    try {
      final response = await ApiService.get('meditations');
      
      if (response is List) {
        return response
            .map((json) => Meditation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((json) => Meditation.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des méditations: $e');
    }
  }

  /// Récupérer une méditation par son ID
  Future<Meditation> getMeditationById(int id) async {
    try {
      final response = await ApiService.get('meditations/$id');
      
      if (response is Map) {
        // Si la réponse contient une clé 'data', utiliser celle-ci
        if (response.containsKey('data')) {
          return Meditation.fromJson(response['data'] as Map<String, dynamic>);
        }
        return Meditation.fromJson(response as Map<String, dynamic>);
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la méditation: $e');
    }
  }
}
