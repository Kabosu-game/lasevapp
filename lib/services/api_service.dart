import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service API générique avec gestion des tokens et erreurs
/// Utilise l'API de production : lasevapi.o-sterebois.fr
class ApiService {
  static const String _apiHost = 'https://lasevapi.o-sterebois.fr';
  static String get baseUrl => '$_apiHost/api';
  /// Base URL pour les images (sans /api)
  static String get imageBaseUrl => _apiHost;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  /// Obtenir le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Sauvegarder le token d'authentification
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Supprimer le token (déconnexion)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  /// Construire les headers avec authentification
  static Future<Map<String, String>> _getHeaders(
      {bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Requête GET générique
  static Future<dynamic> get(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final url = '$baseUrl/$endpoint';
      print('🔵 API GET: $url'); // Debug
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      print('🟢 API Response Status: ${response.statusCode}'); // Debug
      final bodyPreview = response.body.length > 200
          ? '${response.body.substring(0, 200)}...'
          : response.body;
      print('🟢 API Response Body: $bodyPreview'); // Debug

      return _handleResponse(response);
    } catch (e) {
      print('🔴 API Error: $e'); // Debug
      print('🔴 URL tentée: $baseUrl/$endpoint'); // Debug
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Requête POST générique
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic>? body, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final url = '$baseUrl/$endpoint';
      print('🔵 API POST: $url'); // Debug
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      print('🟢 API Response Status: ${response.statusCode}'); // Debug
      print(
          '🟢 API Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}'); // Debug

      return _handleResponse(response);
    } catch (e) {
      print('🔴 Erreur API POST $endpoint: $e'); // Debug
      print('🔴 URL tentée: $baseUrl/$endpoint'); // Debug
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Gérer la réponse HTTP
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        print('🔴 Erreur de parsing JSON: $e');
        print('🔴 Body: ${response.body}');
        throw Exception('Erreur de format de réponse: $e');
      }
    } else if (response.statusCode == 401) {
      clearToken();
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée (404)');
    } else if (response.statusCode >= 500) {
      throw Exception('Erreur serveur: ${response.statusCode}');
    } else {
      try {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ??
            errorData['errors']?.toString() ??
            'Erreur: ${response.statusCode}';
        throw Exception(message);
      } catch (e) {
        throw Exception('Erreur: ${response.statusCode} - ${response.body}');
      }
    }
  }
}
