import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../widgets/video_background.dart';
import '../widgets/stripe_payment_widget.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';

class RetreatFormScreen extends StatefulWidget {
  final String retreatName;
  final String retreatDates;

  const RetreatFormScreen({
    super.key,
    required this.retreatName,
    required this.retreatDates,
  });

  @override
  State<RetreatFormScreen> createState() => _RetreatFormScreenState();
}

class _RetreatFormScreenState extends State<RetreatFormScreen> {
  static const Color primaryColor = Color(0xFF265533);
  
  // Controllers pour les champs de texte
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _allergyDetailsController = TextEditingController();
  final TextEditingController _intoleranceController = TextEditingController();
  final TextEditingController _otherDietController = TextEditingController();
  final TextEditingController _ingredient1Controller = TextEditingController();
  final TextEditingController _ingredient2Controller = TextEditingController();
  final TextEditingController _ingredient3Controller = TextEditingController();
  final TextEditingController _dislikedFoodController = TextEditingController();
  final TextEditingController _comfortDishController = TextEditingController();
  final TextEditingController _otherHotDrinkController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  // Variables pour les checkboxes et radio buttons
  bool _hasAllergy = false;
  bool _isContactAllergy = false;
  bool _isIngestionAllergy = false;
  String _dietPreference = '';
  String _spiceLevel = 'Médium';
  List<String> _cuisinePreferences = [];
  String _breakfastPreference = '';
  List<String> _hotDrinks = [];
  String _vegetableMilk = '';
  bool _needsSnacks = false;

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Fiche de Confort Alimentaire'),
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
                // Header
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
                      Text(
                        'Retraite : ${widget.retreatName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dates : ${widget.retreatDates}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Nom & Prénom
                _buildSectionTitle('Nom & Prénom :'),
                _buildTextField(_nameController, 'Votre nom et prénom'),
                
                const SizedBox(height: 32),
                
                // Section 1: SANTÉ & SÉCURITÉ
                _buildSectionTitle('1. SANTÉ & SÉCURITÉ (Impératif)'),
                _buildSubTitle('Avez-vous des allergies alimentaires ?'),
                Row(
                  children: [
                    Checkbox(
                      value: !_hasAllergy,
                      onChanged: (value) => setState(() => _hasAllergy = false),
                    ),
                    const Text('Non'),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: _hasAllergy,
                      onChanged: (value) => setState(() => _hasAllergy = true),
                    ),
                    const Text('Oui'),
                  ],
                ),
                if (_hasAllergy) ...[
                  const SizedBox(height: 12),
                  _buildSubTitle('(Précisez l\'aliment et la réaction) :'),
                  _buildTextField(_allergyDetailsController, 'Détails de l\'allergie'),
                  const SizedBox(height: 12),
                  _buildSubTitle('Précision : S\'agit-il d\'une allergie par contact ou uniquement par ingestion ?'),
                  Row(
                    children: [
                      Checkbox(
                        value: _isContactAllergy,
                        onChanged: (value) => setState(() => _isContactAllergy = value!),
                      ),
                      const Text('par contact'),
                      const SizedBox(width: 20),
                      Checkbox(
                        value: _isIngestionAllergy,
                        onChanged: (value) => setState(() => _isIngestionAllergy = value!),
                      ),
                      const Text('uniquement par ingestion'),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Souffrez-vous d\'intolérances ? (Lactose, gluten, FODMAPs, etc.) :'),
                _buildTextField(_intoleranceController, 'Vos intolérances'),
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Suivez-vous un régime spécifique ?'),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildCheckbox('Végétarien', 'Végétarien'),
                    _buildCheckbox('Vegan', 'Vegan'),
                    _buildCheckbox('Sans Gluten', 'Sans Gluten'),
                    _buildCheckbox('Sans Porc', 'Sans Porc'),
                    _buildCheckbox('Autre', 'Autre'),
                  ],
                ),
                if (_dietPreference == 'Autre') ...[
                  const SizedBox(height: 12),
                  _buildTextField(_otherDietController, 'Précisez votre régime'),
                ],
                
                const SizedBox(height: 32),
                
