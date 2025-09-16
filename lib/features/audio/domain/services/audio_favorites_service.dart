import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/supplication.dart';

class AudioFavoritesService {
  static const String _favoritesKey = 'favorites';

  final List<String> _favoriteTitles = [];
  final Map<String, Supplication> _supplicationByTitle = {};

  Future<void> initialize(Map<String, List<Supplication>> categories) async {
    _supplicationByTitle
      ..clear()
      ..addEntries(
        categories.values.expand((supplications) => supplications).map(
              (supplication) => MapEntry(supplication.title, supplication),
            ),
      );

    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList(_favoritesKey) ?? [];

    _favoriteTitles
      ..clear()
      ..addAll(
        savedFavorites.where(_supplicationByTitle.containsKey),
      );
  }

  List<Supplication> get favorites => _favoriteTitles
      .map((title) => _supplicationByTitle[title])
      .whereType<Supplication>()
      .toList(growable: false);

  bool isFavorite(Supplication supplication) {
    return _favoriteTitles.contains(supplication.title);
  }

  Future<List<Supplication>> toggleFavorite(Supplication supplication) async {
    if (_favoriteTitles.contains(supplication.title)) {
      _favoriteTitles.remove(supplication.title);
    } else {
      _favoriteTitles.add(supplication.title);
    }
    await _persist();
    return favorites;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, List.unmodifiable(_favoriteTitles));
  }
}
