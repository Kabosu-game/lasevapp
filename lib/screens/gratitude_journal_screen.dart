import 'package:flutter/material.dart';
import '../widgets/video_background.dart';

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({super.key});

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  static const Color primaryColor = Color(0xFF265533);
  
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  
  List<List<String>> journalEntries = [];
  bool _showForm = false;

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    super.dispose();
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  void _saveEntry() {
    if (_firstController.text.isNotEmpty || 
        _secondController.text.isNotEmpty || 
        _thirdController.text.isNotEmpty) {
      
      setState(() {
        journalEntries.add([
          _firstController.text,
          _secondController.text,
          _thirdController.text,
        ]);
        _showForm = false; // Cacher le formulaire après sauvegarde
      });
      
      // Vider les champs
      _firstController.clear();
      _secondController.clear();
      _thirdController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal de gratitude enregistré avec succès!'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Journal de gratitude'),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            // Contenu principal
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Journal de gratitude',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ecrivez trois choses qui vous sont arrivées aujourd\'hui ou pour lesquelles vous vous sentez reconnaissant(e)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Formulaire (affiché conditionnellement)
                    if (_showForm) ...[
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Qu\'est-ce qui vous a apporté de la joie aujourd\'hui ?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Champ 1
                              TextField(
                                controller: _firstController,
                                decoration: InputDecoration(
                                  labelText: 'Première chose positive',
                                  hintText: 'Une chose pour laquelle vous êtes reconnaissant(e)...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.star, color: primaryColor),
                                ),
                                maxLines: 2,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Champ 2
                              TextField(
                                controller: _secondController,
                                decoration: InputDecoration(
                                  labelText: 'Deuxième chose positive',
                                  hintText: 'Une autre chose qui vous a fait sourire...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.favorite, color: primaryColor),
                                ),
                                maxLines: 2,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Champ 3
                              TextField(
                                controller: _thirdController,
                                decoration: InputDecoration(
                                  labelText: 'Troisième chose positive',
                                  hintText: 'Un moment de bonheur ou de paix...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.sentiment_very_satisfied, color: primaryColor),
                                ),
                                maxLines: 2,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Boutons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saveEntry,
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
                                        'Valider mon journal',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showForm = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Annuler'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                    
                    // Historique des entrées (visible seulement pour l'utilisateur)
                    if (journalEntries.isNotEmpty) ...[
                      const Text(
                        'Mon journal de gratitude',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...journalEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final entries = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: primaryColor.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getTodayDate(),
                                      style: TextStyle(
                                        color: primaryColor.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (entries[0].isNotEmpty)
                                  _buildGratitudeItem('1️⃣', entries[0]),
                                if (entries[1].isNotEmpty)
                                  _buildGratitudeItem('2️⃣', entries[1]),
                                if (entries[2].isNotEmpty)
                                  _buildGratitudeItem('3️⃣', entries[2]),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    
                    // Message si aucune entrée
                    if (journalEntries.isEmpty && !_showForm) ...[
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Commencez votre journal de gratitude',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appuyez sur le bouton + en bas pour ajouter votre première entrée',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Bouton flottant pour ajouter une entrée
            if (!_showForm)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      _showForm = true;
                    });
                  },
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  elevation: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGratitudeItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
