import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/counter_controls.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  void _addCounter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCounterName = '';
        return AlertDialog(
          title: const Text('Neuen Counter hinzufügen'),
          content: TextField(
            onChanged: (value) {
              newCounterName = value;
            },
            decoration: const InputDecoration(hintText: 'Name des Counters'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (newCounterName.isNotEmpty &&
                    !counters.containsKey(newCounterName)) {
                  setState(() {
                    counters[newCounterName] = 0;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  void _editCounter(String oldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCounterName = oldName;
        return AlertDialog(
          title: const Text('Counter umbenennen'),
          content: TextField(
            controller: TextEditingController(text: oldName),
            onChanged: (value) {
              newCounterName = value;
            },
            decoration: const InputDecoration(
              hintText: 'Neuer Name des Counters',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (newCounterName.isNotEmpty &&
                    !counters.containsKey(newCounterName)) {
                  setState(() {
                    int value = counters[oldName]!;
                    counters.remove(oldName);
                    counters[newCounterName] = value;
                    if (currentCounter == oldName) {
                      currentCounter = newCounterName;
                    }
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Umbenennen'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Titel in der AppBar entfernt, nur Spenden-Icon bleibt
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _openDonateUrl,
            tooltip: 'Spenden',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: SizedBox.shrink(),
            ),
            ...counters.keys.map((String counter) {
              return ListTile(
                title: Text(counter),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editCounter(counter),
                ),
                onTap: () {
                  _selectCounter(counter);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Neuer Counter'),
              onTap: () {
                Navigator.of(context).pop();
                _addCounter();
              },
            ),
          ],
        ),
      ),
      body: Padding(
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
          ],
        ),
      ),
    );
  }
}
