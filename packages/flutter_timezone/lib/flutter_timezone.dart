import 'dart:async';

import 'package:flutter/services.dart';

class FlutterTimezone {
  FlutterTimezone._();

  static const MethodChannel _channel = MethodChannel('flutter_timezone');

  /// Returns the timezone name for the current device.
  static Future<String> getLocalTimezone() async {
    final timezone = await _channel.invokeMethod<String>('getLocalTimezone');
    if (timezone == null) {
      throw PlatformException(
        code: 'unavailable',
        message: 'Timezone information is not available on this device.',
      );
    }
    return timezone;
  }

  /// Returns the list of available timezone identifiers on the platform.
  static Future<List<String>> getAvailableTimezones() async {
    final timezones = await _channel.invokeMethod<List<dynamic>>(
      'getAvailableTimezones',
    );
    if (timezones == null) {
      return const <String>[];
    }
    return timezones.cast<String>();
  }
}
