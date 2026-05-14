# StudyFlow

A productivity-focused Flutter application designed to help students maintain focus, track their study progress, and gamify their learning experience.

## 🚀 Features

## Home Page
- Have a calendar to view schedule
- Have a daily goals to see what to do


### 📊 Focus Mode
- **Pomodoro Timer**: Customizable work and break intervals.
- **Real-time Statistics**: Track focus duration and completion rates.
- **Visual Feedback**: Progressive ring animation to visualize progress.
- **Session Tracking**: Log completed focus sessions.

### 🏆 Gamification
- **Points System**: Earn points for every minute of focused study.
- **Daily Streak**: Maintain a streak by studying every day.
- **Levels & Badges**: Unlock achievements and level up your profile.
- **Leaderboard**: Compete with friends and other users.

### 👤 Profile & Social
- **User Profile**: Track total study time and achievements.
- **Friend System**: Connect with friends to share progress.
- **Activity Feed**: View recent activities from your network.

## 🛠️ Built With

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Database**: Firebase (Firestore, Auth)
- **Local Storage**: Hive (for caching and offline support)

## 💻 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 2.12.0)
- Firebase CLI (optional, for local testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/studyflow.git
   cd studyflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
   - Add Android and/or iOS apps to your Firebase project
   - Download the configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)
   - Place them in the correct directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
studyflow/
├── lib/
│   ├── features/             # Feature-based modules
│   │   ├── auth/             # Authentication flows
│   │   ├── focus/            # Focus mode and timer
│   │   ├── gamification/     # Points, levels, badges
│   │   ├── profile/          # User profiles and stats
│   │   └── social/           # Friends and leaderboard
|   |   |_ task/              # Task management
│   ├── core/                 # Core utilities and services
│   ├── shared/               # Shared widgets and constants
│   ├── providers/            # Riverpod providers
│   └── main.dart             # App entry point
├── test/                     # Unit and widget tests
├── android/                  # Android native code
├── ios/                      # iOS native code
└── pubspec.yaml              # Dependencies and project config

task/
│
├── data/
│   ├── models/
│   ├── repositories/
│   ├── datasources/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── viewmodels/
```

## 🧩 Key Riverpod Providers

| Provider | Description |
|----------|-------------|
| `authProvider` | Manages user authentication state |
| `timerProvider` | Handles the Pomodoro timer logic |
| `pointsProvider` | Tracks user points and streak |
| `settingsProvider` | Manages app settings and preferences |
| `networkProvider` | Monitors network connectivity |

## 📋 Scripts

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run the app |
| `flutter test` | Run tests |
| `flutter analyze` | Analyze code quality |
| `flutter build apk --debug` | Build debug APK |

## 🧩 Configuration

The app uses environment variables for configuration. You can set them in a `.env` file in the project root:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Create a feature branch (`git checkout -b feature/AmazingFeature`)
2. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
3. Push to the branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For issues or questions, please open an issue on the repository.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing Flutter framework
- **Riverpod Community** - For the excellent state management solution
- **Firebase Team** - For the powerful backend services

---

