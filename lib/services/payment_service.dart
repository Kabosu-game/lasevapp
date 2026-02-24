import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

String? _extractPayPalApprovalUrl(dynamic links) {
  if (links is! List) return null;
  try {
    final approve = links.cast<Map>().firstWhere(
        (l) => l['rel'] == 'approve',
        orElse: () => <String, dynamic>{});
    return approve['href'] as String?;
  } catch (_) {
    return null;
  }
}

/// Capture les requêtes/réponses pour diagnostic - visible dans la console
void _captureDiagnostic(String label, Map<String, dynamic> data) {
  final msg = '''
━━━ DIAGNOSTIC API [$label] ━━━
${const JsonEncoder.withIndent('  ').convert(data)}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''';
  debugPrint(msg);
}

class PaymentService {
  /// Crée une intention de paiement Stripe et retourne le client_secret
  /// Le backend crée l'intention et retourne le client_secret + ephemeral_key + customer
  Future<Map<String, dynamic>> createStripePaymentIntent({
    required double amount,
    required String currency,
    required String email,
  }) async {
    final payload = {
      'amount': (amount * 100).toInt(),
      'currency': currency,
      'email': email,
    };
    final url = '${ApiService.baseUrl}/create-stripe-payment-intent';

    try {
      final body = jsonEncode(payload);
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'clientSecret': data['clientSecret'],
          'ephemeralKey': data['ephemeralKey'],
          'customer': data['customer'],
          'publishableKey': data['publishableKey'],
        };
      } else {
        String errMsg = 'Erreur serveur: ${response.statusCode}';
        Map<String, dynamic>? errData;
        try {
          errData = jsonDecode(response.body) as Map<String, dynamic>?;
          if (errData?['error'] != null) {
            errMsg = errData!['error'] as String;
          }
          if (errData?['errors'] != null && errData!['errors'] is Map) {
            final errs = (errData['errors'] as Map).values;
            if (errs.isNotEmpty) errMsg = errs.join(' ');
          }
        } catch (_) {}

        _captureDiagnostic('create-stripe-payment-intent ERREUR', {
          'url': url,
          'request': payload,
          'statusCode': response.statusCode,
          'responseBody': response.body,
          'error': errMsg,
          'errors': errData?['errors'],
        });
        return {'success': false, 'error': errMsg};
      }
    } catch (e, stack) {
      _captureDiagnostic('create-stripe-payment-intent EXCEPTION', {
        'url': url,
        'request': payload,
        'exception': e.toString(),
        'stack': stack.toString().split('\n').take(5).join('\n'),
      });
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  /// Crée une commande PayPal et retourne l'ID de la commande
  Future<Map<String, dynamic>> createPayPalOrder({
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/create-paypal-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount.toString(),
          'currency': currency,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'orderId': data['orderId'] ?? data['id'],
          'approvalUrl': data['approvalUrl'] ??
              _extractPayPalApprovalUrl(data['links']),
        };
      } else {
        _captureDiagnostic('create-paypal-order ERREUR', {
          'statusCode': response.statusCode,
          'responseBody': response.body,
        });
        return {
          'success': false,
          'error': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e, stack) {
      _captureDiagnostic('create-paypal-order EXCEPTION', {
        'exception': e.toString(),
      });
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  /// Capture le paiement Stripe après confirmation
  Future<Map<String, dynamic>> captureStripePayment({
    required String paymentIntentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/capture-stripe-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'transactionId': data['transactionId'] ?? data['id'],
          'status': data['status'],
        };
      } else {
        _captureDiagnostic('capture-stripe-payment ERREUR', {
          'paymentIntentId': paymentIntentId,
          'statusCode': response.statusCode,
          'responseBody': response.body,
        });
        return {
          'success': false,
          'error': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e, stack) {
      _captureDiagnostic('capture-stripe-payment EXCEPTION', {
        'paymentIntentId': paymentIntentId,
        'exception': e.toString(),
      });
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  /// Approuve et capture le paiement PayPal
  Future<Map<String, dynamic>> approvePayPalOrder({
    required String orderId,
    required String payerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/approve-paypal-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'payerId': payerId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'transactionId': data['transactionId'] ?? data['id'],
          'status': data['status'],
        };
      } else {
        _captureDiagnostic('approve-paypal-order ERREUR', {
          'orderId': orderId,
          'statusCode': response.statusCode,
          'responseBody': response.body,
        });
        return {
          'success': false,
          'error': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e, stack) {
      _captureDiagnostic('approve-paypal-order EXCEPTION', {
        'orderId': orderId,
        'exception': e.toString(),
      });
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  /// Enregistre le paiement dans la base de données après succès
  Future<Map<String, dynamic>> recordPayment({
    required String transactionId,
    required String method, // 'stripe' ou 'paypal'
    required double amount,
    required String status,
    String? userId,
    String? retreatPlanId,
    String? email,
  }) async {
    final requestBody = <String, dynamic>{
      'transactionId': transactionId,
      'method': method,
      'amount': amount,
      'status': status,
      'userId': userId,
      'retreatPlanId': retreatPlanId,
    };
    if (email != null && email.isNotEmpty) {
      requestBody['email'] = email;
    }
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/record-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        _captureDiagnostic('record-payment ERREUR', {
          'request': requestBody,
          'statusCode': response.statusCode,
          'responseBody': response.body,
        });
        return {
          'success': false,
          'error': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e, stack) {
      _captureDiagnostic('record-payment EXCEPTION', {
        'request': requestBody,
        'exception': e.toString(),
      });
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }
}
