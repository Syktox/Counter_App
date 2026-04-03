import 'package:flutter/material.dart';

typedef CounterNameCallback = void Function(String counterName);

class CounterDrawer extends StatelessWidget {
  final Map<String, int> counters;
  final VoidCallback onAddNewCounter;
  final CounterNameCallback onSelectCounter;
  final CounterNameCallback onRenameCounter;
  final VoidCallback onOpenSettings;

  const CounterDrawer({
    super.key,
    required this.counters,
    required this.onAddNewCounter,
    required this.onSelectCounter,
    required this.onRenameCounter,
    required this.onOpenSettings,
  });

  Widget _buildCounterTile(BuildContext context, String counter) {
    return ListTile(
      title: Text(counter),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => onRenameCounter(counter),
        tooltip: 'Rename counter',
      ),
      onTap: () {
        onSelectCounter(counter);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final counterTiles = counters.keys.map(
      (counter) => _buildCounterTile(context, counter),
    );

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ...counterTiles,
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Counter'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onAddNewCounter();
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
                onOpenSettings();
              },
            ),
          ),
        ],
      ),
    );
  }
}