                // Section 2: VOS PRÉFÉRENCES & PLAISIRS
                _buildSectionTitle('2. VOS PRÉFÉRENCES & PLAISIRS'),
                _buildSubTitle('Quels sont vos 3 ingrédients "bonheur" (ceux qui vous font du bien) ?'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_ingredient1Controller, 'Ingrédient 1')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_ingredient2Controller, 'Ingrédient 2')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_ingredient3Controller, 'Ingrédient 3')),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Y a-t-il des aliments que vous ne mangez jamais par simple dégoût ?'),
                _buildTextField(_dislikedFoodController, 'Aliments que vous n\'aimez pas'),
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Votre rapport aux épices :'),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Très doux (non piquant)'),
                      value: 'Très doux',
                      groupValue: _spiceLevel,
                      onChanged: (value) => setState(() => _spiceLevel = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Médium (parfumé)'),
                      value: 'Médium',
                      groupValue: _spiceLevel,
                      onChanged: (value) => setState(() => _spiceLevel = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Relevé (j\'aime le piment)'),
                      value: 'Relevé',
                      groupValue: _spiceLevel,
                      onChanged: (value) => setState(() => _spiceLevel = value!),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Section 3: VOS INSPIRATIONS CULINAIRES
                _buildSectionTitle('3. VOS INSPIRATIONS CULINAIRES'),
                _buildSubTitle('Quels types de cuisines préférez-vous ? (Cochez vos 2 favoris)'),
                _buildCheckbox('Méditerranéenne (Huile d\'olive, légumes du soleil, herbes de Provence)', 'Méditerranéenne'),
                _buildCheckbox('Asiatique (Lait de coco, gingembre, vapeur, riz, curry)', 'Asiatique'),
                _buildCheckbox('Orientale (Épices douces, semoule, légumineuses, fruits secs)', 'Orientale'),
                _buildCheckbox('Terroir (Plats mijotés, légumes racines, gratins, simplicité)', 'Terroir'),
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Citez un plat qui vous apporte du réconfort :'),
                _buildTextField(_comfortDishController, 'Plat réconfort'),
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Le matin, vous êtes plutôt :'),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Sucré (Fruits, granola, pain)'),
                      value: 'Sucré',
                      groupValue: _breakfastPreference,
                      onChanged: (value) => setState(() => _breakfastPreference = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Salé (Œufs, avocat, fromage)'),
                      value: 'Salé',
                      groupValue: _breakfastPreference,
                      onChanged: (value) => setState(() => _breakfastPreference = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Pas de petit-déjeuner'),
                      value: 'Pas de petit-déjeuner',
                      groupValue: _breakfastPreference,
                      onChanged: (value) => setState(() => _breakfastPreference = value!),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Section 4: HABITUDES ET BOISSONS
                _buildSectionTitle('4. HABITUDES ET BOISSONS'),
                _buildSubTitle('Boissons chaudes :'),
                _buildCheckbox('Café', 'Café'),
                _buildCheckbox('Thé noir', 'Thé noir'),
                _buildCheckbox('Infusions', 'Infusions'),
                _buildCheckbox('Autre', 'Autre boissons chaudes'),
                if (_hotDrinks.contains('Autre boissons chaudes')) ...[
                  const SizedBox(height: 12),
                  _buildTextField(_otherHotDrinkController, 'Précisez la boisson'),
                ],
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Boissons végétales souhaitées ?'),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildCheckbox('Avoine', 'Avoine'),
                    _buildCheckbox('Amande', 'Amande'),
                    _buildCheckbox('Soja', 'Soja'),
                    _buildCheckbox('Lait animal', 'Lait animal'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Besoin de collations entre les repas ?'),
                Row(
                  children: [
                    Checkbox(
                      value: _needsSnacks,
                      onChanged: (value) => setState(() => _needsSnacks = value!),
                    ),
                    const Text('Oui'),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: !_needsSnacks,
                      onChanged: (value) => setState(() => _needsSnacks = false),
                    ),
                    const Text('Non'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSubTitle('Commentaires libres (besoins particuliers, portion, etc.) :'),
                _buildTextField(_commentsController, 'Vos commentaires', maxLines: 3),
                
                const SizedBox(height: 32),
                
                // Message de remerciement
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Merci d\'avoir pris le temps de remplir ce questionnaire. Nous ferons de notre mieux pour que vos repas soient un moment de joie et de ressourcement.',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Bouton de validation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Valider et continuer vers le paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: _cuisinePreferences.contains(value) || 
                   _hotDrinks.contains(value) ||
                   _vegetableMilk == value ||
                   _dietPreference == value,
            onChanged: (checked) {
              setState(() {
                if (value == 'Autre' || value == 'Autre boissons chaudes') {
                  if (value == 'Autre') {
                    _dietPreference = checked! ? value : '';
                  } else {
                    if (checked!) {
                      _hotDrinks.add(value);
                    } else {
                      _hotDrinks.remove(value);
                    }
                  }
                } else if (_vegetableMilk == value || (_vegetableMilk.isEmpty && checked!)) {
                  _vegetableMilk = checked! ? value : '';
                } else if (_dietPreference == value || (_dietPreference.isEmpty && checked!)) {
                  _dietPreference = checked! ? value : '';
                } else if (_hotDrinks.contains(value) || checked!) {
                  if (checked!) {
                    _hotDrinks.add(value);
                  } else {
                    _hotDrinks.remove(value);
                  }
                } else {
                  if (checked!) {
                    _cuisinePreferences.add(value);
                  } else {
                    _cuisinePreferences.remove(value);
                  }
                }
              });
            },
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    // Validation basique
    if (_nameController.text.trim().isEmpty) {
      _showError('Veuillez remplir votre nom et prénom');
      return;
    }

    if (_hasAllergy && _allergyDetailsController.text.trim().isEmpty) {
      _showError('Veuillez préciser les détails de votre allergie');
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Créer les données du formulaire
      final formData = {
        'retreatName': widget.retreatName,
        'retreatDates': widget.retreatDates,
        'name': _nameController.text,
        'hasAllergy': _hasAllergy,
        'allergyDetails': _allergyDetailsController.text,
        'isContactAllergy': _isContactAllergy,
        'isIngestionAllergy': _isIngestionAllergy,
        'intolerances': _intoleranceController.text,
        'dietPreference': _dietPreference,
        'otherDiet': _otherDietController.text,
        'ingredients': [
          _ingredient1Controller.text,
          _ingredient2Controller.text,
          _ingredient3Controller.text,
        ].where((ing) => ing.isNotEmpty).toList(),
        'dislikedFood': _dislikedFoodController.text,
        'spiceLevel': _spiceLevel,
        'cuisinePreferences': _cuisinePreferences,
        'comfortDish': _comfortDishController.text,
        'breakfastPreference': _breakfastPreference,
        'hotDrinks': _hotDrinks,
        'otherHotDrink': _otherHotDrinkController.text,
        'vegetableMilk': _vegetableMilk,
        'needsSnacks': _needsSnacks,
        'comments': _commentsController.text,
      };

      // Envoyer le formulaire à l'API Laravel
      final response = await ApiService.post('food-comfort-form', formData);
      
      // Fermer le dialog de chargement
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Récupérer les identifiants depuis la réponse API
      String? userId;
      String? password;
      String? email;
      String? retreatPlanId;

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final userData = data['user'];
        userId = userData['id']?.toString() ?? userData['username'];
        password = userData['password'];
        email = userData['email'];
        retreatPlanId = data['retreat_plan_id']?.toString() ?? data['form']?['retreat_plan_id']?.toString();
      } else {
        // Générer des identifiants en fallback si l'API ne les retourne pas
        userId = 'USR${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        password = 'RET${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().year.toString().substring(2)}!';
        email = null;
        retreatPlanId = null;
      }

      // Naviguer vers la page de paiement avec les données du formulaire et les identifiants
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdvancedPaymentScreen(
              formData: formData,
              userId: userId ?? 'N/A',
              password: password ?? 'N/A',
              email: email,
              amount: 25.0,
              retreatPlanId: retreatPlanId ?? '1',
            ),
          ),
        );
      }
    } catch (e) {
      // Fermer le dialog en cas d'erreur
      if (mounted) {
        Navigator.of(context).pop();
        _showError('Erreur lors de l\'envoi du formulaire: $e');
      }
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
}

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

  /// Traite le paiement Stripe en utilisant Stripe Flutter SDK (mobile) ou API backend (web)
  Future<void> _processStripePayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Créer une intention de paiement côté serveur
      final email = (widget.email?.trim().isEmpty ?? true)
          ? 'user@example.com'
          : widget.email!;
      final intentResult = await _paymentService.createStripePaymentIntent(
        amount: widget.amount,
        currency: 'EUR',
        email: email,
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

      // 2. Sur mobile, utiliser Stripe Flutter SDK
      if (!kIsWeb) {
        Stripe.publishableKey = publishableKey;
        await Stripe.instance.applySettings();
        // Confirmer le paiement avec Stripe Flutter SDK
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'LASEV',
            customFlow: true,
          ),
        );

        // Montrer le formulaire de paiement Stripe
        await Stripe.instance.presentPaymentSheet();

        // Le paiement est confirmé localement; capturer côté serveur
        final captureResult = await _paymentService.captureStripePayment(
          paymentIntentId: clientSecret.split('_secret_')[0],
        );

        if (captureResult['success']) {
          // Enregistrer le paiement dans la base de données
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
          _showError('Erreur: ${captureResult['error']}');
        }
      } else {
        // 3. Sur web, utiliser Stripe.js avec WebView
        _showStripePaymentModal(clientSecret, publishableKey);
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Affiche un modal de paiement Stripe pour web
  void _showStripePaymentModal(String clientSecret, String publishableKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paiement Stripe'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: StripePaymentWidget(
              clientSecret: clientSecret,
              publishableKey: publishableKey,
              onSuccess: () {
                Navigator.of(context).pop();
                _captureAndRecordStripePayment(clientSecret);
              },
              onError: (error) {
                Navigator.of(context).pop();
                _showError('Erreur Stripe: $error');
              },
            ),
          ),
        );
      },
    );
  }

  /// Capture et enregistre le paiement Stripe après succès web
  Future<void> _captureAndRecordStripePayment(String clientSecret) async {
    try {
      final intentId = clientSecret.split('_secret_')[0];
      final captureResult = await _paymentService.captureStripePayment(
        paymentIntentId: intentId,
      );

      if (captureResult['success']) {
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
        _showError('Erreur capture: ${captureResult['error']}');
      }
    } catch (e) {
      _showError('Erreur: $e');
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
                        Container(
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
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payer avec Stripe',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                kIsWeb
                                    ? 'Sécurisé par Stripe'
                                    : 'Carte bancaire sécurisée',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
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
