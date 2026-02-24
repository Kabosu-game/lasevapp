import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../services/payment_service.dart';
import '../widgets/video_background.dart';

class AdvancedPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final String userId;
  final String password;
  final String? email;
  final double amount;
  final String retreatPlanId;

  const AdvancedPaymentScreen({
    super.key,
    required this.formData,
    required this.userId,
    required this.password,
    this.email,
    required this.amount,
    required this.retreatPlanId,
  });

  @override
  State<AdvancedPaymentScreen> createState() => _AdvancedPaymentScreenState();
}

class _AdvancedPaymentScreenState extends State<AdvancedPaymentScreen> {
  static const Color primaryColor = Color(0xFF265533);
  final PaymentService _paymentService = PaymentService();

  bool _isProcessing = false;
  String? _selectedPaymentMethod; // 'stripe' ou 'paypal'
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  /// Traite le paiement Stripe en utilisant Stripe Flutter SDK
  Future<void> _processStripePayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Créer une intention de paiement côté serveur
      final intentResult = await _paymentService.createStripePaymentIntent(
        amount: widget.amount,
        currency: 'EUR',
        email: widget.email ?? 'user@example.com',
      );

      if (!intentResult['success']) {
        _showError('Erreur: ${intentResult['error']}');
        return;
      }

      final clientSecret = intentResult['clientSecret'];
      final publishableKey = intentResult['publishableKey'] as String?;

      if (publishableKey == null || publishableKey.isEmpty) {
        _showError('Clé Stripe manquante. Vérifiez la configuration serveur.');
        return;
      }

      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();

      // 2. Confirmer le paiement avec Stripe Flutter SDK
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LASEV',
          customFlow: true,
        ),
      );

      // 3. Montrer le formulaire de paiement Stripe
      await Stripe.instance.presentPaymentSheet();

      // 4. Le paiement est confirmé localement; capturer côté serveur
      final captureResult = await _paymentService.captureStripePayment(
        paymentIntentId: clientSecret.split('_secret_')[0],
      );

      if (captureResult['success']) {
        // 5. Enregistrer le paiement dans la base de données
        await _paymentService.recordPayment(
          transactionId: captureResult['transactionId'],
          method: 'stripe',
          amount: widget.amount,
          status: 'completed',
          userId: widget.userId,
          retreatPlanId: widget.retreatPlanId,
          email: widget.email,
        );

        _showSuccess('Paiement Stripe réussi!');
        _navigateToConfirmation();
      } else {
        _showError('Erreur lors de la capture: ${captureResult['error']}');
      }
    } on StripeException catch (e) {
      _showError('Erreur Stripe: ${e.error.localizedMessage}');
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Traite le paiement PayPal avec WebView
  Future<void> _processPayPalPayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Créer une commande PayPal côté serveur
      final orderResult = await _paymentService.createPayPalOrder(
        amount: widget.amount,
        currency: 'EUR',
        description: widget.formData['retreatName'] ?? 'Retraite',
      );

      if (!orderResult['success']) {
        _showError('Erreur: ${orderResult['error']}');
        return;
      }

      final orderId = orderResult['orderId'];
      final approvalUrl = orderResult['approvalUrl'];

      // 2. Ouvrir PayPal dans une WebView pour l'approbation
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PayPalWebView(
              approvalUrl: approvalUrl,
            ),
          ),
        );

        if (result == null) {
          _showError('Paiement PayPal annulé');
          return;
        }

        final payerId = result['payerId'];

        // 3. Approuver et capturer le paiement PayPal côté serveur
        final approveResult = await _paymentService.approvePayPalOrder(
          orderId: orderId,
          payerId: payerId,
        );

        if (approveResult['success']) {
          // 4. Enregistrer le paiement dans la base de données
          await _paymentService.recordPayment(
            transactionId: approveResult['transactionId'],
            method: 'paypal',
            amount: widget.amount,
            status: 'completed',
            userId: widget.userId,
            retreatPlanId: widget.retreatPlanId,
            email: widget.email,
          );

          _showSuccess('Paiement PayPal réussi!');
          _navigateToConfirmation();
        } else {
          _showError('Erreur: ${approveResult['error']}');
        }
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _navigateToConfirmation() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Paiement Sécurisé'),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Récapitulatif
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Récapitulatif de votre réservation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Retraite : ${widget.formData['retreatName']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Dates : ${widget.formData['retreatDates']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Participant : ${widget.formData['name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Montant
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Montant à payer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.amount.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Choix du moyen de paiement
                const Text(
                  'Choisir un moyen de paiement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton Stripe
                GestureDetector(
                  onTap: _isProcessing
                      ? null
                      : () {
                          setState(() => _selectedPaymentMethod = 'stripe');
                          _processStripePayment();
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPaymentMethod == 'stripe'
                            ? Colors.blue
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _selectedPaymentMethod == 'stripe'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/stripe-logo.png',
                          height: 40,
                          width: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'S',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Payer avec Stripe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Carte bancaire sécurisée',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton PayPal
                GestureDetector(
                  onTap: _isProcessing
                      ? null
                      : () {
                          setState(() => _selectedPaymentMethod = 'paypal');
                          _processPayPalPayment();
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPaymentMethod == 'paypal'
                            ? const Color(0xFF003087)
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _selectedPaymentMethod == 'paypal'
                          ? const Color(0xFF003087).withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/paypal-logo.png',
                          height: 40,
                          width: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF003087),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'P',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Payer avec PayPal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Compte PayPal ou carte',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_isProcessing)
                  Center(
                    child: Column(
                      children: const [
                        CircularProgressIndicator(color: primaryColor),
                        SizedBox(height: 16),
                        Text('Traitement du paiement...'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// WebView pour approuver PayPal
class PayPalWebView extends StatefulWidget {
  final String approvalUrl;

  const PayPalWebView({super.key, required this.approvalUrl});

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Vérifier si l'utilisateur a approuvé et est redirigé
            if (url.contains('return=1') && url.contains('PayerID')) {
              final uri = Uri.parse(url);
              final payerId = uri.queryParameters['PayerID'];
              Navigator.pop(context, {'payerId': payerId});
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('cancel=1')) {
              Navigator.pop(context);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approuver le paiement PayPal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
