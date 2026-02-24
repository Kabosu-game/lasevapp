import 'package:flutter/material.dart';
import '../widgets/video_background.dart';
import 'retreat_form_screen.dart';
import '../services/retreat_plan_service.dart';

class RetreatsScreen extends StatefulWidget {
  const RetreatsScreen({super.key});

  @override
  State<RetreatsScreen> createState() => _RetreatsScreenState();
}

class _RetreatsScreenState extends State<RetreatsScreen> {
  static const Color primaryColor = Color(0xFF265533);
  final RetreatPlanService _retreatPlanService = RetreatPlanService();
  List<RetreatPlan> _retreats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRetreats();
  }

  Future<void> _loadRetreats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final retreats = await _retreatPlanService.getRetreatPlans();
      
      setState(() {
        _retreats = retreats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback sur les données statiques si l'API échoue
    final List<Map<String, dynamic>> fallbackRetreats = [
      {
        'name': 'Full Recovery',
        'duration': '14 jours',
        'price': 'Sur demande',
        'image': 'assets/images/retreat1.jpg',
        'description': 'Ce plan offre aux participants un full recovery dans les problèmes subtils',
        'details': [
          'Accompagnés par TAR, avec des soins sur mesure',
          'Un programme détaillé du matin jusqu\'au soir',
          'Des activités spirituelles incluses',
          'Un chef de cuisine privé',
        ],
        'highlights': [
          'Soins personnalisés',
          'Programme complet',
          'Spiritualité',
          'Cuisine privée',
        ],
      },
      {
        'name': 'L\'Éveil des Sens et de l\'Âme',
        'duration': '14 jours',
        'price': 'Sur demande',
        'image': 'assets/images/retreat2.jpg',
        'description': 'Une immersion de 14 jours dans un espace ZEN où le confort matériel sert de catalyseur à la libération émotionnelle',
        'details': [
          'Espace ZEN en pleine nature',
          'Confort matériel optimal',
          'Libération émotionnelle',
          'Immersion totale',
        ],
        'highlights': [
          'Espace ZEN',
          'Confort',
          'Libération',
          'Immersion',
        ],
      },
      {
        'name': 'Architecture de l\'Être',
        'duration': '14 jours',
        'price': 'Sur demande',
        'image': 'assets/images/retreat3.jpg',
        'description': 'Un programme structuré autour de 3 piliers pour transformer votre être',
        'details': [
          'Pilier I: Libération du Passé (Jour 1-5)',
          'Pilier II: Alchimie Émotionnelle (Jour 6-9)',
          'Pilier III: Expansion et Manifestation (Jour 10-14)',
          'Accompagnement personnalisé',
        ],
        'highlights': [
          '3 piliers',
          'Transformation',
          'Accompagnement',
          'Résultats',
        ],
      },
    ];

    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Plans de Retraite'),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRetreats,
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : _error != null && _retreats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadRetreats,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Réessayer'),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Affichage des données locales',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: fallbackRetreats.length,
                              itemBuilder: (context, index) {
                                final retreat = fallbackRetreats[index];
                                return _buildRetreatCard(context, retreat);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : _retreats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.spa_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun plan de retraite disponible',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loadRetreats,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Actualiser'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRetreats,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _retreats.length,
                            itemBuilder: (context, index) {
                              final retreat = _retreats[index];
                              return _buildRetreatCard(context, _convertRetreatPlanToMap(retreat));
                            },
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildRetreatCard(BuildContext context, Map<String, dynamic> retreat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.spa,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      retreat['duration'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        retreat['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        retreat['price'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  retreat['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Details list
                ...retreat['details'].map<Widget>((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                
                const SizedBox(height: 20),
                
                // Highlights chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: retreat['highlights'].map<Widget>((highlight) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        highlight,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 20),
                
                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showRetreatDetails(context, retreat);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Voir les détails complets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _convertRetreatPlanToMap(RetreatPlan retreat) {
    return {
      'name': retreat.title,
      'duration': retreat.duration,
      'price': retreat.priceDisplay,
      'image': retreat.coverImage,
      'description': retreat.description,
      'details': retreat.features ?? [],
      'highlights': retreat.tags ?? [],
    };
  }

  void _showRetreatDetails(BuildContext context, Map<String, dynamic> retreat) {
    // Naviguer directement vers le formulaire au lieu de la page de détails
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RetreatFormScreen(
          retreatName: retreat['name'],
          retreatDates: retreat['duration'],
        ),
      ),
    );
  }
}
