import 'dart:convert';

import 'package:counter_app/models/app_mode.dart';
import 'package:counter_app/models/watten_game.dart';
import 'package:counter_app/services/counter_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CounterStorageService', () {
    test('loads defaults when no values are stored', () async {
      SharedPreferences.setMockInitialValues({});

      final data = await CounterStorageService.load();

      expect(data.counters, CounterStorageService.defaultCounters);
      expect(data.currentCounter, CounterStorageService.defaultCurrentCounter);
      expect(data.wattenGames.keys, CounterStorageService.defaultWattenGames.keys);
      expect(
        data.currentMulatschakPlayer,
        CounterStorageService.defaultCurrentMulatschakPlayer,
      );
      expect(data.appMode, AppMode.counter);
    });

    test('saves and loads a complete state roundtrip', () async {
      SharedPreferences.setMockInitialValues({});

      await CounterStorageService.save(
        counters: const {'Focus': 3},
        currentCounter: 'Focus',
        wattenGames: const {'Final': WattenGame(me: 11, you: 9)},
        currentWattenGame: 'Final',
        mulatschakPlayers: const {'Anna': 12, 'Ben': 8},
        currentMulatschakPlayer: 'Ben',
        mulatschakMultiplier: 4,
        muleqackEnabled: true,
        muleqackTriggerPoints: 100,
        muleqackResetPoints: 50,
        appMode: AppMode.mulatschak,
      );

      final data = await CounterStorageService.load();

      expect(data.counters, {'Focus': 3});
      expect(data.currentCounter, 'Focus');
      expect(data.wattenGames['Final']?.me, 11);
      expect(data.wattenGames['Final']?.you, 9);
      expect(data.currentWattenGame, 'Final');
      expect(data.mulatschakPlayers, {'Anna': 12, 'Ben': 8});
      expect(data.currentMulatschakPlayer, 'Ben');
      expect(data.mulatschakMultiplier, 4);
      expect(data.muleqackEnabled, isTrue);
      expect(data.muleqackTriggerPoints, 100);
      expect(data.muleqackResetPoints, 50);
      expect(data.appMode, AppMode.mulatschak);
    });

    test('falls back safely for malformed and legacy stored data', () async {
      SharedPreferences.setMockInitialValues({
        'counters': 'not-json',
        'current_counter': 'Missing',
        'watten_games': jsonEncode({
          'Spiel 1': {'me': 2, 'you': 1},
        }),
        'current_watten_game': 'Spiel 1',
        'mulatschak_players': jsonEncode(<String, dynamic>{}),
        'current_mulatschak_player': 'Nobody',
        'mulatschak_multiplier': -2,
        'muleqack_enabled': true,
        'muleqack_trigger_points': 0,
        'muleqack_reset_points': -5,
        'app_mode': 'unknown-mode',
      });

      final data = await CounterStorageService.load();

      expect(data.counters, CounterStorageService.defaultCounters);
      expect(data.currentCounter, CounterStorageService.defaultCurrentCounter);
      expect(data.wattenGames.containsKey('Game 1'), isTrue);
      expect(data.wattenGames['Game 1']?.me, 2);
      expect(data.wattenGames['Game 1']?.you, 1);
      expect(data.currentWattenGame, 'Game 1');
      expect(data.mulatschakPlayers, CounterStorageService.defaultMulatschakPlayers);
      expect(
        data.currentMulatschakPlayer,
        CounterStorageService.defaultCurrentMulatschakPlayer,
      );
      expect(
        data.mulatschakMultiplier,
        CounterStorageService.defaultMulatschakMultiplier,
      );
      expect(data.muleqackEnabled, isTrue);
      expect(
        data.muleqackTriggerPoints,
        CounterStorageService.defaultMuleqackTriggerPoints,
      );
      expect(
        data.muleqackResetPoints,
        CounterStorageService.defaultMuleqackResetPoints,
      );
      expect(data.appMode, CounterStorageService.defaultAppMode);
    });
  });
}
