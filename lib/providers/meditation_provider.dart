import 'package:flutter/material.dart';
import '../models/meditation.dart';
import '../services/meditation_service.dart';

class MeditationProvider extends ChangeNotifier {
  final MeditationService _meditationService = MeditationService();
  
  List<Meditation> _meditations = [];
  bool _isLoading = false;
  String? _error;

  List<Meditation> get meditations => _meditations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMeditations() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _meditations = await _meditationService.getMeditations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Meditation?> getMeditationById(int id) async {
    try {
      return await _meditationService.getMeditationById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
