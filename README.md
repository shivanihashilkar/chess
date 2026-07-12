# Chess Tournament Management System

Flutter app — Dart · Riverpod · SQLite

## Features
- **Players** — Create, Read, Update, Delete players (name, email, rating)
- **Tournaments** — Full CRUD with date picker and status tracking
- **Enroll Players** — Add/remove players from any tournament
- **Random Match System** — Auto-pairs players randomly and picks random winners
- **Rankings** — 1st 🥇, 2nd 🥈, 3rd 🥉 place with full match results

---

## ⚡ Quick Setup (do this once)

> Make sure Flutter is installed: https://flutter.dev/docs/get-started/install

### Step 1 — Create a new Flutter project
```bash
flutter create chess_tournament
cd chess_tournament
```

### Step 2 — Replace lib/ and pubspec.yaml with the files from this ZIP
Copy the `lib/` folder and `pubspec.yaml` from this ZIP into the `chess_tournament` folder,
overwriting the existing ones.

### Step 3 — Get packages and run
```bash
flutter pub get
flutter run
```

That's it! 🎉

---

## Folder Structure
```
lib/
├── main.dart
├── app.dart
├── models/
│   ├── player.dart
│   ├── tournament.dart
│   └── match_result.dart
├── database/
│   └── database_helper.dart     ← SQLite via sqflite
├── providers/
│   ├── player_provider.dart     ← Riverpod state
│   ├── tournament_provider.dart
│   └── match_provider.dart      ← random pairing + rankings
└── screens/
    ├── home_screen.dart
    ├── players/
    │   ├── players_screen.dart
    │   └── player_form_screen.dart
    ├── tournaments/
    │   ├── tournaments_screen.dart
    │   ├── tournament_form_screen.dart
    │   └── tournament_detail_screen.dart
    └── matches/
        └── rankings_screen.dart
```

## How to use the app
1. Go to **Players** tab → tap **Add Player** to create players
2. Go to **Tournaments** tab → tap **New Tournament**
3. Open a tournament → tap **Add** to enroll at least 2 players
4. Tap **Generate Matches & Run Tournament** — random pairs are created and winners picked
5. Tap **View Rankings & Results** to see the podium
