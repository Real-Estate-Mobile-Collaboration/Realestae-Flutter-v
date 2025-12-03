import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class FavoriteProvider with ChangeNotifier {
  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get favorites
  Future<void> fetchFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(
        ApiConstants.favorites,
        requiresAuth: true,
      );

      if (response['success']) {
        _favorites = (response['data'] as List)
            .map((json) => Favorite.fromJson(json))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to favorites
  Future<bool> addFavorite(String propertyId) async {
    try {
      final response = await ApiService.post(
        ApiConstants.addFavorite(propertyId),
        {},
        requiresAuth: true,
      );

      if (response['success']) {
        await fetchFavorites(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFavorite(String propertyId) async {
    try {
      final response = await ApiService.delete(
        ApiConstants.removeFavorite(propertyId),
        requiresAuth: true,
      );

      if (response['success']) {
        _favorites.removeWhere((f) => f.property.id == propertyId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if property is favorite
  Future<bool> checkFavorite(String propertyId) async {
    try {
      final response = await ApiService.get(
        ApiConstants.checkFavorite(propertyId),
        requiresAuth: true,
      );

      return response['success'] && response['data']['isFavorite'] == true;
    } catch (e) {
      return false;
    }
  }

  // Check if property is favorited (local check)
  bool isFavorite(String propertyId) {
    return _favorites.any((f) => f.property.id == propertyId);
  }
}
