import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';
import '../models/app_mode.dart';
import '../models/watten_game.dart';
import '../services/counter_storage_service.dart';
import '../services/url_launcher_service.dart';
import '../widgets/counter_controls.dart';
import '../widgets/counter_drawer.dart';
import 'settings_page.dart';

enum WattenSide { me, you }

class _HomePageSnapshot {
  final Map<String, int> counters;
  final String currentCounter;
  final Map<String, WattenGame> wattenGames;
  final String currentWattenGame;
  final WattenSide selectedWattenSide;
  final Map<String, int> mulatschakPlayers;
  final String currentMulatschakPlayer;
  final int mulatschakMultiplier;
  final bool muleqackEnabled;
  final int muleqackTriggerPoints;
  final int muleqackResetPoints;
  final AppMode appMode;

  const _HomePageSnapshot({
    required this.counters,
    required this.currentCounter,
    required this.wattenGames,
    required this.currentWattenGame,
    required this.selectedWattenSide,
    required this.mulatschakPlayers,
    required this.currentMulatschakPlayer,
    required this.mulatschakMultiplier,
    required this.muleqackEnabled,
    required this.muleqackTriggerPoints,
    required this.muleqackResetPoints,
    required this.appMode,
  });
}

class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AppMode appMode;
  final ValueChanged<AppMode> onAppModeChanged;

  const HomePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.appMode,
    required this.onAppModeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> counters = Map<String, int>.from(
    CounterStorageService.defaultCounters,
  );
  String currentCounter = CounterStorageService.defaultCurrentCounter;
  Map<String, WattenGame> wattenGames = Map<String, WattenGame>.from(
    CounterStorageService.defaultWattenGames,
  );
  String currentWattenGame = CounterStorageService.defaultCurrentWattenGame;
  WattenSide selectedWattenSide = WattenSide.me;
  Map<String, int> mulatschakPlayers = Map<String, int>.from(
    CounterStorageService.defaultMulatschakPlayers,
  );
  String currentMulatschakPlayer =
      CounterStorageService.defaultCurrentMulatschakPlayer;
  int mulatschakMultiplier = CounterStorageService.defaultMulatschakMultiplier;
  bool muleqackEnabled = CounterStorageService.defaultMuleqackEnabled;
  int muleqackTriggerPoints = CounterStorageService.defaultMuleqackTriggerPoints;
  int muleqackResetPoints = CounterStorageService.defaultMuleqackResetPoints;
  final List<_HomePageSnapshot> _undoStack = [];
  bool _isLoadingCounters = true;

  @override
  void initState() {
    super.initState();
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    final storedData = await CounterStorageService.load();
    if (!mounted) {
      return;
    }

    widget.onAppModeChanged(storedData.appMode);
    setState(() {
      counters = storedData.counters;
      currentCounter = storedData.currentCounter;
      wattenGames = storedData.wattenGames;
      currentWattenGame = storedData.currentWattenGame;
      mulatschakPlayers = storedData.mulatschakPlayers;
      currentMulatschakPlayer = storedData.currentMulatschakPlayer;
      mulatschakMultiplier = storedData.mulatschakMultiplier;
      muleqackEnabled = storedData.muleqackEnabled;
      muleqackTriggerPoints = storedData.muleqackTriggerPoints;
      muleqackResetPoints = storedData.muleqackResetPoints;
      _isLoadingCounters = false;
    });
  }

  Future<void> _saveCounters({AppMode? appMode}) {
    return CounterStorageService.save(
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
      appMode: appMode ?? widget.appMode,
    );
  }

  _HomePageSnapshot _createSnapshot({AppMode? appMode}) {
    return _HomePageSnapshot(
      counters: LinkedHashMap<String, int>.from(counters),
      currentCounter: currentCounter,
      wattenGames: LinkedHashMap<String, WattenGame>.from(wattenGames),
      currentWattenGame: currentWattenGame,
      selectedWattenSide: selectedWattenSide,
      mulatschakPlayers: LinkedHashMap<String, int>.from(mulatschakPlayers),
      currentMulatschakPlayer: currentMulatschakPlayer,
      mulatschakMultiplier: mulatschakMultiplier,
      muleqackEnabled: muleqackEnabled,
      muleqackTriggerPoints: muleqackTriggerPoints,
      muleqackResetPoints: muleqackResetPoints,
      appMode: appMode ?? widget.appMode,
    );
  }

  void _pushUndoSnapshot({AppMode? appMode}) {
    _undoStack.add(_createSnapshot(appMode: appMode));
  }

  void _undoLastAction() {
    if (_undoStack.isEmpty) {
      return;
    }

    final snapshot = _undoStack.removeLast();
    widget.onAppModeChanged(snapshot.appMode);
    setState(() {
      counters = LinkedHashMap<String, int>.from(snapshot.counters);
      currentCounter = snapshot.currentCounter;
      wattenGames = LinkedHashMap<String, WattenGame>.from(snapshot.wattenGames);
      currentWattenGame = snapshot.currentWattenGame;
      selectedWattenSide = snapshot.selectedWattenSide;
      mulatschakPlayers = LinkedHashMap<String, int>.from(
        snapshot.mulatschakPlayers,
      );
      currentMulatschakPlayer = snapshot.currentMulatschakPlayer;
      mulatschakMultiplier = snapshot.mulatschakMultiplier;
      muleqackEnabled = snapshot.muleqackEnabled;
      muleqackTriggerPoints = snapshot.muleqackTriggerPoints;
      muleqackResetPoints = snapshot.muleqackResetPoints;
    });
    _saveCounters(appMode: snapshot.appMode);
  }

  void _handleAppModeChanged(AppMode mode) {
    if (mode == widget.appMode) {
      return;
    }

    _pushUndoSnapshot();
    widget.onAppModeChanged(mode);
    _saveCounters(appMode: mode);
  }

  void _increment() {
    _pushUndoSnapshot();
    setState(() {
      counters[currentCounter] = counters[currentCounter]! + 1;
    });
    _saveCounters();
  }

  void _decrement() {
    if (counters[currentCounter]! <= 0) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      counters[currentCounter] = counters[currentCounter]! - 1;
    });
    _saveCounters();
  }

  void _reset() {
    if (counters[currentCounter] == 0) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      counters[currentCounter] = 0;
    });
    _saveCounters();
  }

  void _selectCounter(String counter) {
    setState(() {
      currentCounter = counter;
    });
    _saveCounters();
  }

  bool _isCounterNameValid(String counterName) {
    return counterName.isNotEmpty && !counters.containsKey(counterName);
  }

  bool _isWattenGameNameValid(String gameName) {
    return gameName.isNotEmpty && !wattenGames.containsKey(gameName);
  }

  bool _isMulatschakPlayerNameValid(String playerName) {
    return playerName.isNotEmpty && !mulatschakPlayers.containsKey(playerName);
  }

  String? _wattenWinner(WattenGame game) {
    if (game.me > 10 && game.me > game.you) {
      return 'Me';
    }
    if (game.you > 10 && game.you > game.me) {
      return 'You';
    }
    return null;
  }

  String? _mulatschakWinner() {
    for (final entry in mulatschakPlayers.entries) {
      if (entry.value == 0) {
        return entry.key;
      }
    }
    return null;
  }

  void _addCounterToList(String counterName) {
    _pushUndoSnapshot();
    setState(() {
      counters[counterName] = 0;
      currentCounter = counterName;
    });
    _saveCounters();
  }

  void _renameCounter(String oldName, String newName) {
    _pushUndoSnapshot();
    setState(() {
      final value = counters[oldName]!;
      counters.remove(oldName);
      counters[newName] = value;
      if (currentCounter == oldName) {
        currentCounter = newName;
      }
    });
    _saveCounters();
  }

  void _deleteCounter(String counterName) {
    if (counters.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one counter must remain.')),
      );
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      counters.remove(counterName);
      if (currentCounter == counterName) {
        currentCounter = counters.keys.first;
      }
    });
    _saveCounters();
  }

  void _selectWattenGame(String gameName) {
    setState(() {
      currentWattenGame = gameName;
    });
    _saveCounters();
  }

  void _renameMulatschakPlayer(String oldName, String newName) {
    _pushUndoSnapshot();
    setState(() {
      final value = mulatschakPlayers[oldName]!;
      mulatschakPlayers.remove(oldName);
      mulatschakPlayers[newName] = value;
      if (currentMulatschakPlayer == oldName) {
        currentMulatschakPlayer = newName;
      }
    });
    _saveCounters();
  }

  void _reorderCounters(int oldIndex, int newIndex) {
    _pushUndoSnapshot();
    setState(() {
      final entries = counters.entries.toList();
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final movedEntry = entries.removeAt(oldIndex);
      entries.insert(newIndex, movedEntry);
      counters = LinkedHashMap<String, int>.fromEntries(entries);
    });
    _saveCounters();
  }

  void _reorderMulatschakPlayers(int oldIndex, int newIndex) {
    _pushUndoSnapshot();
    setState(() {
      final entries = mulatschakPlayers.entries.toList();
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final movedEntry = entries.removeAt(oldIndex);
      entries.insert(newIndex, movedEntry);
      mulatschakPlayers = LinkedHashMap<String, int>.fromEntries(entries);
    });
    _saveCounters();
  }

  void _addWattenGame(String gameName) {
    _pushUndoSnapshot();
    setState(() {
      wattenGames[gameName] = const WattenGame(me: 0, you: 0);
      currentWattenGame = gameName;
      selectedWattenSide = WattenSide.me;
    });
    _saveCounters();
  }

  void _deleteWattenGame(String gameName) {
    if (wattenGames.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one game must remain.')),
      );
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      wattenGames.remove(gameName);
      if (currentWattenGame == gameName) {
        currentWattenGame = wattenGames.keys.first;
      }
    });
    _saveCounters();
  }

  void _selectMulatschakPlayer(String playerName) {
    setState(() {
      currentMulatschakPlayer = playerName;
    });
    _saveCounters();
  }

  void _addMulatschakPlayer(String playerName) {
    _pushUndoSnapshot();
    setState(() {
      mulatschakPlayers[playerName] = 21;
      currentMulatschakPlayer = playerName;
    });
    _saveCounters();
  }

  void _deleteMulatschakPlayer(String playerName) {
    if (mulatschakPlayers.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one player must remain.')),
      );
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      mulatschakPlayers.remove(playerName);
      if (currentMulatschakPlayer == playerName) {
        currentMulatschakPlayer = mulatschakPlayers.keys.first;
      }
    });
    _saveCounters();
  }

  void _updateMulatschakScore(int baseDelta) {
    final currentValue = mulatschakPlayers[currentMulatschakPlayer]!;
    final delta = baseDelta * mulatschakMultiplier;
    final rawNextValue = currentValue + delta;

    if (rawNextValue < 0) {
      return;
    }

    _pushUndoSnapshot();
    final nextValue =
        muleqackEnabled
            ? _applyMuleqackReset(rawNextValue)
            : rawNextValue;

    setState(() {
      mulatschakPlayers[currentMulatschakPlayer] = nextValue;
    });
    _saveCounters();
  }

  int _applyMuleqackReset(int score) {
    final resetDifference = muleqackTriggerPoints - muleqackResetPoints;

    if (resetDifference <= 0) {
      return score;
    }

    var adjustedScore = score;
    while (adjustedScore >= muleqackTriggerPoints) {
      adjustedScore -= resetDifference;
    }

    return adjustedScore;
  }

  void _resetMulatschakPlayers() {
    _pushUndoSnapshot();
    setState(() {
      mulatschakPlayers.updateAll((key, value) => 21);
    });
    _saveCounters();
  }

  void _setMulatschakMultiplier(int multiplier) {
    if (mulatschakMultiplier == multiplier) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      mulatschakMultiplier = multiplier;
    });
    _saveCounters();
  }

  void _setMuleqackEnabled(bool enabled) {
    if (muleqackEnabled == enabled) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      muleqackEnabled = enabled;
    });
    _saveCounters();
  }

  void _setMuleqackTriggerPoints(int points) {
    if (muleqackTriggerPoints == points) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      muleqackTriggerPoints = points;
    });
    _saveCounters();
  }

  void _setMuleqackResetPoints(int points) {
    if (muleqackResetPoints == points) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      muleqackResetPoints = points;
    });
    _saveCounters();
  }

  void _updateWattenScore(int delta) {
    final currentGame = wattenGames[currentWattenGame]!;
    final currentValue =
        selectedWattenSide == WattenSide.me ? currentGame.me : currentGame.you;
    final nextValue = currentValue + delta;

    if (nextValue < 0) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      wattenGames[currentWattenGame] =
          selectedWattenSide == WattenSide.me
              ? currentGame.copyWith(me: nextValue)
              : currentGame.copyWith(you: nextValue);
    });
    _saveCounters();
  }

  Widget _buildWattenControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _updateWattenScore(2),
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 80)),
              child: const Text('+2', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => _updateWattenScore(3),
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 80)),
              child: const Text('+3', style: TextStyle(fontSize: 28)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetWattenSelectedSide,
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 80)),
          child: const Text('Reset', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
  }

  void _resetWattenSelectedSide() {
    final currentGame = wattenGames[currentWattenGame]!;
    final currentValue =
        selectedWattenSide == WattenSide.me ? currentGame.me : currentGame.you;

    if (currentValue == 0) {
      return;
    }

    _pushUndoSnapshot();
    setState(() {
      wattenGames[currentWattenGame] =
          selectedWattenSide == WattenSide.me
              ? currentGame.copyWith(me: 0)
              : currentGame.copyWith(you: 0);
    });
    _saveCounters();
  }

  void _showAddCounterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCounterName = '';
        return AlertDialog(
          title: const Text('Add Counter'),
          content: TextField(
            onChanged: (value) {
              newCounterName = value;
            },
            decoration: const InputDecoration(hintText: 'Counter name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_isCounterNameValid(newCounterName)) {
                  _addCounterToList(newCounterName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddWattenGameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newGameName = '';
        return AlertDialog(
          title: const Text('Add Game'),
          content: TextField(
            onChanged: (value) {
              newGameName = value.trim();
            },
            decoration: const InputDecoration(hintText: 'Game name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_isWattenGameNameValid(newGameName)) {
                  _addWattenGame(newGameName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMulatschakPlayerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newPlayerName = '';
        final textController = TextEditingController();
        final focusNode = FocusNode();

        void submit() {
          final trimmedName = newPlayerName.trim();
          if (_isMulatschakPlayerNameValid(trimmedName)) {
            _addMulatschakPlayer(trimmedName);
            Navigator.of(context).pop();
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
          if (textController.text.isNotEmpty) {
            textController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: textController.text.length,
            );
          }
        });

        return AlertDialog(
          title: const Text('Add Player'),
          content: TextField(
            controller: textController,
            focusNode: focusNode,
            autofocus: true,
            onChanged: (value) {
              newPlayerName = value;
            },
            onSubmitted: (_) => submit(),
            decoration: const InputDecoration(hintText: 'Player name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: submit,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCounterDialog(String oldName) {
    _showRenameItemDialog(
      title: 'Rename Counter',
      initialValue: oldName,
      hintText: 'New counter name',
      isValidName: (newName) => newName == oldName || _isCounterNameValid(newName),
      onRename: (newName) {
        if (newName != oldName) {
          _renameCounter(oldName, newName);
        }
      },
    );
  }

  void _showRenameMulatschakPlayerDialog(String oldName) {
    _showRenameItemDialog(
      title: 'Rename Player',
      initialValue: oldName,
      hintText: 'New player name',
      isValidName: (newName) =>
          newName == oldName || _isMulatschakPlayerNameValid(newName),
      onRename: (newName) {
        if (newName != oldName) {
          _renameMulatschakPlayer(oldName, newName);
        }
      },
    );
  }

  void _showRenameItemDialog({
    required String title,
    required String initialValue,
    required String hintText,
    required bool Function(String newName) isValidName,
    required ValueChanged<String> onRename,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItemName = initialValue;
        final controller = TextEditingController(text: initialValue);
        final focusNode = FocusNode();

        void submit() {
          final trimmedName = newItemName.trim();
          if (trimmedName.isNotEmpty && isValidName(trimmedName)) {
            onRename(trimmedName);
            Navigator.of(context).pop();
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        });

        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            onChanged: (value) {
              newItemName = value;
            },
            onSubmitted: (_) => submit(),
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: submit,
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCounterDialog(String counterName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Counter'),
          content: Text('Do you really want to delete "$counterName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCounter(counterName);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteWattenGameDialog(String gameName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Game'),
          content: Text('Do you really want to delete "$gameName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteWattenGame(gameName);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteMulatschakPlayerDialog(String playerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Player'),
          content: Text('Do you really want to delete "$playerName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteMulatschakPlayer(playerName);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDonateUrl() async {
    await UrlLauncherService.openDonateUrl(context);
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoStack.isEmpty ? null : _undoLastAction,
            tooltip: 'Undo',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _openDonateUrl,
            tooltip: 'Donate',
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final isWattenMode = widget.appMode == AppMode.watten;
    final isMulatschakMode = widget.appMode == AppMode.mulatschak;

    return CounterDrawer(
      items: isWattenMode
          ? wattenGames.keys.toList()
          : isMulatschakMode
          ? mulatschakPlayers.keys.toList()
          : counters.keys.toList(),
      selectedItem: isWattenMode
          ? currentWattenGame
          : isMulatschakMode
          ? currentMulatschakPlayer
          : currentCounter,
      addButtonLabel: isWattenMode
          ? 'Add Game'
          : isMulatschakMode
          ? 'Add Player'
          : 'New Counter',
      addButtonIcon: isWattenMode
          ? Icons.add
          : isMulatschakMode
          ? Icons.person_add_alt_1
          : Icons.add,
      closeDrawerOnAdd: !isMulatschakMode,
      enableReorder: !isWattenMode,
      onAddNewItem: isWattenMode
          ? _showAddWattenGameDialog
          : isMulatschakMode
          ? _showAddMulatschakPlayerDialog
          : _showAddCounterDialog,
      onSelectItem: (item) {
        if (isWattenMode) {
          _selectWattenGame(item);
          return;
        }
        if (isMulatschakMode) {
          _selectMulatschakPlayer(item);
          return;
        }
        _selectCounter(item);
      },
      onRenameItem: isWattenMode
          ? null
          : isMulatschakMode
          ? (player) {
              _showRenameMulatschakPlayerDialog(player);
            }
          : (counter) {
              _showRenameCounterDialog(counter);
            },
      onDeleteItem: (item) {
        if (isWattenMode) {
          _showDeleteWattenGameDialog(item);
          return;
        }
        if (isMulatschakMode) {
          _showDeleteMulatschakPlayerDialog(item);
          return;
        }
        _showDeleteCounterDialog(item);
      },
      onReorderItems: isWattenMode
          ? null
          : isMulatschakMode
          ? _reorderMulatschakPlayers
          : _reorderCounters,
      onOpenSettings: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SettingsPage(
              currentThemeMode: widget.themeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
              currentAppMode: widget.appMode,
              onAppModeChanged: _handleAppModeChanged,
              muleqackEnabled: muleqackEnabled,
              muleqackTriggerPoints: muleqackTriggerPoints,
              muleqackResetPoints: muleqackResetPoints,
              onMuleqackEnabledChanged: _setMuleqackEnabled,
              onMuleqackTriggerPointsChanged: _setMuleqackTriggerPoints,
              onMuleqackResetPointsChanged: _setMuleqackResetPoints,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterBody() {
    if (_isLoadingCounters) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            currentCounter,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${counters[currentCounter]}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          CounterControls(
            onIncrement: _increment,
            onDecrement: _decrement,
            onReset: _reset,
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWattenSideCard({
    required String title,
    required int score,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDesktopCard =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          constraints: BoxConstraints(
            minHeight: isDesktopCard ? 260 : 220,
            maxHeight: isDesktopCard ? 300 : 260,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.45)
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWattenBody() {
    if (_isLoadingCounters) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentGame = wattenGames[currentWattenGame]!;
    final winner = _wattenWinner(currentGame);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (winner != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.45),
                  width: 2,
                ),
              ),
              child: Text(
                '$winner wins',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildWattenSideCard(
                  title: 'Me',
                  score: currentGame.me,
                  isSelected: selectedWattenSide == WattenSide.me,
                  onTap: () {
                    setState(() {
                      selectedWattenSide = WattenSide.me;
                    });
                  },
                ),
                _buildWattenSideCard(
                  title: 'You',
                  score: currentGame.you,
                  isSelected: selectedWattenSide == WattenSide.you,
                  onTap: () {
                    setState(() {
                      selectedWattenSide = WattenSide.you;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildWattenControls(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMulatschakPlayerCard(String playerName, int score) {
    final isSelected = playerName == currentMulatschakPlayer;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentMulatschakPlayer = playerName;
        });
        _saveCounters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.45)
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playerName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            Text(
              '$score',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMulatschakMultiplierSelector() {
    const baseMultipliers = [1, 2, 4, 8, 16];
    const extraMultipliers = [32, 64, 128];
    final dropdownValue = extraMultipliers.contains(mulatschakMultiplier)
        ? mulatschakMultiplier
        : extraMultipliers.first;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...baseMultipliers.map((multiplier) {
          final isSelected = mulatschakMultiplier == multiplier;
          return ChoiceChip(
            label: Text('${multiplier}x'),
            selected: isSelected,
            onSelected: (_) => _setMulatschakMultiplier(multiplier),
          );
        }),
        DropdownButton<int>(
          value: dropdownValue,
          borderRadius: BorderRadius.circular(16),
          items: extraMultipliers
              .map(
                (multiplier) => DropdownMenuItem<int>(
                  value: multiplier,
                  child: Text('${multiplier}x'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _setMulatschakMultiplier(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMulatschakControls() {
    return Column(
      children: [
        const Text(
          'Multiplier',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _buildMulatschakMultiplierSelector(),
        const SizedBox(height: 10),
        Text(
          'Current factor: ${mulatschakMultiplier}x',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _updateMulatschakScore(-1),
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 80)),
              child: const Text('-1', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => _updateMulatschakScore(1),
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 80)),
              child: const Text('+1', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => _updateMulatschakScore(5),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 80)),
              child: const Text('+5', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetMulatschakPlayers,
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 80)),
          child: const Text('Reset', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
  }

  Widget _buildMulatschakBody() {
    if (_isLoadingCounters) {
      return const Center(child: CircularProgressIndicator());
    }

    final winner = _mulatschakWinner();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Column(
        children: [
          if (winner != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.45),
                  width: 2,
                ),
              ),
              child: Text(
                '$winner wins',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: mulatschakPlayers.entries
                    .map(
                      (entry) =>
                          _buildMulatschakPlayerCard(entry.key, entry.value),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildMulatschakControls(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileDrawerGesture =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      drawerEdgeDragWidth: isMobileDrawerGesture ? screenWidth * 0.5 : null,
      body: widget.appMode == AppMode.watten
          ? _buildWattenBody()
          : widget.appMode == AppMode.mulatschak
          ? _buildMulatschakBody()
          : _buildCounterBody(),
    );
  }
}
