import 'package:flutter/material.dart';
import '../models/app_mode.dart';
import '../models/watten_game.dart';
import '../services/counter_storage_service.dart';
import '../services/url_launcher_service.dart';
import '../widgets/counter_controls.dart';
import '../widgets/counter_drawer.dart';
import 'settings_page.dart';

enum WattenSide { me, you }

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
      _isLoadingCounters = false;
    });
  }

  Future<void> _saveCounters({AppMode? appMode}) {
    return CounterStorageService.save(
      counters: counters,
      currentCounter: currentCounter,
      wattenGames: wattenGames,
      currentWattenGame: currentWattenGame,
      appMode: appMode ?? widget.appMode,
    );
  }

  void _handleAppModeChanged(AppMode mode) {
    widget.onAppModeChanged(mode);
    _saveCounters(appMode: mode);
  }

  void _increment() {
    setState(() {
      counters[currentCounter] = counters[currentCounter]! + 1;
    });
    _saveCounters();
  }

  void _decrement() {
    setState(() {
      if (counters[currentCounter]! > 0) {
        counters[currentCounter] = counters[currentCounter]! - 1;
      }
    });
    _saveCounters();
  }

  void _reset() {
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

  String? _wattenWinner(WattenGame game) {
    if (game.me > 10 && game.me > game.you) {
      return 'Me';
    }
    if (game.you > 10 && game.you > game.me) {
      return 'You';
    }
    return null;
  }

  void _addCounterToList(String counterName) {
    setState(() {
      counters[counterName] = 0;
      currentCounter = counterName;
    });
    _saveCounters();
  }

  void _renameCounter(String oldName, String newName) {
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

  void _addWattenGame(String gameName) {
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

    setState(() {
      wattenGames.remove(gameName);
      if (currentWattenGame == gameName) {
        currentWattenGame = wattenGames.keys.first;
      }
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

  void _showRenameCounterDialog(String oldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCounterName = oldName;
        return AlertDialog(
          title: const Text('Rename Counter'),
          content: TextField(
            controller: TextEditingController(text: oldName),
            onChanged: (value) {
              newCounterName = value;
            },
            decoration: const InputDecoration(hintText: 'New counter name'),
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
                  _renameCounter(oldName, newCounterName);
                }
                Navigator.of(context).pop();
              },
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

  Future<void> _openDonateUrl() async {
    await UrlLauncherService.openDonateUrl(context);
  }

  AppBar _buildAppBar() {
    return AppBar(
      actions: [
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

    return CounterDrawer(
      items: isWattenMode ? wattenGames.keys.toList() : counters.keys.toList(),
      selectedItem: isWattenMode ? currentWattenGame : currentCounter,
      addButtonLabel: isWattenMode ? 'Add Game' : 'New Counter',
      addButtonIcon: isWattenMode ? Icons.sports_score : Icons.add,
      onAddNewItem: isWattenMode ? _showAddWattenGameDialog : _showAddCounterDialog,
      onSelectItem: (item) {
        if (isWattenMode) {
          _selectWattenGame(item);
          return;
        }
        _selectCounter(item);
      },
      onRenameItem: isWattenMode
          ? null
          : (counter) {
              _showRenameCounterDialog(counter);
            },
      onDeleteItem: (item) {
        if (isWattenMode) {
          _showDeleteWattenGameDialog(item);
          return;
        }
        _showDeleteCounterDialog(item);
      },
      onOpenSettings: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SettingsPage(
              currentThemeMode: widget.themeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
              currentAppMode: widget.appMode,
              onAppModeChanged: _handleAppModeChanged,
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          constraints: const BoxConstraints(minHeight: 220, maxHeight: 260),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: widget.appMode == AppMode.watten
          ? _buildWattenBody()
          : _buildCounterBody(),
    );
  }
}
