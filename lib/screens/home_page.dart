import 'package:flutter/material.dart';
import '../services/counter_storage_service.dart';
import '../widgets/counter_controls.dart';
import '../widgets/counter_drawer.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HomePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> counters = Map<String, int>.from(
    CounterStorageService.defaultCounters,
  );
  String currentCounter = CounterStorageService.defaultCurrentCounter;
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

    setState(() {
      counters = storedData.counters;
      currentCounter = storedData.currentCounter;
      _isLoadingCounters = false;
    });
  }

  Future<void> _saveCounters() {
    return CounterStorageService.save(
      counters: counters,
      currentCounter: currentCounter,
    );
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

  AppBar _buildAppBar() {
    return AppBar();
  }

  Widget _buildDrawer() {
    return CounterDrawer(
      counters: counters,
      onAddNewCounter: _showAddCounterDialog,
      onSelectCounter: (counter) {
        _selectCounter(counter);
      },
      onRenameCounter: (counter) {
        _showRenameCounterDialog(counter);
      },
      onOpenSettings: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SettingsPage(
              currentThemeMode: widget.themeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }
}
