import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meditation.dart';
import '../providers/meditation_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/video_background.dart';
import 'affirmation_style_screen.dart';
import 'retreats_screen.dart';
import 'cuisine_screen.dart';
import 'gratitude_journal_screen.dart';
import 'event_detail_screen.dart';
import 'login_screen.dart';
import '../screens/meditation_detail_screen.dart';
import '../services/api_service.dart';
import '../services/blog_service.dart';
import '../services/event_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Couleur principale du projet
  static const Color primaryColor = Color(0xFF265533);

  // Slug des menus (ordre fixe) — nom et image viennent de l'API (home-menu-items)
  static const List<String> _categorySlugs = [
    'affirmation', 'meditation', 'articles', 'gratitude', 'events', 'retreats', 'cuisine',
  ];
  // Structure de base : type + content (navigation). Nom et image sont mergés depuis l'API.
  final List<Map<String, dynamic>> _baseCategories = [
    {
      'slug': 'affirmation',
      'name': 'Affirmation',
      'image': 'assets/images/logotar.png',
      'type': 'phrases',
      'content': [
        'Je suis capable de surmonter tous les défis.',
        'Je mérite le bonheur et le succès.',
        'Ma force intérieure grandit chaque jour.',
        'Je choisis la paix et la sérénité.',
        'Je suis reconnaissant(e) pour tout ce que j\'ai.',
      ],
    },
    {
      'slug': 'meditation',
      'name': 'Meditation',
      'image': 'assets/images/logotar.png',
      'type': 'media',
      'content': [
        {'title': 'Méditation guidée 10 min', 'type': 'audio', 'duration': '10:00'},
        {'title': 'Respiration profonde', 'type': 'video', 'duration': '15:00'},
        {'title': 'Scan corporel', 'type': 'audio', 'duration': '20:00'},
      ],
    },
    {
      'slug': 'articles',
      'name': 'Le pouvoir secret',
      'image': 'assets/images/logotar.png',
      'type': 'articles',
      'content': [
        {
          'title': 'La loi de l\'attraction : Le pouvoir de vos pensées',
          'excerpt': 'Découvrez comment vos pensées créent votre réalité et comment utiliser la loi de l\'attraction',
          'content': 'La loi de l\'attraction est l\'une des lois les plus puissantes de l\'univers. Elle stipule que vos pensées et émotions attirent des expériences similaires dans votre vie. En cultivant des pensées positives et en vous concentrant sur ce que vous désirez, vous pouvez manifester vos rêves et transformer votre réalité.',
          'hasVideo': true,
          'readTime': '8 min',
          'views': 3421,
          'tags': ['loi de l\'attraction', 'pensées', 'réalité', 'manifestation'],
        },
        {
          'title': 'Le secret de la manifestation',
          'excerpt': 'Les techniques avancées pour manifester vos désirs les plus profonds',
          'content': 'La manifestation est un art qui demande pratique et compréhension. Découvrez les techniques utilisées par les plus grands maîtres spirituels pour attirer l\'abondance, l\'amour et le succès dans votre vie. Apprenez à aligner vos vibrations avec vos désirs.',
          'hasVideo': false,
          'readTime': '12 min',
          'views': 2876,
          'tags': ['manifestation', 'désirs', 'techniques', 'abondance'],
        },
        {
          'title': 'Le pouvoir de la gratitude',
          'excerpt': 'Comment la gratitude transforme votre vie et attire plus de bonheur',
          'content': 'La gratitude est l\'un des secrets les plus puissants pour attirer le bonheur et l\'abondance. En pratiquant régulièrement la gratitude, vous changez votre perspective et ouvrez la porte à plus de bénédictions dans votre vie.',
          'hasVideo': true,
          'readTime': '6 min',
          'views': 1987,
          'tags': ['gratitude', 'bonheur', 'transformation', 'bénédictions'],
        },
        {
          'title': 'La vibration de l\'abondance',
          'excerpt': 'Comment élever votre fréquence vibratoire pour attirer la prospérité',
          'content': 'L\'univers fonctionne sur des fréquences vibratoires. Découvrez comment élever votre vibration pour attirer naturellement l\'abondance financière, les opportunités et les relations harmonieuses dans votre existence.',
          'hasVideo': false,
          'readTime': '10 min',
          'views': 1654,
          'tags': ['vibration', 'abondance', 'fréquence', 'prospérité'],
        },
        {
          'title': 'Le pouvoir du subconscient',
          'excerpt': 'Programmez votre esprit pour le succès et le bonheur durable',
          'content': 'Votre subconscient contrôle 95% de vos actions et décisions. Apprenez à reprogrammer vos croyances limitantes pour créer automatiquement le succès et le bonheur dans tous les aspects de votre vie.',
          'hasVideo': true,
          'readTime': '15 min',
          'views': 2234,
          'tags': ['subconscient', 'programmation', 'succès', 'croyances'],
        },
      ],
    },
    {
      'slug': 'gratitude',
      'name': 'Gratitude',
      'image': 'assets/images/logotar.png',
      'type': 'gratitude_journal',
      'content': [],
    },
    {
      'slug': 'events',
      'name': 'Evenement',
      'image': 'assets/images/logotar.png',
      'type': 'events',
      'content': [
        {
          'title': 'Retraite méditation 3 jours',
          'date': '15-17 Mars 2024',
          'location': 'Montagne sacrée',
          'status': 'À venir',
          'description': 'Une retraite immersive de 3 jours dans un cadre naturel exceptionnel. Pratiquez la méditation, le yoga et la respiration consciente avec des experts internationaux.',
          'duration': '3 jours',
          'participants': 25,
          'price': '450€',
          'contact': '+33 1 23 45 67 89',
        },
        {
          'title': 'Atelier respiration',
          'date': '25 Mars 2024',
          'location': 'Centre de bien-être',
          'status': 'En cours',
          'description': 'Apprenez les techniques de respiration avancées pour réduire le stress et améliorer votre concentration. Atelier pratique de 2 heures.',
          'duration': '2 heures',
          'participants': 15,
          'price': '30€',
          'contact': '+33 1 23 45 67 89',
        },
        {
          'title': 'Soirée bien-être',
          'date': '10 Mars 2024',
          'location': 'Spa urbain',
          'status': 'Terminé',
          'description': 'Une soirée de détente avec massages, méditation guidée et tisanes bio. Moment de relaxation profonde.',
          'duration': '4 heures',
          'participants': 30,
          'price': '60€',
          'contact': '+33 1 23 45 67 89',
        },
        {
          'title': 'Séminaire développement personnel',
          'date': '5 Avril 2024',
          'location': 'Salle de conférence',
          'status': 'Reporté',
          'description': 'Séminaire intensif sur le développement personnel et la manifestation de vos objectifs. Avec coach certifié.',
          'duration': '1 journée',
          'participants': 50,
          'price': '120€',
          'contact': '+33 1 23 45 67 89',
        },
      ],
    },
    {
      'slug': 'retreats',
      'name': 'Plan de retraite',
      'image': 'assets/images/logotar.png',
      'type': 'retreats',
      'content': [],
    },
    {
      'slug': 'cuisine',
      'name': 'Cuisine',
      'image': 'assets/images/logotar.png',
      'type': 'cuisine',
      'content': [],
    },
  ];

  // Menus page d'accueil (nom + image par section, depuis l'API)
  Map<String, Map<String, dynamic>> _homeMenuItems = {};

  // Données dynamiques depuis l'API
  List<Map<String, dynamic>> _blogArticles = [];
  bool _isLoadingBlogArticles = false;

  List<Map<String, dynamic>> _events = [];
  bool _isLoadingEvents = false;

  // Phrases du jour (chargées depuis l'API, modifiables dans l'admin)
  static const List<String> _defaultDailyQuotes = [
    'La paix intérieure commence par le sourire de l\'âme.',
    'Chaque jour est une nouvelle opportunité de grandir.',
    'La gratitude transforme ce que nous avons en suffisance.',
  ];
  List<String> _dailyQuotes = List.from(_defaultDailyQuotes);

  int currentQuoteIndex = 0;
  DateTime? lastQuoteChange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeQuoteIndex();
    _startQuoteRotation();
    _loadAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Rafraîchir les données quand l'app revient au premier plan (ex: après modification dans l'admin)
    if (state == AppLifecycleState.resumed && mounted) {
      _loadAllData();
    }
  }

  /// Charge méditations, blogs, événements, phrases du jour, menus accueil (appelé au démarrage, au retour app, et au pull-to-refresh)
  void _loadAllData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MeditationProvider>().fetchMeditations();
      context.read<UserProfileProvider>().loadUserProfile();
      _loadBlogArticles();
      _loadEvents();
      _loadDailyQuotes();
      _loadHomeMenuItems();
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    await context.read<MeditationProvider>().fetchMeditations();
    if (!mounted) return;
    await _loadBlogArticles();
    if (!mounted) return;
    await _loadEvents();
    if (!mounted) return;
    await _loadDailyQuotes();
    if (!mounted) return;
    await _loadHomeMenuItems();
  }

  Future<void> _loadHomeMenuItems() async {
    try {
      final response = await ApiService.get('home-menu-items');
      if (!mounted) return;
      if (response is List) {
        final map = <String, Map<String, dynamic>>{};
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            final slug = item['slug']?.toString();
            if (slug == null || slug.isEmpty) continue;
            String? imageUrl = item['image']?.toString()?.replaceAll(r'\', '/');
            if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
              imageUrl = '${ApiService.imageBaseUrl}/serve-storage/${imageUrl.trim()}';
            }
            map[slug] = {
              'name': item['name']?.toString() ?? '',
              'imageUrl': imageUrl,
            };
          }
        }
        setState(() {
          _homeMenuItems = map;
        });
      }
    } catch (_) {}
  }

  /// Catégories affichées : base mergée avec les données API (nom + image)
  List<Map<String, dynamic>> get _displayCategories {
    return _baseCategories.map((base) {
      final slug = base['slug'] as String?;
      final fromApi = slug != null ? _homeMenuItems[slug] : null;
      return {
        ...base,
        'name': fromApi?['name'] ?? base['name'],
        'image': base['image'],
        'imageUrl': fromApi?['imageUrl'],
      };
    }).toList();
  }

  Future<void> _loadDailyQuotes() async {
    try {
      // Envoyer la date locale pour que l'API renvoie les phrases du "jour" de l'utilisateur
      final now = DateTime.now();
      final dateParam = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final response = await ApiService.get('daily-quote/today?date=$dateParam');
      if (!mounted) return;
      if (response is Map && response['data'] != null) {
        final raw = response['data']['quotes'];
        List<String> parsed = [];
        if (raw is List) {
          parsed = raw.map((e) => e?.toString() ?? '').take(3).toList();
        } else if (raw is Map) {
          for (int i = 0; i < 3; i++) {
            final v = raw[i] ?? raw['$i'];
            parsed.add(v?.toString() ?? '');
          }
        }
        if (parsed.length >= 3) {
          setState(() {
            _dailyQuotes = parsed;
          });
        }
      }
    } catch (e) {
      // En cas d'erreur, garder les phrases actuelles (déjà chargées ou par défaut)
    }
  }

  void _initializeQuoteIndex() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Déterminer l'index basé sur l'heure actuelle
    if (hour < 12) {
      // 00:00 - 11:59 : Première phrase
      currentQuoteIndex = 0;
    } else if (hour < 23) {
      // 12:00 - 22:59 : Deuxième phrase
      currentQuoteIndex = 1;
    } else {
      // 23:00 - 23:59 : Troisième phrase
      currentQuoteIndex = 2;
    }
    
    lastQuoteChange = DateTime(now.year, now.month, now.day, hour >= 23 ? 23 : (hour >= 12 ? 12 : 0), 0, 0);
  }

  void _startQuoteRotation() {
    // Vérifier toutes les minutes si on doit changer la phrase
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _checkAndUpdateQuote();
        _startQuoteRotation();
      }
    });
  }

  Future<void> _loadBlogArticles() async {
    setState(() {
      _isLoadingBlogArticles = true;
    });
    try {
      print('🟡 Chargement des blogs depuis l\'API avec filtre pouvoir-secret...');
      final service = BlogService();
      // Charger uniquement les articles de la catégorie "pouvoir-secret"
      final blogs = await service.getBlogs(category: 'pouvoir-secret');
      print('🟢 ${blogs.length} blogs chargés depuis l\'API');
      if (!mounted) return;
      setState(() {
        _blogArticles = blogs
            .map((b) => {
                  'title': b.title,
                  'excerpt': b.description ?? '',
                  'author': b.authorName ?? 'Admin',
                  'date': b.formattedDate,
                  'readTime': '5 min',
                  'likes': 0,
                  'content': b.body,
                  'hasVideo': b.media != null && b.media!.isNotEmpty,
                  'tags': b.category != null ? [b.category!] : [],
                })
            .toList();
      });
    } catch (e) {
      print('🔴 Erreur lors du chargement des blogs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement blogs: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBlogArticles = false;
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
    });
    try {
      print('🟡 Chargement des événements depuis l\'API...');
      final service = EventService();
      final apiEvents = await service.getEvents();
      print('🟢 ${apiEvents.length} événements chargés depuis l\'API');
      if (!mounted) return;
      setState(() {
        _events = apiEvents
            .map((e) => {
                  'title': e.title,
                  'date': e.formattedDate,
                  'location': e.location ?? '',
                  'status': e.status ?? 'À venir',
                  'description': e.description ?? '',
                  'duration': '—',
                  'participants': null,
                  'price': e.price != null
                      ? '${e.price!.toStringAsFixed(0)}€'
                      : 'Gratuit',
                  'contact': '',
                })
            .toList();
      });
    } catch (e) {
      print('🔴 Erreur lors du chargement des événements: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement événements: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEvents = false;
        });
      }
    }
  }

  void _checkAndUpdateQuote() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Heures de changement : 00:00, 12:00, 23:59
    final changeTimes = [
      DateTime(today.year, today.month, today.day, 0, 0, 0),
      DateTime(today.year, today.month, today.day, 12, 0, 0),
      DateTime(today.year, today.month, today.day, 23, 59, 0),
    ];
    
    // Trouver le prochain changement de phrase
    DateTime? nextChange;
    int nextIndex = 0;
    
    for (int i = 0; i < changeTimes.length; i++) {
      if (now.isBefore(changeTimes[i]) || now.isAtSameMomentAs(changeTimes[i])) {
        nextChange = changeTimes[i];
        nextIndex = i;
        break;
      }
    }
    
    // Si on a dépassé toutes les heures d'aujourd'hui, on prend la première de demain
    if (nextChange == null) {
      final tomorrow = today.add(const Duration(days: 1));
      nextChange = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0, 0);
      nextIndex = 0;
    }
    
    // Vérifier si on doit changer la phrase maintenant
    if (lastQuoteChange != null && now.isAfter(nextChange)) {
      setState(() {
        currentQuoteIndex = nextIndex;
        lastQuoteChange = nextChange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Consumer<UserProfileProvider>(
            builder: (context, userProvider, child) {
              return Row(
                children: [
                  Image.asset(
                    'assets/images/logotar.png',
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(userProvider.userProfile?.name ?? 'Bienvenue'),
                ],
              );
            },
          ),
          backgroundColor: primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // (Connexion button removed here; login accessible via menu)
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () => _showAppsMenu(context),
              tooltip: 'Plus d\'applications',
            ),
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: () => _showPremiumDialog(context),
              tooltip: 'Abonnements premium',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _shareApp();
                    break;
                  case 'privacy':
                    _showPrivacyPolicy();
                    break;
                  case 'rate':
                    _rateApp();
                      break;
                    case 'login':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                      break;
                    case 'logout':
                      _showLogoutConfirmation();
                      break;
                  }
                },
                itemBuilder: (context) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  return [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Partager l\'app'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'privacy',
                      child: Row(
                        children: [
                          Icon(Icons.privacy_tip),
                          SizedBox(width: 8),
                          Text('Politique de confidentialité'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'rate',
                      child: Row(
                        children: [
                          Icon(Icons.star_rate),
                          SizedBox(width: 8),
                          Text('Évaluer notre app'),
                        ],
                      ),
                    ),
                    if (!authProvider.isLoggedIn)
                      const PopupMenuItem(
                        value: 'login',
                        child: Row(
                          children: [
                            Icon(Icons.login),
                            SizedBox(width: 8),
                            Text('Connexion'),
                          ],
                        ),
                      ),
                    if (authProvider.isLoggedIn)
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Déconnexion'),
                          ],
                        ),
                      ),
                  ];
                },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
          ),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section catégories 2 par ligne sans images
                _buildCategoriesSection(),
                
                const SizedBox(height: 24),
                
                // Section phrase du jour qui défile
                _buildDailyQuoteSection(),
                
                const SizedBox(height: 24),
                
                // Section affirmations avec logo et bouton
                _buildAffirmationsSection(),
                
                const SizedBox(height: 24),
                
                // Section nos activités
                _buildActivitiesSection(),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _categoryPlaceholder() {
    return Container(
      color: primaryColor.withOpacity(0.15),
      child: Icon(
        Icons.category,
        size: 36,
        color: primaryColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Découvrez nos catégories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _displayCategories.length,
          itemBuilder: (context, index) {
            final category = _displayCategories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return InkWell(
      onTap: () => _navigateToCategory(category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image de la catégorie
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: primaryColor.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: (category['imageUrl'] != null && (category['imageUrl'] as String).isNotEmpty)
                      ? Image.network(
                          category['imageUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _categoryPlaceholder(),
                        )
                      : Image.asset(
                          category['image'] as String? ?? 'assets/images/logotar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _categoryPlaceholder(),
                        ),
                ),
              ),
            ),
            // Nom de la catégorie
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category['name'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.8), primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phrase du jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              currentQuoteIndex < _dailyQuotes.length
                  ? _dailyQuotes[currentQuoteIndex]
                  : _defaultDailyQuotes[currentQuoteIndex.clamp(0, 2)],
              key: ValueKey(currentQuoteIndex),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffirmationsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Logo à gauche
          Image.asset(
            'assets/images/logotar.png',
            height: 50,
            width: 50,
          ),
          const SizedBox(width: 16),
          // Texte et bouton à droite
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Affirmations positives',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _navigateToAffirmationStyle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Choisir le style'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    // Articles de blog publiés par l'admin depuis l'API
    final blogArticles = _blogArticles;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Blog',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Naviguer vers tous les articles du blog
                  _showAllBlogArticles();
                },
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Articles publiés par l\'admin pour vous inspirer et vous guider dans votre voyage de bien-être.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoadingBlogArticles)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ))
          else if (blogArticles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Aucun article pour le moment.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            // Articles défilants horizontalement
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: blogArticles.length,
                itemBuilder: (context, index) {
                  final article = blogArticles[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          _showBlogArticle(article);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre
                              Text(
                                article['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Extrait
                              Text(
                                article['excerpt'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),

                              // Métadonnées
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    article['author'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.schedule,
                                      size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    article['readTime'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    article['date'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.favorite,
                                          size: 14,
                                          color: Colors.red.shade400),
                                      const SizedBox(width: 4),
                                      Text(
                                        article['likes'].toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showBlogArticle(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(article['title']),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec métadonnées
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              article['author'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.favorite, color: Colors.red.shade400),
                            const SizedBox(width: 4),
                            Text(
                              article['likes'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(article['readTime']),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(article['date']),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contenu de l'article
                  const Text(
                    'Contenu de l\'article',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    article['excerpt'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Contenu simulé
                  const Text(
                    'Introduction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Bienvenue dans cet article inspirant qui va vous guider dans votre voyage de bien-être et de développement personnel. Ici, nous explorons des pratiques et des techniques qui peuvent transformer votre vie quotidienne.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Les bienfaits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Les pratiques que nous partageons ici ont été testées et validées par des milliers de personnes à travers le monde. Elles peuvent vous aider à:\n\n• Réduire le stress et l\'anxiété\n• Améliorer votre concentration\n• Développer votre confiance en vous\n• Atteindre un état de paix intérieure\n• Manifestez vos rêves et aspirations',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Comment pratiquer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Pour intégrer ces pratiques dans votre vie, nous vous recommandons de commencer progressivement. Consacrez quelques minutes chaque jour à ces exercices. La régularité est la clé du succès. Soyez patient et bienveillant avec vous-même.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Article ajouté aux favoris!'),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                          icon: const Icon(Icons.favorite),
                          label: const Text('Ajouter aux favoris'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lien copié!'),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Partager'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor),
                            foregroundColor: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAllBlogArticles() {
    final List<Map<String, dynamic>> allArticles = _blogArticles;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Tous les articles du blog'),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allArticles.length,
              itemBuilder: (context, index) {
                final article = allArticles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _showBlogArticle(article),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article['excerpt'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                article['author'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                article['readTime'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                article['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAffirmationStyle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AffirmationStyleScreen(),
      ),
    );
  }

  void _navigateToCategory(Map<String, dynamic> category) {
    switch (category['type']) {
      case 'phrases':
        _navigateToAffirmationStyle();
        break;
      case 'media':
        _showMeditationMedia(category);
        break;
      case 'articles':
        _showArticles(category);
        break;
      case 'events':
        _showEvents(category);
        break;
      case 'retreats':
        _showRetreats(category);
        break;
      case 'cuisine':
        _showCuisine(category);
        break;
      case 'gratitude_journal':
        _showGratitudeJournal(category);
        break;
      default:
        _showCategoryContent(category);
        break;
    }
  }

  void _showAffirmationCategories(Map<String, dynamic> category) {
    // Afficher les 14 catégories d'affirmations
    final affirmationCategories = [
      'Confiance en soi', 'Paix intérieure', 'Amour-propre', 'Santé',
      'Abondance', 'Succès', 'Bonheur', 'Sérénité', 'Force', 'Courage',
      'Gratitude', 'Espoir', 'Harmonie', 'Équilibre',
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(category['name']),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: affirmationCategories.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _showAffirmationPhrases(affirmationCategories[index]),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.purple.withOpacity(0.1),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      affirmationCategories[index],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAffirmationPhrases(String categoryName) {
    final phrases = [
      'Je suis capable de surmonter tous les défis.',
      'Je mérite le bonheur et le succès.',
      'Ma force intérieure grandit chaque jour.',
      'Je choisis la paix et la sérénité.',
      'Je suis reconnaissant(e) pour tout ce que j\'ai.',
      'Je suis digne d\'amour et de respect.',
      'Je fais confiance à mon intuition.',
      'Je crée ma propre réalité.',
      'Je suis en parfaite santé.',
      'Je prospère dans tous les aspects de ma vie.',
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(categoryName),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: PageView.builder(
            itemCount: phrases.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(32),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 48,
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          phrases[index],
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Phrase partagée!'),
                                    backgroundColor: Colors.purple,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Phrase ajoutée aux favoris!'),
                                    backgroundColor: Colors.purple,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMeditationMedia(Map<String, dynamic> category) {
    final mediaList = category['content'] as List<Map<String, dynamic>>;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(category['name']),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final media = mediaList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    media['type'] == 'audio' ? Icons.headphones : Icons.play_circle,
                    color: primaryColor,
                    size: 40,
                  ),
                  title: Text(media['title']),
                  subtitle: Text('${media['type']} • ${media['duration']}'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lecture: ${media['title']}'),
                        backgroundColor: primaryColor,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showArticles(Map<String, dynamic> category) {
    final articles = category['content'] as List<Map<String, dynamic>>;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(category['name']),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text(article['title']),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          body: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // En-tête de l'article
                                Row(
                                  children: [
                                    if (article['hasVideo'] == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.play_arrow, color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text('VIDÉO', style: TextStyle(color: Colors.white, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    const Spacer(),
                                    Text(
                                      '${article['readTime']} de lecture',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Titre
                                Text(
                                  article['title'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Tags
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: (article['tags'] as List<String>).map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                
                                // Contenu
                                Text(
                                  article['content'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Footer
                                Row(
                                  children: [
                                    Icon(Icons.visibility, color: Colors.grey.shade600, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${article['views']} vues',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Article partagé!'),
                                            backgroundColor: primaryColor,
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.favorite_border),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Article ajouté aux favoris!'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec badge vidéo si applicable
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                article['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (article['hasVideo'] == true)
                              const SizedBox(width: 8),
                            if (article['hasVideo'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow, color: Colors.white, size: 12),
                                    SizedBox(width: 2),
                                    Text('VIDÉO', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article['excerpt'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Footer avec métadonnées
                        Row(
                          children: [
                            Text(
                              '${article['readTime']} • ${article['views']} vues',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            // Premier tag visible
                            if ((article['tags'] as List<String>).isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  (article['tags'] as List<String>).first,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showEvents(Map<String, dynamic> category) {
    // Utiliser les événements de l'API si disponibles, sinon fallback sur les données statiques
    final events = _events.isNotEmpty 
        ? _events 
        : (category['content'] as List<Map<String, dynamic>>);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(category['name']),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header avec statut
                          Row(
                            children: [
                              // Badge de statut
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(event['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getStatusIcon(event['status']),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      event['status'] ?? 'Statut inconnu',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: primaryColor,
                                size: 16,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Titre
                          Text(
                            event['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Description courte
                          Text(
                            event['description'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Informations
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                event['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.location_on, size: 16, color: primaryColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event['location'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Prix et participants
                          Row(
                            children: [
                              Icon(Icons.euro, size: 16, color: primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                event['price'] ?? 'Gratuit',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.people, size: 16, color: primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                '${event['participants'] ?? 0} participants',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Bouton d'action
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailScreen(event: event),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Voir l\'événement'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'À venir':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'Terminé':
        return Colors.red;
      case 'Reporté':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusIcon(String? status) {
    switch (status) {
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

  void _showCategoryContent(Map<String, dynamic> category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contenu de ${category['name']}'),
        backgroundColor: primaryColor,
      ),
    );
  }

  void _showAppsMenu(BuildContext context) {
    // Applications qui seront insérées par l'admin
    final apps = [
      {'name': 'Yoga Daily', 'icon': Icons.self_improvement, 'color': Colors.orange},
      {'name': 'Sleep Better', 'icon': Icons.bedtime, 'color': Colors.indigo},
      {'name': 'Mindfulness', 'icon': Icons.spa, 'color': Colors.teal},
      {'name': 'Fitness Pro', 'icon': Icons.fitness_center, 'color': Colors.red},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plus d\'applications'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ouverture de ${app['name']}...'),
                      backgroundColor: primaryColor,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (app['color'] as Color).withOpacity(0.1),
                    border: Border.all(color: (app['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        app['icon'] as IconData,
                        size: 40,
                        color: app['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: app['color'] as Color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Abonnements Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Débloquez toutes les fonctionnalités premium:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPremiumFeature('Accès illimité à toutes les méditations'),
            _buildPremiumFeature('Courses exclusives avec des experts'),
            _buildPremiumFeature('Programmes personnalisés'),
            _buildPremiumFeature('Téléchargement hors ligne'),
            _buildPremiumFeature('Sans publicité'),
            const SizedBox(height: 16),
            const Text(
              'À partir de 9,99€/mois',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirection vers les abonnements...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('S\'abonner'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(feature)),
        ],
      ),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partage de l\'application...'),
        backgroundColor: primaryColor,
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notre engagement pour votre confidentialité',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Nous prenons votre confidentialité très au sérieux. Cette politique explique comment nous collectons, utilisons et protégeons vos informations personnelles.',
              ),
              SizedBox(height: 16),
              Text(
                'Données collectées:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Informations de profil (nom, préférences)'),
              Text('• Données d\'utilisation de l\'application'),
              Text('• Informations de progression'),
              SizedBox(height: 16),
              Text(
                'Utilisation des données:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Personnaliser votre expérience'),
              Text('• Améliorer nos services'),
              Text('• Fournir un support client'),
              SizedBox(height: 16),
              Text(
                'Protection des données:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Chiffrement des données'),
              Text('• Serveurs sécurisés'),
              Text('• Conformité RGPD'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Évaluer notre application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Votre avis compte pour nous!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Merci pour votre évaluation de ${index + 1} étoiles!'),
                        backgroundColor: Colors.amber,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
        ],
      ),
    );
  }

    void _showLogoutConfirmation() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/welcome');
                }
              },
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      );
    }
  void _showGratitudeJournal(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GratitudeJournalScreen(),
      ),
    );
  }

  void _showRetreats(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RetreatsScreen(),
      ),
    );
  }

  void _showCuisine(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CuisineScreen(),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final userProvider = Provider.of<UserProfileProvider>(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userProvider.userProfile?.name ?? 'Invité',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profil utilisateur',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
