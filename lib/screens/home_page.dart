import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/counter_controls.dart';
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
  Map<String, int> counters = {'Zigaretten': 0};
  String currentCounter = 'Zigaretten';

  void _increment() {
    setState(() {
      counters[currentCounter] = counters[currentCounter]! + 1;
    });
  }

  void _decrement() {
    setState(() {
      if (counters[currentCounter]! > 0) {
        counters[currentCounter] = counters[currentCounter]! - 1;
      }
    });
  }

  void _reset() {
    setState(() {
      counters[currentCounter] = 0;
    });
  }

  void _selectCounter(String counter) {
    setState(() {
      currentCounter = counter;
    });
  }

  bool _isCounterNameValid(String counterName) {
    return counterName.isNotEmpty && !counters.containsKey(counterName);
  }

  void _addCounterToList(String counterName) {
    setState(() {
      counters[counterName] = 0;
    });
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

  Future<void> _openDonateUrl() async {
    const url =
        'https://www.paypal.com/donate/?hosted_button_id=YOUR_BUTTON_ID';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Spenden-URL konnte nicht geöffnet werden.'),
        ),
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      // Only donation button, no title
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: _openDonateUrl,
          tooltip: 'Donate',
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ...counters.keys.map((String counter) {
                  return ListTile(
                    title: Text(counter),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showRenameCounterDialog(counter),
                    ),
                    onTap: () {
                      _selectCounter(counter);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Counter'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddCounterDialog();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      currentThemeMode: widget.themeMode,
                      onThemeModeChanged: widget.onThemeModeChanged,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            currentCounter,
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
