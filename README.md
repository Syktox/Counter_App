# Counter

Eine einfache Flutter-App zum Verwalten mehrerer Counter. Sie eignet sich zum Verfolgen von Gewohnheiten, Streaks und Countdown-Zielen.

Dieses Repository enthält die Quellgrafik und Konfigurationen, aber nicht die generierten App-Icons oder andere generierbare Flutter-Artefakte.

## Features

- Mehrere Counter verwalten
- Counter hinzufügen und umbenennen
- Einfache Bedienung mit + und - Buttons
- Reset-Funktion für jeden Counter
- Counter werden lokal gespeichert und beim nächsten Start wieder geladen
- Beim ersten Start sind bereits drei Beispiel-Counter vorhanden

## Verwendung

1. **Counter auswählen**: Öffne die Seitenleiste (Drawer) über das Hamburger-Menü in der AppBar und wähle einen Counter aus.
2. **Counter hinzufügen**: In der Seitenleiste auf "Neuer Counter" tippen und einen Namen eingeben.
3. **Counter umbenennen**: In der Seitenleiste auf das Edit-Icon neben dem Counter-Namen tippen.
4. **Zählen**: Verwende die + und - Buttons, um den Counter zu erhöhen oder zu verringern.
5. **Reset**: Drücke den Reset-Button, um den Counter auf 0 zurückzusetzen.

## Standard-Counter beim ersten Start

- `Workout streak`
- `Days without smoking`
- `Days till my next holidays` mit Startwert `100`

## Installation

1. Stelle sicher, dass Flutter installiert ist: [Flutter Installation](https://flutter.dev/docs/get-started/install)
2. Klone dieses Repository oder lade den Code herunter.
3. Navigiere zum Projektverzeichnis und führe `flutter pub get` aus.
4. Erzeuge die plattformspezifischen App-Icons mit `dart run flutter_launcher_icons`.
5. Starte die App mit `flutter run`.

## Generierte Dateien neu erstellen

Nach einem frischen Klon sollten generierte Dateien lokal neu erzeugt werden:

```bash
flutter pub get
dart run flutter_launcher_icons
```

Hinweise:

- Die Launcher-Icons für Android, iOS, Web, Windows und macOS werden aus `assets/icon/app_icon.png` erzeugt.
- Weitere Flutter-Generierungsdateien wie Plugin-Registrants werden beim ersten Build bzw. Run automatisch wieder erstellt.

## Abhängigkeiten

- Flutter SDK
- shared_preferences: Für die lokale Speicherung der Counter
- flutter_launcher_icons: Für die Generierung der App-Icons

## Beitragen

Fühle dich frei, Issues zu melden oder Pull Requests zu erstellen.
