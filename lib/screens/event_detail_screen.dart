import 'package:flutter/material.dart';
import '../widgets/video_background.dart';
import '../services/api_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  static const Color primaryColor = Color(0xFF265533);
  bool _showParticipationForm = false;
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getStatusColor() {
    switch (widget.event['status']) {
      case 'À venir':
        return 'green';
      case 'En cours':
        return 'orange';
      case 'Terminé':
        return 'red';
      case 'Reporté':
        return 'purple';
      default:
        return 'grey';
    }
  }

  String _getStatusIcon() {
    switch (widget.event['status']) {
      case 'À venir':
        return '📅';
      case 'En cours':
        return '🔴';
      case 'Terminé':
        return '✅';
      case 'Reporté':
        return '⏰';
      default:
        return '📋';
    }
  }

  void _submitParticipation() {
    if (_firstNameController.text.isNotEmpty && 
        _lastNameController.text.isNotEmpty && 
        _phoneController.text.isNotEmpty) {
      
      // Simuler la soumission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription à l\'événement réussie ! Nous vous contacterons bientôt.'),
          backgroundColor: primaryColor,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Vider les champs et fermer le formulaire
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      setState(() {
        _showParticipationForm = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> rawMedia = (widget.event['media'] as List?) ?? const [];
    final List<Map<String, dynamic>> media = rawMedia
        .where((m) => m is Map<String, dynamic>)
        .map((m) => m as Map<String, dynamic>)
        .toList();

    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.event['title']),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec statut
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor() == 'green' ? Colors.green :
                                        _getStatusColor() == 'orange' ? Colors.orange :
                                        _getStatusColor() == 'red' ? Colors.red :
                                        _getStatusColor() == 'purple' ? Colors.purple :
                                        Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getStatusIcon(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.event['status'] ?? 'Statut inconnu',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.event,
                            size: 40,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.event['title'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.event['date'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Icon(Icons.location_on, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.event['location'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.event['description'] ??
                          'Rejoignez-nous pour cet événement exceptionnel qui transformera votre approche du bien-être et du développement personnel. Une expérience immersive vous attend dans un cadre magnifique.',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Galerie d'images
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Galerie',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (media.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Aucune image de galerie pour le moment.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: media.length,
                              itemBuilder: (context, index) {
                                final item = media[index];
                                final String? path =
                                    (item['file_path'] ?? item['url'])?.toString();
                                if (path == null || path.trim().isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final String url = ApiService.mediaUrl(path) ?? path;

                                return Container(
                                  width: 180,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade200,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                      ),
                                      if (item['title'] != null &&
                                          (item['title'] as String).trim().isNotEmpty)
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                            child: Text(
                                              (item['title'] as String).trim(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Informations supplémentaires
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations pratiques',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.access_time, 'Durée', widget.event['duration'] ?? '3 heures'),
                        _buildInfoRow(Icons.people, 'Participants', '${widget.event['participants'] ?? 25} personnes'),
                        _buildInfoRow(Icons.euro, 'Tarif', widget.event['price'] ?? 'Gratuit'),
                        _buildInfoRow(Icons.phone, 'Contact', widget.event['contact'] ?? '+33 1 23 45 67 89'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Formulaire de participation (affiché conditionnellement)
                if (_showParticipationForm) ...[
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
                            'Formulaire d\'inscription',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'Prénom',
                              hintText: 'Entrez votre prénom',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person, color: primaryColor),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              hintText: 'Entrez votre nom',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              hintText: 'Entrez votre numéro de téléphone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.phone, color: primaryColor),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _submitParticipation,
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
                                    'Valider mon inscription',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showParticipationForm = false;
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
                
                // Bouton de participation
                if (!_showParticipationForm)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showParticipationForm = true;
                        });
                      },
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Participer à l\'événement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label :',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
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
