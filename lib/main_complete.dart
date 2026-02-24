import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'services/meditation_service.dart';
import 'providers/meditation_provider.dart';
import 'providers/user_profile_provider.dart';

void main() {
  runApp(const MeditationApp());
}

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreenComplete(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreenComplete extends StatelessWidget {
  const HomeScreenComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation App'),
        backgroundColor: const Color(0xFF265533),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section principale
            const Text(
              'Découvrez',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF265533),
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid des catégories
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildCategoryCard('Affirmation', Icons.favorite, Colors.purple),
                _buildCategoryCard('Meditation', Icons.self_improvement, Colors.blue),
                _buildCategoryCard('Le pouvoir secret', Icons.auto_awesome, Colors.amber),
                _buildCategoryCard('Evenement', Icons.event, Colors.orange),
                _buildCategoryCard('Cuisine', Icons.restaurant, Colors.green),
                _buildCategoryCard('Plus', Icons.add, Colors.grey),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section citations quotidiennes
            _buildSection('Citation du jour', 'La paix commence par un sourire'),
            
            const SizedBox(height: 24),
            
            // Section affirmations
            _buildSection('Affirmations', 'Je suis capable, je suis fort, je suis confiant'),
            
            const SizedBox(height: 24),
            
            // Section activités
            _buildSection('Activités', 'Méditation guidée, Yoga, Respiration'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        _handleCategoryTap(name);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF265533).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF265533).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF265533),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCategoryTap(String category) {
    // Navigation directe selon la catégorie
    switch (category) {
      case 'Affirmation':
        // Navigation directe vers les catégories d'affirmations
        break;
      case 'Meditation':
        // Navigation directe vers les audios/vidéos
        break;
      case 'Le pouvoir secret':
        // Navigation vers les articles détaillés
        break;
      case 'Evenement':
        // Navigation vers les événements
        break;
      default:
        // Navigation normale
        break;
    }
  }
}
