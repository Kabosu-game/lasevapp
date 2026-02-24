import 'api_service.dart';

/// Modèle pour un événement
class Event {
  final int id;
  final String title;
  final String? description;
  final String eventDate;
  final String? location;
  final double? price;
  final String? status;
  final List<Map<String, dynamic>>? media;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.location,
    this.price,
    this.status,
    this.media,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      eventDate: json['event_date'] ?? json['eventDate'] ?? '',
      location: json['location'],
      price: json['price'] != null 
          ? (json['price'] is double ? json['price'] : double.tryParse(json['price'].toString()))
          : null,
      status: json['status'],
      media: json['media'] != null && json['media'] is List
          ? (json['media'] as List).map((m) => m as Map<String, dynamic>).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate,
      'location': location,
      'price': price,
      'status': status,
      'media': media,
    };
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(eventDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return eventDate;
    }
  }
}

/// Service pour récupérer les événements depuis l'API Laravel
class EventService {
  /// Récupérer tous les événements
  Future<List<Event>> getEvents() async {
    try {
      final response = await ApiService.get('events');
      
      if (response is List) {
        return response
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((json) => Event.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  /// Récupérer un événement par son ID
  Future<Event> getEventById(int id) async {
    try {
      final response = await ApiService.get('events/$id');
      
      if (response is Map) {
        if (response.containsKey('data')) {
          return Event.fromJson(response['data'] as Map<String, dynamic>);
        }
        return Event.fromJson(response as Map<String, dynamic>);
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'événement: $e');
    }
  }
}

