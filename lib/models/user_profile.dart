class UserProfile {
  String? birthDate;
  String? gender;
  String? name;
  List<String> goals = [];
  List<String> reminderTimes = [];
  bool remindersEnabled = false;

  UserProfile({
    this.birthDate,
    this.gender,
    this.name,
    this.goals = const [],
    this.reminderTimes = const [],
    this.remindersEnabled = false,
  });

  // Créer un profil à partir des SharedPreferences
  factory UserProfile.fromPreferences(Map<String, dynamic> data) {
    return UserProfile(
      birthDate: data['birth_date'],
      gender: data['gender'],
      name: data['name'],
      goals: List<String>.from(data['goals'] ?? []),
      reminderTimes: List<String>.from(data['reminder_times'] ?? []),
      remindersEnabled: data['reminders_enabled'] ?? false,
    );
  }

  // Convertir en Map pour SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'birth_date': birthDate,
      'gender': gender,
      'name': name,
      'goals': goals,
      'reminder_times': reminderTimes,
      'reminders_enabled': remindersEnabled,
    };
  }

  // Vérifier si le profil est complet
  bool get isComplete {
    return birthDate != null &&
        gender != null &&
        name != null &&
        name!.isNotEmpty &&
        goals.isNotEmpty;
  }

  // Obtenir l'âge à partir de la date de naissance
  int? get age {
    if (birthDate == null) return null;
    
    try {
      final parts = birthDate!.split('/');
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final birthDateTime = DateTime(year, month, day);
      final today = DateTime.now();
      
      int age = today.year - birthDateTime.year;
      if (today.month < birthDateTime.month || 
          (today.month == birthDateTime.month && today.day < birthDateTime.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      return null;
    }
  }

  // Obtenir le message de bienvenue personnalisé
  String get welcomeMessage {
    if (name == null || name!.isEmpty) return 'Bienvenue';
    
    final hour = DateTime.now().hour;
    String greeting = 'Bonjour';
    
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }
    
    return '$greeting $name';
  }

  // Réinitialiser le profil
  void reset() {
    birthDate = null;
    gender = null;
    name = null;
    goals = [];
    reminderTimes = [];
    remindersEnabled = false;
  }
}
