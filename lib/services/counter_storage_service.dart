import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CounterStorageData {
  final Map<String, int> counters;
  final String currentCounter;

  const CounterStorageData({
    required this.counters,
    required this.currentCounter,
  });
}

class CounterStorageService {
  static const String _countersKey = 'counters';
  static const String _currentCounterKey = 'current_counter';

  static const Map<String, int> defaultCounters = {
    'Workout streak': 0,
    'Days without smoking': 0,
    'Days till my next holidays': 100,
  };
  static const String defaultCurrentCounter = 'Workout streak';

  static Future<CounterStorageData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final countersJson = prefs.getString(_countersKey);
    final storedCurrentCounter = prefs.getString(_currentCounterKey);

    final counters = _decodeCounters(countersJson);
    final currentCounter =
        counters.containsKey(storedCurrentCounter)
            ? storedCurrentCounter!
            : counters.keys.first;

    return CounterStorageData(
      counters: counters,
      currentCounter: currentCounter,
    );
  }

  static Future<void> save({
    required Map<String, int> counters,
    required String currentCounter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countersKey, jsonEncode(counters));
    await prefs.setString(_currentCounterKey, currentCounter);
  }

  static Map<String, int> _decodeCounters(String? countersJson) {
    if (countersJson == null || countersJson.isEmpty) {
      return Map<String, int>.from(defaultCounters);
    }

    try {
      final decoded = jsonDecode(countersJson);
      if (decoded is! Map<String, dynamic>) {
        return Map<String, int>.from(defaultCounters);
      }

      final counters = decoded.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );

      if (counters.isEmpty) {
        return Map<String, int>.from(defaultCounters);
      }

      return counters;
    } catch (_) {
      return Map<String, int>.from(defaultCounters);
    }
  }
}
