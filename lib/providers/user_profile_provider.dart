import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger le profil utilisateur depuis SharedPreferences
  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      // Vérifier si c'est la première fois
      final isFirstTime = prefs.getBool('is_first_time') ?? true;
      
      if (!isFirstTime) {
        final userProfileData = <String, dynamic>{
          'birth_date': prefs.getString('birth_date'),
          'gender': prefs.getString('gender'),
          'name': prefs.getString('name'),
          'goals': prefs.getStringList('goals') ?? [],
          'reminder_times': prefs.getStringList('reminder_times') ?? [],
          'reminders_enabled': prefs.getBool('reminders_enabled') ?? false,
        };
        
        _userProfile = UserProfile.fromPreferences(userProfileData);
      }
    } catch (e) {
      _error = 'Erreur lors du chargement du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sauvegarder le profil utilisateur
  Future<void> saveUserProfile(UserProfile userProfile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('birth_date', userProfile.birthDate ?? '');
      await prefs.setString('gender', userProfile.gender ?? '');
      await prefs.setString('name', userProfile.name ?? '');
      await prefs.setStringList('goals', userProfile.goals);
      await prefs.setStringList('reminder_times', userProfile.reminderTimes);
      await prefs.setBool('reminders_enabled', userProfile.remindersEnabled);
      await prefs.setBool('is_first_time', false);
      
      _userProfile = userProfile;
    } catch (e) {
      _error = 'Erreur lors de la sauvegarde du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? name,
    List<String>? goals,
    List<String>? reminderTimes,
    bool? remindersEnabled,
  }) async {
    if (_userProfile == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      if (name != null) {
        _userProfile!.name = name;
        await prefs.setString('name', name);
      }
      
      if (goals != null) {
        _userProfile!.goals = goals;
        await prefs.setStringList('goals', goals);
      }
      
      if (reminderTimes != null) {
        _userProfile!.reminderTimes = reminderTimes;
        await prefs.setStringList('reminder_times', reminderTimes);
      }
      
      if (remindersEnabled != null) {
        _userProfile!.remindersEnabled = remindersEnabled;
        await prefs.setBool('reminders_enabled', remindersEnabled);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Réinitialiser le profil (pour une nouvelle inscription)
  Future<void> resetProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      // Effacer toutes les données utilisateur
      await prefs.remove('birth_date');
      await prefs.remove('gender');
      await prefs.remove('name');
      await prefs.remove('goals');
      await prefs.remove('reminder_times');
      await prefs.remove('reminders_enabled');
      await prefs.setBool('is_first_time', true);
      
      _userProfile = null;
    } catch (e) {
      _error = 'Erreur lors de la réinitialisation du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vérifier si l'utilisateur est inscrit
  bool get isRegistered {
    return _userProfile != null && _userProfile!.isComplete;
  }

  // Obtenir le message de bienvenue
  String get welcomeMessage {
    return _userProfile?.welcomeMessage ?? 'Bienvenue';
  }

  // Effacer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
