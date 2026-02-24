import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login avec email et mot de passe
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];

        // Sauvegarder le token et les données utilisateur
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _userKey, value: jsonEncode(user));

        return {'success': true, 'user': user};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Email ou mot de passe incorrect'};
      } else {
        return {'success': false, 'error': 'Erreur serveur: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  // Récupérer le token stocké
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Récupérer l'utilisateur connecté
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Récupérer l'historique de paiement de l'utilisateur
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/user/payments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> payments = data['data'] ?? [];
        return payments.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des paiements: $e');
      return [];
    }
  }

  // Récupérer les statistiques de paiement
  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      final token = await getToken();
      if (token == null) return {};

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/user/payment-stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }
}
