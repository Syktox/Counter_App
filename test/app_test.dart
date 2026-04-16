import 'dart:convert';

import 'package:counter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Counter mode', () {
    testWidgets('supports increment, reset and undo', (tester) async {
      await _pumpApp(tester);

      expect(find.text('Workout streak'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byTooltip('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('supports adding, renaming and deleting counters', (tester) async {
      await _pumpApp(tester);

      await _openDrawer(tester);
      await tester.tap(find.text('New Counter'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Reading streak');
      await tester.tap(find.widgetWithText(TextButton, 'Add'));
      await tester.pumpAndSettle();

      expect(find.text('Reading streak'), findsOneWidget);

      await _openDrawer(tester);
      await tester.tap(_drawerActionForItem('Reading streak', 'Rename item'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Reading days');
      await tester.tap(find.widgetWithText(TextButton, 'Rename'));
      await tester.pumpAndSettle();

      expect(find.text('Reading days'), findsWidgets);

      await _openDrawer(tester);
      await tester.tap(_drawerActionForItem('Reading days', 'Delete item'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      await _closeDrawer(tester);

      expect(find.text('Workout streak'), findsOneWidget);
      expect(find.text('Reading days'), findsNothing);
    });
  });

  group('Watten mode', () {
    testWidgets('supports score updates and side reset', (tester) async {
      await _pumpApp(
        tester,
        sharedPreferences: {
          'app_mode': 'watten',
          'watten_games': jsonEncode({
            'Game 1': {'me': 4, 'you': 7},
          }),
          'current_watten_game': 'Game 1',
        },
      );

      expect(find.text('Me'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      await tester.tap(find.text('+2'));
      await tester.pumpAndSettle();
      expect(find.text('6'), findsOneWidget);

      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+3'));
      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('10'), findsNothing);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('supports winner display and game management', (tester) async {
      await _pumpApp(
        tester,
        sharedPreferences: {
          'app_mode': 'watten',
          'watten_games': jsonEncode({
            'Game 1': {'me': 9, 'you': 0},
          }),
          'current_watten_game': 'Game 1',
        },
      );

      await tester.tap(find.text('+2'));
      await tester.pumpAndSettle();
      expect(find.text('Me wins'), findsOneWidget);

      await _openDrawer(tester);
      await tester.tap(find.text('Add Game'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Finale');
      await tester.tap(find.widgetWithText(TextButton, 'Add'));
      await tester.pumpAndSettle();

      await _openDrawer(tester);
      expect(find.descendant(of: find.byType(Drawer), matching: find.text('Finale')), findsOneWidget);
      await _closeDrawer(tester);

      await _openDrawer(tester);
      await tester.tap(_drawerActionForItem('Finale', 'Delete item'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Me wins'), findsOneWidget);

      await _openDrawer(tester);
      expect(find.descendant(of: find.byType(Drawer), matching: find.text('Game 1')), findsOneWidget);
      expect(find.descendant(of: find.byType(Drawer), matching: find.text('Finale')), findsNothing);
    });
  });

  group('Mulatschak mode', () {
    testWidgets('supports multiplier-based scoring and winner display', (tester) async {
      await _pumpApp(
        tester,
        sharedPreferences: {
          'app_mode': 'mulatschak',
          'mulatschak_players': jsonEncode({
            'Player 1': 1,
            'Player 2': 21,
          }),
          'current_mulatschak_player': 'Player 1',
        },
      );

      expect(find.text('Current factor: 1x'), findsOneWidget);

      await tester.tap(find.text('-1'));
      await tester.pumpAndSettle();
      expect(find.text('Player 1 wins'), findsOneWidget);

      await tester.tap(find.text('4x'));
      await tester.pumpAndSettle();
      expect(find.text('Current factor: 4x'), findsOneWidget);

      await tester.tap(find.text('+5'));
      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('supports adding, renaming and deleting players', (tester) async {
      await _pumpApp(
        tester,
        sharedPreferences: {
          'app_mode': 'mulatschak',
        },
      );

      await _openDrawer(tester);
      await tester.tap(find.text('Add Player'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Chris');
      await tester.tap(find.widgetWithText(TextButton, 'Add'));
      await tester.pumpAndSettle();

      expect(find.text('Chris'), findsWidgets);

      await tester.tap(_drawerActionForItem('Chris', 'Rename item'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.tap(find.widgetWithText(TextButton, 'Rename'));
      await tester.pumpAndSettle();

      expect(find.text('Alex'), findsWidgets);

      await tester.tap(_drawerActionForItem('Alex', 'Delete item'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      await _closeDrawer(tester);

      expect(find.text('Alex'), findsNothing);
      expect(find.text('Player 1'), findsOneWidget);
    });

    testWidgets('applies muleqack reset settings to scoring', (tester) async {
      await _pumpApp(
        tester,
        sharedPreferences: {
          'app_mode': 'mulatschak',
          'mulatschak_players': jsonEncode({
            'Player 1': 95,
            'Player 2': 21,
          }),
          'current_mulatschak_player': 'Player 1',
        },
      );

      await _openSettings(tester);
      await tester.tap(find.text('Mulatschak'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      await tester.enterText(_textFieldWithLabel('Reset when score reaches'), '100');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.enterText(_textFieldWithLabel('Reset score to'), '50');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('+5'));
      await tester.pumpAndSettle();

      expect(find.text('50'), findsOneWidget);
      expect(find.text('100'), findsNothing);
    });
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> sharedPreferences = const {},
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1440, 2200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(sharedPreferences);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
  scaffoldState.openDrawer();
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await _openDrawer(tester);
  await tester.tap(find.descendant(of: find.byType(Drawer), matching: find.text('Settings')));
  await tester.pumpAndSettle();
}

Future<void> _closeDrawer(WidgetTester tester) async {
  final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
  scaffoldState.closeDrawer();
  await tester.pumpAndSettle();
}

Finder _drawerActionForItem(String itemName, String tooltip) {
  final itemTile = find.ancestor(
    of: find.descendant(of: find.byType(Drawer), matching: find.text(itemName)).last,
    matching: find.byType(ListTile),
  );

  return find.descendant(of: itemTile, matching: find.byTooltip(tooltip));
}

Finder _textFieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
}
