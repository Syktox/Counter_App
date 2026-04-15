import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_mode.dart';
import '../models/watten_game.dart';

class CounterStorageData {
  final Map<String, int> counters;
  final String currentCounter;
  final Map<String, WattenGame> wattenGames;
  final String currentWattenGame;
  final Map<String, int> mulatschakPlayers;
  final String currentMulatschakPlayer;
  final int mulatschakMultiplier;
  final bool muleqackEnabled;
  final int muleqackTriggerPoints;
  final int muleqackResetPoints;
  final AppMode appMode;

  const CounterStorageData({
    required this.counters,
    required this.currentCounter,
    required this.wattenGames,
    required this.currentWattenGame,
    required this.mulatschakPlayers,
    required this.currentMulatschakPlayer,
    required this.mulatschakMultiplier,
    required this.muleqackEnabled,
    required this.muleqackTriggerPoints,
    required this.muleqackResetPoints,
    required this.appMode,
  });
}

class CounterStorageService {
  static const String _countersKey = 'counters';
  static const String _currentCounterKey = 'current_counter';
  static const String _wattenGamesKey = 'watten_games';
  static const String _currentWattenGameKey = 'current_watten_game';
  static const String _mulatschakPlayersKey = 'mulatschak_players';
  static const String _currentMulatschakPlayerKey = 'current_mulatschak_player';
  static const String _mulatschakMultiplierKey = 'mulatschak_multiplier';
  static const String _muleqackEnabledKey = 'muleqack_enabled';
  static const String _muleqackTriggerPointsKey = 'muleqack_trigger_points';
  static const String _muleqackResetPointsKey = 'muleqack_reset_points';
  static const String _appModeKey = 'app_mode';

  static const Map<String, int> defaultCounters = {
    'Workout streak': 0,
    'Days without smoking': 0,
    'Days till my next holidays': 100,
  };
  static const String defaultCurrentCounter = 'Workout streak';
  static const Map<String, WattenGame> defaultWattenGames = {
    'Game 1': WattenGame(me: 0, you: 0),
    'Game 2': WattenGame(me: 0, you: 0),
    'Game 3': WattenGame(me: 0, you: 0),
  };
  static const String defaultCurrentWattenGame = 'Game 1';
  static const Map<String, int> defaultMulatschakPlayers = {
    'Player 1': 21,
    'Player 2': 21,
  };
  static const String defaultCurrentMulatschakPlayer = 'Player 1';
  static const int defaultMulatschakMultiplier = 1;
  static const bool defaultMuleqackEnabled = false;
  static const int defaultMuleqackTriggerPoints = 100;
  static const int defaultMuleqackResetPoints = 50;
  static const AppMode defaultAppMode = AppMode.counter;

  static Future<CounterStorageData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final countersJson = prefs.getString(_countersKey);
    final storedCurrentCounter = prefs.getString(_currentCounterKey);
    final wattenGamesJson = prefs.getString(_wattenGamesKey);
    final storedCurrentWattenGame = prefs.getString(_currentWattenGameKey);
    final mulatschakPlayersJson = prefs.getString(_mulatschakPlayersKey);
    final storedCurrentMulatschakPlayer = prefs.getString(
      _currentMulatschakPlayerKey,
    );
    final storedMulatschakMultiplier = prefs.getInt(_mulatschakMultiplierKey);
    final storedMuleqackEnabled = prefs.getBool(_muleqackEnabledKey);
    final storedMuleqackTriggerPoints = prefs.getInt(_muleqackTriggerPointsKey);
    final storedMuleqackResetPoints = prefs.getInt(_muleqackResetPointsKey);
    final storedAppMode = prefs.getString(_appModeKey);

    final counters = _decodeCounters(countersJson);
    final wattenGames = _decodeWattenGames(wattenGamesJson);
    final mulatschakPlayers = _decodeCounters(
      mulatschakPlayersJson,
      fallback: defaultMulatschakPlayers,
    );
    final currentCounter =
        counters.containsKey(storedCurrentCounter)
            ? storedCurrentCounter!
            : counters.keys.first;
    final currentWattenGame =
        wattenGames.containsKey(storedCurrentWattenGame)
            ? storedCurrentWattenGame!
            : wattenGames.keys.first;
    final currentMulatschakPlayer =
        mulatschakPlayers.containsKey(storedCurrentMulatschakPlayer)
            ? storedCurrentMulatschakPlayer!
            : mulatschakPlayers.keys.first;
    final appMode = _decodeAppMode(storedAppMode);
    final mulatschakMultiplier =
        storedMulatschakMultiplier != null && storedMulatschakMultiplier > 0
            ? storedMulatschakMultiplier
            : defaultMulatschakMultiplier;
    final muleqackEnabled = storedMuleqackEnabled ?? defaultMuleqackEnabled;
    final muleqackTriggerPoints =
        storedMuleqackTriggerPoints != null && storedMuleqackTriggerPoints > 0
            ? storedMuleqackTriggerPoints
            : defaultMuleqackTriggerPoints;
    final muleqackResetPoints =
        storedMuleqackResetPoints != null && storedMuleqackResetPoints >= 0
            ? storedMuleqackResetPoints
            : defaultMuleqackResetPoints;

