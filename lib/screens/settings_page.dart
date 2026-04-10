import 'package:flutter/material.dart';
import '../models/app_mode.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AppMode currentAppMode;
  final ValueChanged<AppMode> onAppModeChanged;

  const SettingsPage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    required this.currentAppMode,
    required this.onAppModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Modi'),
          ),
          RadioListTile<AppMode>(
            title: const Text('Counter'),
            value: AppMode.counter,
            groupValue: currentAppMode,
            onChanged: (value) {
              if (value != null) {
                onAppModeChanged(value);
              }
            },
          ),
          RadioListTile<AppMode>(
            title: const Text('Watten'),
            value: AppMode.watten,
            groupValue: currentAppMode,
            onChanged: (value) {
              if (value != null) {
                onAppModeChanged(value);
              }
            },
          ),
          RadioListTile<AppMode>(
            title: const Text('Mulatschak'),
            value: AppMode.mulatschak,
            groupValue: currentAppMode,
            onChanged: (value) {
              if (value != null) {
                onAppModeChanged(value);
              }
            },
          ),
          const Divider(),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                onThemeModeChanged(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                onThemeModeChanged(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Mode'),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                onThemeModeChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
