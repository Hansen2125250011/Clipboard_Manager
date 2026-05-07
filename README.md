# 📋 Clipboard History Manager

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

A modern, efficient clipboard management application built with Flutter. Keep track of your clipboard history, sync it across devices via Firebase, and never lose a copied snippet again.

## ✨ Features

- **📜 History Tracking**: Automatically saves everything you copy to a local SQLite database.
- **☁️ Cloud Sync**: Seamlessly sync your snippets to Firebase for multi-device access.
- **⭐ Favorites**: Mark important snippets as favorites for quick access.
- **🔍 Smart Search**: Easily find past snippets using the built-in search functionality.
- **🏷️ Categories**: Automatically distinguishes between plain text and links.
- **🔐 Secure Access**: Built-in Google Sign-In for secure data synchronization.
- **🎨 Modern UI**: Clean, responsive interface following modern design principles.

## 🚀 Tech Stack

- **Frontend**: Flutter & Dart
- **State Management**: Provider
- **Local Database**: SQFlite
- **Backend/Cloud**: Firebase (Auth, Firestore)
- **Utilities**: 
  - `shared_preferences` for local settings.
  - `google_sign_in` for authentication.
  - `intl` for date formatting.
  - `flutter_local_notifications` for background tasks.

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code
- A Firebase project for cloud sync

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/clipboard_history_manager.git
   cd clipboard_history_manager
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add an Android/iOS app to your project.
   - Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in their respective directories.

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── database/     # SQLite configuration and helpers
├── screens/      # UI screens (History, Login, Settings)
├── services/     # Firebase and Cloud synchronization logic
└── main.dart     # App entry point and State Management
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
Built with ❤️ using Flutter.