    return CounterStorageData(
      counters: counters,
      currentCounter: currentCounter,
      wattenGames: wattenGames,
      currentWattenGame: currentWattenGame,
      mulatschakPlayers: mulatschakPlayers,
      currentMulatschakPlayer: currentMulatschakPlayer,
      mulatschakMultiplier: mulatschakMultiplier,
      muleqackEnabled: muleqackEnabled,
      muleqackTriggerPoints: muleqackTriggerPoints,
      muleqackResetPoints: muleqackResetPoints,
      appMode: appMode,
    );
  }

  static Future<void> save({
    required Map<String, int> counters,
    required String currentCounter,
    required Map<String, WattenGame> wattenGames,
    required String currentWattenGame,
    required Map<String, int> mulatschakPlayers,
    required String currentMulatschakPlayer,
    required int mulatschakMultiplier,
    required bool muleqackEnabled,
    required int muleqackTriggerPoints,
    required int muleqackResetPoints,
    required AppMode appMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countersKey, jsonEncode(counters));
    await prefs.setString(_currentCounterKey, currentCounter);
    await prefs.setString(
      _wattenGamesKey,
      jsonEncode(
        wattenGames.map((key, value) => MapEntry(key, value.toJson())),
      ),
    );
    await prefs.setString(_currentWattenGameKey, currentWattenGame);
    await prefs.setString(_mulatschakPlayersKey, jsonEncode(mulatschakPlayers));
    await prefs.setString(_currentMulatschakPlayerKey, currentMulatschakPlayer);
    await prefs.setInt(_mulatschakMultiplierKey, mulatschakMultiplier);
    await prefs.setBool(_muleqackEnabledKey, muleqackEnabled);
    await prefs.setInt(_muleqackTriggerPointsKey, muleqackTriggerPoints);
    await prefs.setInt(_muleqackResetPointsKey, muleqackResetPoints);
    await prefs.setString(_appModeKey, appMode.name);
  }

  static Map<String, int> _decodeCounters(
    String? countersJson, {
    Map<String, int>? fallback,
  }) {
    final fallbackCounters = fallback ?? defaultCounters;

    if (countersJson == null || countersJson.isEmpty) {
      return Map<String, int>.from(fallbackCounters);
    }

    try {
      final decoded = jsonDecode(countersJson);
      if (decoded is! Map<String, dynamic>) {
        return Map<String, int>.from(fallbackCounters);
      }

      final counters = decoded.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );

      if (counters.isEmpty) {
        return Map<String, int>.from(fallbackCounters);
      }

      return counters;
    } catch (_) {
      return Map<String, int>.from(fallbackCounters);
    }
  }

  static Map<String, WattenGame> _decodeWattenGames(String? wattenGamesJson) {
    if (wattenGamesJson == null || wattenGamesJson.isEmpty) {
      return Map<String, WattenGame>.from(defaultWattenGames);
    }

    try {
      final decoded = jsonDecode(wattenGamesJson);
      if (decoded is! Map<String, dynamic>) {
        return Map<String, WattenGame>.from(defaultWattenGames);
      }

      final games = decoded.map((key, value) {
        if (value is! Map<String, dynamic>) {
          return MapEntry(_normalizeWattenGameName(key), const WattenGame(me: 0, you: 0));
        }
        return MapEntry(_normalizeWattenGameName(key), WattenGame.fromJson(value));
      });

      if (games.isEmpty) {
        return Map<String, WattenGame>.from(defaultWattenGames);
      }

      return games;
    } catch (_) {
      return Map<String, WattenGame>.from(defaultWattenGames);
    }
  }

  static AppMode _decodeAppMode(String? storedAppMode) {
    return AppMode.values.firstWhere(
      (mode) => mode.name == storedAppMode,
      orElse: () => defaultAppMode,
    );
  }

  static String _normalizeWattenGameName(String name) {
    if (name == 'Spiel 1') {
      return 'Game 1';
    }
    return name;
  }
}
