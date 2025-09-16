import '../../../../core/models/supplication.dart';
import '../../../../core/services/storage_service.dart';

class AudioFavoritesService {
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

    final savedFavorites = StorageService.getFavorites();

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
    await StorageService.saveFavorites(List.unmodifiable(_favoriteTitles));
  }
}
