# Professional Flutter Note App 📝

A complete, production-ready Android Note Application built with Flutter using **Material Design 3**, **SharedPreferences** local storage, and **Provider** state management.

## 🌟 Key Features

- 🎨 **Material Design 3 UI**: Dynamic color schemes, rounded cards, smooth animations, and Material 3 expressiveness.
- 🌓 **Light & Dark Theme**: Toggle effortlessly between light and dark modes.
- 📌 **Pin & Unpin Notes**: Keep important notes always at the top of your list.
- 🔍 **Real-time Search**: Search notes instantly by title or content.
- ↕️ **Smart Sorting**: Sort notes by Newest First or Oldest First.
- ⚡ **Auto-Save Note Editor**: Automatically saves notes as you type so you never lose your ideas.
- ✍️ **Character & Word Counter**: Real-time counter displayed in the note editor.
- 🗑️ **Safe Deletion**: Confirmation dialog before deleting any note.
- 💾 **100% Offline Local Storage**: Uses `shared_preferences` for fast, offline JSON persistence. Zero internet permissions required.

## 📁 Project Architecture

```
lib/
├── main.dart               # App entry point & Theme setup
├── models/
│   └── note.dart           # Note data model with JSON serialization
├── services/
│   └── storage_service.dart # Local storage operations using SharedPreferences
├── providers/
│   └── theme_provider.dart # Dark/Light mode state management
├── screens/
│   ├── home_screen.dart    # Main screen with notes grid/list, search, & sort
│   └── note_editor_screen.dart # Auto-saving note editor with character count
└── widgets/
    ├── note_card.dart      # Material 3 Note item widget with pin/delete
    ├── search_bar_widget.dart # Animated search header input
    ├── delete_dialog.dart  # Material 3 confirmation alert dialog
    └── empty_state.dart    # Custom illustration empty view
```

## 🚀 Getting Started

1. **Clone or Download** this repository.
2. Ensure you have **Flutter SDK (3.0.0+)** installed.
3. Run `flutter pub get` to fetch dependencies.
4. Connect an Android device or emulator.
5. Run `flutter run` to launch the application.
6. To build the APK for release:
   ```bash
   flutter build apk --release
   ```
   The generated APK will be available at `build/app/outputs/flutter-apk/app-release.apk`.
