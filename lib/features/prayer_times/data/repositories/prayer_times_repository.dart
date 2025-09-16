import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesRepository {
  static const _cacheKey = 'cached_prayer_times';

  Future<PrayerTimes> fetchPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCoordinates = _readCachedCoordinates(prefs);
    final hasConnection = await _hasNetworkConnection();

    if (!hasConnection) {
      final cachedTimes = await _buildPrayerTimesFromCoordinates(
        prefs: prefs,
        coordinates: cachedCoordinates,
        updateCache: true,
      );

      if (cachedTimes != null) {
        return cachedTimes;
      }

      throw Exception('لا يوجد اتصال بالشبكة ولا بيانات أوقات صلاة محفوظة.');
    }

    try {
      final position = await _determinePosition();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final prayerTimes = _calculatePrayerTimes(coordinates);
      await _cachePrayerTimes(prefs, coordinates, prayerTimes);
      return prayerTimes;
    } catch (e) {
      final cachedTimes = await _buildPrayerTimesFromCoordinates(
        prefs: prefs,
        coordinates: cachedCoordinates,
        updateCache: true,
      );

      if (cachedTimes != null) {
        return cachedTimes;
      }

      throw Exception(e.toString());
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('يرجى تفعيل خدمة الموقع.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض إذن الموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('تم رفض إذن الموقع بشكل دائم.');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<bool> _hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  PrayerTimes _calculatePrayerTimes(Coordinates coordinates) {
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.hanafi;
    final now = DateTime.now();
    final dateComponents = DateComponents(now.year, now.month, now.day);
    return PrayerTimes(coordinates, dateComponents, params);
  }

  Coordinates? _readCachedCoordinates(SharedPreferences prefs) {
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) {
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
      final latitude = (data['latitude'] as num?)?.toDouble();
      final longitude = (data['longitude'] as num?)?.toDouble();

      if (latitude == null || longitude == null) {
        return null;
      }

      return Coordinates(latitude, longitude);
    } catch (_) {
      return null;
    }
  }

  Future<PrayerTimes?> _buildPrayerTimesFromCoordinates({
    required SharedPreferences prefs,
    required Coordinates? coordinates,
    bool updateCache = false,
  }) async {
    if (coordinates == null) {
      return null;
    }

    final prayerTimes = _calculatePrayerTimes(coordinates);

    if (updateCache) {
      await _cachePrayerTimes(prefs, coordinates, prayerTimes);
    }

    return prayerTimes;
  }

  Future<void> _cachePrayerTimes(
    SharedPreferences prefs,
    Coordinates coordinates,
    PrayerTimes prayerTimes,
  ) async {
    final cachedData = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'times': {
        'fajr': prayerTimes.fajr.toIso8601String(),
        'sunrise': prayerTimes.sunrise.toIso8601String(),
        'dhuhr': prayerTimes.dhuhr.toIso8601String(),
        'asr': prayerTimes.asr.toIso8601String(),
        'maghrib': prayerTimes.maghrib.toIso8601String(),
        'isha': prayerTimes.isha.toIso8601String(),
      },
    };

    await prefs.setString(_cacheKey, jsonEncode(cachedData));
  }
}
