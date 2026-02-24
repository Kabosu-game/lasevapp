import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/onboarding_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Couleur principale du projet
  static const Color primaryColor = Color(0xFF265533);
  
  // Couleurs dérivées
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color primaryMedium = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  final UserProfile _userProfile = UserProfile();
  
  final List<String> _stepTitles = [
    'Bienvenue',
    'Votre date de naissance',
    'Votre identité',
    'Vos objectifs',
    'Rappels',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      // Sauvegarder le profil utilisateur
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('birth_date', _userProfile.birthDate ?? '');
      await prefs.setString('gender', _userProfile.gender ?? '');
      await prefs.setString('name', _userProfile.name ?? '');
      await prefs.setStringList('goals', _userProfile.goals);
      await prefs.setStringList('reminder_times', _userProfile.reminderTimes);
      await prefs.setBool('reminders_enabled', _userProfile.remindersEnabled);
      await prefs.setBool('is_first_time', false);
      
      // Marquer l'onboarding comme terminé
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond pour toutes les étapes sauf la première
          if (_currentStep > 0)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image_bg/background_${_currentStep}.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryLight,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          
          // Contenu
          SafeArea(
            child: Column(
              children: [
                // Header avec indicateur de progression
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Titre
                      Text(
                        _stepTitles[_currentStep],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _currentStep > 0 ? Colors.white : primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Indicateur de progression
                      Row(
                        children: List.generate(
                          5,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 4,
                              decoration: BoxDecoration(
                                color: index <= _currentStep
                                    ? (_currentStep > 0 ? Colors.white : primaryColor)
                                    : (_currentStep > 0 ? Colors.white.withOpacity(0.3) : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Étape ${_currentStep + 1} sur 5',
                        style: TextStyle(
                          fontSize: 14,
                          color: _currentStep > 0 ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contenu du formulaire
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      OnboardingStep(
                        title: '',
                        subtitle: '',
                        child: _buildWelcomeStep(),
                      ),
                      OnboardingStep(
                        title: 'Quelle est votre date de naissance?',
                        subtitle: 'Cela nous aidera à personnaliser votre expérience',
                        child: _buildBirthDateStep(),
                      ),
                      OnboardingStep(
                        title: 'Parlez-nous de vous',
                        subtitle: 'Votre identité et votre nom',
                        child: _buildIdentityStep(),
                      ),
                      OnboardingStep(
                        title: 'Que souhaitez-vous attirer?',
                        subtitle: 'Choisissez vos objectifs de méditation',
                        child: _buildGoalsStep(),
                      ),
                      OnboardingStep(
                        title: 'Programmez vos rappels',
                        subtitle: 'Recevez des notifications pour méditer',
                        child: _buildRemindersStep(),
                      ),
                    ],
                  ),
                ),
                
                // Boutons de navigation
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Bouton précédent
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: _currentStep > 0 ? Colors.white : primaryMedium,
                              ),
                            ),
                            child: Text(
                              'Précédent',
                              style: TextStyle(
                                color: _currentStep > 0 ? Colors.white : primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                      
                      const SizedBox(width: 16),
                      
                      // Bouton suivant/terminer
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canProceed() ? _nextStep : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentStep > 0 ? Colors.white : primaryColor,
                            foregroundColor: _currentStep > 0 ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentStep == 4 ? 'Terminer' : 'Suivant',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Titre
            const Text(
              'Bienvenue dans votre voyage',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Commencez votre voyage vers la paix intérieure',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Bouton Commencer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _nextStep();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Commencer',
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
    );
  }

  Widget _buildBirthDateStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.cake,
          size: 80,
          color: Colors.white,
        ),
        
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
            );
            
            if (picked != null) {
              setState(() {
                _userProfile.birthDate = '${picked.day}/${picked.month}/${picked.year}';
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _userProfile.birthDate ?? 'Sélectionner votre date de naissance',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sexe
          const Text(
            'Vous êtes:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _userProfile.gender = 'homme';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _userProfile.gender == 'homme'
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    foregroundColor: _userProfile.gender == 'homme'
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Homme'),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _userProfile.gender = 'femme';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _userProfile.gender == 'femme'
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    foregroundColor: _userProfile.gender == 'femme'
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Femme'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Prénom/Surnom
          const Text(
            'Votre prénom ou surnom:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            onChanged: (value) {
              setState(() {
                _userProfile.name = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Entrez votre prénom ou surnom',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    final List<String> availableGoals = [
      'Paix intérieure',
      'Réduction du stress',
      'Meilleur sommeil',
      'Concentration',
      'Énergie vitale',
      'Créativité',
      'Confiance en soi',
      'Relations harmonieuses',
      'Santé globale',
      'Éveil spirituel',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableGoals.map((goal) {
                final isSelected = _userProfile.goals.contains(goal);
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      final newGoals = List<String>.from(_userProfile.goals);
                      if (isSelected) {
                        newGoals.remove(goal);
                      } else {
                        newGoals.add(goal);
                      }
                      _userProfile.goals = newGoals;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        goal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '${_userProfile.goals.length} objectif(s) sélectionné(s)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersStep() {
    final List<String> availableTimes = [
      '06:00',
      '08:00',
      '12:00',
      '14:00',
      '18:00',
      '20:00',
      '22:00',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Toggle pour activer les rappels
          SwitchListTile(
            title: const Text(
              'Activer les rappels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'Recevez des notifications pour méditer',
              style: TextStyle(color: Colors.white70),
            ),
            value: _userProfile.remindersEnabled,
            onChanged: (value) {
              setState(() {
                _userProfile.remindersEnabled = value;
              });
            },
            activeColor: primaryColor,
            activeTrackColor: Colors.white.withOpacity(0.3),
          ),
          
          const SizedBox(height: 24),
          
          if (_userProfile.remindersEnabled) ...[
            const Text(
              'Quand souhaitez-vous recevoir des rappels?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: availableTimes.map((time) {
                  final isSelected = _userProfile.reminderTimes.contains(time);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        final newTimes = List<String>.from(_userProfile.reminderTimes);
                        if (isSelected) {
                          newTimes.remove(time);
                        } else {
                          newTimes.add(time);
                        }
                        _userProfile.reminderTimes = newTimes;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 80,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Les rappels sont désactivés',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Welcome
        return true;
      case 1: // Birth date
        return _userProfile.birthDate != null;
      case 2: // Identity
        return _userProfile.gender != null && _userProfile.name != null && _userProfile.name!.isNotEmpty;
      case 3: // Goals
        return _userProfile.goals.isNotEmpty;
      case 4: // Reminders
        return true; // Les rappels sont optionnels
      default:
        return false;
    }
  }

  // Obtenir la couleur pour chaque étape
  MaterialColor _getStepColor(int step) {
    switch (step) {
      case 1:
        return Colors.blue;
      case 2:
        return const MaterialColor(0xFF265533, {
          50: Color(0xFFE8F5E9),
          100: Color(0xFFC8E6C9),
          200: Color(0xFFA5D6A7),
          300: Color(0xFF81C784),
          400: Color(0xFF66BB6A),
          500: Color(0xFF4CAF50),
          600: Color(0xFF43A047),
          700: Color(0xFF388E3C),
          800: Color(0xFF2E7D32),
          900: Color(0xFF1B5E20),
        });
      case 3:
        return Colors.teal;
      case 4:
        return Colors.orange;
      default:
        return const MaterialColor(0xFF265533, {
          50: Color(0xFFE8F5E9),
          100: Color(0xFFC8E6C9),
          200: Color(0xFFA5D6A7),
          300: Color(0xFF81C784),
          400: Color(0xFF66BB6A),
          500: Color(0xFF4CAF50),
          600: Color(0xFF43A047),
          700: Color(0xFF388E3C),
          800: Color(0xFF2E7D32),
          900: Color(0xFF1B5E20),
        });
    }
  }
}
