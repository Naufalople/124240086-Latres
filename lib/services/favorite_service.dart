import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService instance = FavoriteService._init();
  static const String _keyFavorites = 'favorite_characters_list';

  List<Character> _favorites = [];
  bool _isInitialized = false;

  FavoriteService._init();

  List<Character> get favorites => List.unmodifiable(_favorites);

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadFromPrefs();
    _isInitialized = true;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_keyFavorites);
      if (listJson != null) {
        _favorites = listJson
            .map((itemStr) => Character.fromJson(jsonDecode(itemStr)))
            .toList();
      } else {
        _favorites = [];
      }
    } catch (e) {
      debugPrint('Error loading favorites from SharedPreferences: $e');
      _favorites = [];
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _favorites
          .map((char) => jsonEncode(char.toJson()))
          .toList();
      await prefs.setStringList(_keyFavorites, listJson);
    } catch (e) {
      debugPrint('Error saving favorites to SharedPreferences: $e');
    }
  }

  bool isFavorite(int id) {
    return _favorites.any((c) => c.id == id);
  }

  /// Toggles favorite status.
  /// Returns `true` if added, `false` if removed.
  Future<bool> toggleFavorite(Character character) async {
    final index = _favorites.indexWhere((c) => c.id == character.id);
    bool added;
    if (index >= 0) {
      _favorites.removeAt(index);
      added = false;
    } else {
      _favorites.add(character);
      added = true;
    }
    await _saveToPrefs();
    notifyListeners();
    return added;
  }

  Future<void> addFavorite(Character character) async {
    if (!isFavorite(character.id)) {
      _favorites.add(character);
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<Character?> removeFavorite(int characterId) async {
    final index = _favorites.indexWhere((c) => c.id == characterId);
    if (index >= 0) {
      final removed = _favorites.removeAt(index);
      await _saveToPrefs();
      notifyListeners();
      return removed;
    }
    return null;
  }

  Future<void> insertFavorite(int index, Character character) async {
    if (!isFavorite(character.id)) {
      if (index >= 0 && index <= _favorites.length) {
        _favorites.insert(index, character);
      } else {
        _favorites.add(character);
      }
      await _saveToPrefs();
      notifyListeners();
    }
  }
}
