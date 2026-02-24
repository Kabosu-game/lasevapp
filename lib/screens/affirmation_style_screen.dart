import 'package:flutter/material.dart';
import '../widgets/video_background.dart';

class AffirmationStyleScreen extends StatefulWidget {
  const AffirmationStyleScreen({super.key});

  @override
  State<AffirmationStyleScreen> createState() => _AffirmationStyleScreenState();
}

class _AffirmationStyleScreenState extends State<AffirmationStyleScreen> {
  // Couleur principale du projet
  static const Color primaryColor = Color(0xFF265533);

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Style des cartes'),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Styles de cartes en haut
                const Text(
                  'Choisissez le style de vos cartes d\'affirmations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Styles de cartes
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildStyleCard(index);
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Section Prédefinies et Favoris en bas
                const Text(
                  'Collections',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildCollectionButton(
                        'Prédefinies',
                        Icons.list,
                        Colors.blue,
                        () => _navigateToPredefinedCategories(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCollectionButton(
                        'Favoris',
                        Icons.favorite,
                        Colors.red,
                        () => _navigateToFavorites(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleCard(int index) {
    final List<String> styleNames = [
      'Classique',
      'Moderne',
      'Nature',
      'Spirituel',
    ];
    
    final List<Color> styleColors = [
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
    ];

    return InkWell(
      onTap: () {
        // Logique pour sélectionner le style
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Style "${styleNames[index]}" sélectionné'),
            backgroundColor: primaryColor,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: styleColors[index],
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      styleColors[index],
                      styleColors[index].withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _getStyleIcon(index),
                  size: 60,
                  color: primaryColor,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  styleNames[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStyleIcon(int index) {
    final List<IconData> icons = [
      Icons.style,
      Icons.blur_on,
      Icons.nature,
      Icons.self_improvement,
    ];
    return icons[index];
  }

  void _navigateToPredefinedCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AffirmationCategoriesScreen(),
      ),
    );
  }

  void _navigateToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favoris - Fonctionnalité à venir'),
        backgroundColor: primaryColor,
      ),
    );
  }
}

class AffirmationCategoriesScreen extends StatelessWidget {
  const AffirmationCategoriesScreen({super.key});

  static const Color primaryColor = Color(0xFF265533);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Confiance en soi',
        'description': 'Renforcez votre estime personnelle',
        'count': 15,
        'color': Colors.blue,
      },
      {
        'name': 'Paix intérieure',
        'description': 'Trouvez la sérénité et le calme',
        'count': 12,
        'color': Colors.green,
      },
      {
        'name': 'Abondance',
        'description': 'Attirez la prospérité et le succès',
        'count': 18,
        'color': Colors.purple,
      },
      {
        'name': 'Santé',
        'description': 'Affirmations pour le bien-être',
        'count': 10,
        'color': Colors.red,
      },
      {
        'name': 'Amour',
        'description': 'Cultivez l\'amour et les relations',
        'count': 14,
        'color': Colors.pink,
      },
      {
        'name': 'Réussite',
        'description': 'Atteignez vos objectifs',
        'count': 16,
        'color': Colors.orange,
      },
    ];

    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Catégories d\'affirmations'),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: (category['color'] as Color).withOpacity(0.1),
        border: Border.all(color: (category['color'] as Color).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: category['color'] as Color,
              ),
              child: Icon(
                Icons.category,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${category['count']} affirmations',
                    style: TextStyle(
                      fontSize: 12,
                      color: category['color'] as Color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AffirmationCardsScreen(
                      categoryName: category['name'] as String,
                      categoryColor: category['color'] as Color,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: category['color'] as Color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Manifester'),
            ),
          ],
        ),
      ),
    );
  }
}

class AffirmationCardsScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;

  const AffirmationCardsScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
  });

  static const Color primaryColor = Color(0xFF265533);

  @override
  Widget build(BuildContext context) {
    final List<String> affirmations = _getAffirmationsForCategory(categoryName);

    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(categoryName),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          child: PageView.builder(
            itemCount: affirmations.length,
            itemBuilder: (context, index) {
              return _buildAffirmationCard(affirmations[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAffirmationCard(String affirmation) {
    return Container(
      margin: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            categoryColor,
            categoryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 32),
            Text(
              affirmation,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // Logique pour favoriser
                  },
                  icon: const Icon(Icons.favorite_border),
                  color: Colors.white,
                  iconSize: 30,
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    // Logique pour partager
                  },
                  icon: const Icon(Icons.share),
                  color: Colors.white,
                  iconSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAffirmationsForCategory(String category) {
    switch (category) {
      case 'Confiance en soi':
        return [
          'Je suis confiant(e) et capable de réaliser tout ce que je désire.',
          'Ma confiance en moi grandit chaque jour.',
          'Je mérite le succès et je l\'attire dans ma vie.',
          'Je suis unique et précieux(se) tel(le) que je suis.',
          'Je fais confiance à mes capacités et à mon intuition.',
        ];
      case 'Paix intérieure':
        return [
          'Je suis en paix avec moi-même et avec le monde.',
          'La paix intérieure habite en moi en tout temps.',
          'Je libère toutes les tensions et je trouve la sérénité.',
          'Mon esprit est calme et mon cœur est en paix.',
          'Je choisis la paix dans chaque pensée et chaque action.',
        ];
      case 'Abondance':
        return [
          'Je suis un aimant à l\'abondance et à la prospérité.',
          'L\'univers pourvoit à tous mes besoins au-delà de mes attentes.',
          'Je suis ouvert(e) et réceptif(ve) à l\'abondance infinie.',
          'La richesse coule vers moi de multiples façons.',
          'Je mérite d\'abonder dans tous les aspects de ma vie.',
        ];
      case 'Santé':
        return [
          'Mon corps est en parfaite santé et pleine vitalité.',
          'Je nourris mon corps avec des aliments sains et bénéfiques.',
          'Chaque cellule de mon corps vibre de santé et d\'énergie.',
          'Je suis reconnaissant(e) pour la santé parfaite de mon corps.',
          'Mon corps guérit et se régénère naturellement.',
        ];
      case 'Amour':
        return [
          'Je suis digne d\'aimer et d\'être aimé(e) inconditionnellement.',
          'L\'amour coule vers moi et à travers moi librement.',
          'J\'attire des relations aimantes et harmonieuses.',
          'Mon cœur est ouvert et je donne et reçois l\'amour librement.',
          'Je suis entouré(e) d\'amour et de tendresse.',
        ];
      case 'Réussite':
        return [
          'Je suis destiné(e) à réussir dans tout ce que j\'entreprends.',
          'Le succès vient naturellement vers moi.',
          'Je surmonte tous les obstacles avec facilité et grâce.',
          'Mes efforts sont toujours couronnés de succès.',
          'Je suis une personne réussie et je continue à grandir.',
        ];
      default:
        return [
          'Je suis capable de grandes choses.',
          'Je mérite le meilleur dans la vie.',
          'Je suis reconnaissant(e) pour chaque jour.',
        ];
    }
  }
}
