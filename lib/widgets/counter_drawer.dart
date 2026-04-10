import 'package:flutter/material.dart';

typedef CounterNameCallback = void Function(String counterName);

class CounterDrawer extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final String addButtonLabel;
  final IconData addButtonIcon;
  final VoidCallback onAddNewItem;
  final CounterNameCallback onSelectItem;
  final CounterNameCallback? onRenameItem;
  final CounterNameCallback onDeleteItem;
  final VoidCallback onOpenSettings;

  const CounterDrawer({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.addButtonLabel,
    required this.addButtonIcon,
    required this.onAddNewItem,
    required this.onSelectItem,
    required this.onRenameItem,
    required this.onDeleteItem,
    required this.onOpenSettings,
  });

  Widget _buildCounterTile(BuildContext context, String counter) {
    final isSelected = counter == selectedItem;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.08),
      title: Text(counter),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRenameItem != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onRenameItem!(counter),
              tooltip: 'Rename item',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => onDeleteItem(counter),
            tooltip: 'Delete item',
          ),
        ],
      ),
      onTap: () {
        onSelectItem(counter);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final counterTiles = items.map((counter) => _buildCounterTile(context, counter));

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ...counterTiles,
                ListTile(
                  leading: Icon(addButtonIcon),
                  title: Text(addButtonLabel),
                  onTap: () {
                    Navigator.of(context).pop();
                    onAddNewItem();
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
