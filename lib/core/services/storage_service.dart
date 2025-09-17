
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveLastCategory(String category) async {
    await _prefs?.setString(AppConstants.lastCategoryKey, category);
  }

  static String getLastCategory() {
    return _prefs?.getString(AppConstants.lastCategoryKey) ?? AppConstants.defaultCategory;
  }

  static Future<void> saveFavorites(List<String> favorites) async {
    await _prefs?.setStringList(AppConstants.favoritesKey, favorites);
  }

  static List<String> getFavorites() {
    return _prefs?.getStringList(AppConstants.favoritesKey) ?? [];
  }

  static Future<void> saveTheme(bool isDarkMode) async {
    await _prefs?.setBool(AppConstants.isDarkModeKey, isDarkMode);
  }

  static bool hasThemePreference() {
    return _prefs?.containsKey(AppConstants.isDarkModeKey) ?? false;
  }

  static bool? getTheme() {
    return _prefs?.getBool(AppConstants.isDarkModeKey);
  }

  static Future<void> saveAudioRepeat(bool isRepeatEnabled) async {
    await _prefs?.setBool(AppConstants.audioRepeatKey, isRepeatEnabled);
  }

  static bool getAudioRepeat() {
    return _prefs?.getBool(AppConstants.audioRepeatKey) ?? false;
  }

  static Future<void> saveAudioAutoNext(bool isAutoNextEnabled) async {
    await _prefs?.setBool(AppConstants.audioAutoNextKey, isAutoNextEnabled);
  }

  static bool getAudioAutoNext() {
    return _prefs?.getBool(AppConstants.audioAutoNextKey) ?? false;
  }
}
