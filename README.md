# StudyFlow - Smart Schedule & Study Management Ecosystem

StudyFlow is a comprehensive productivity and study management ecosystem designed to help students optimize their schedule, track progress, maintain focus, and gamify their learning experience. The project consists of a cross-platform mobile application built with Flutter and a modern backend API server built with ASP.NET Core (.NET 8) backed by a PostgreSQL database.

---

## Key Features

### Smart Schedule & Task Management
*   **Integrated Calendar:** Track weekly and monthly schedules with an interactive calendar interface powered by Table Calendar.
*   **Task Management:** Create, edit, delete, and manage the completion status of study tasks and homework.

### Focus Mode
*   **Pomodoro Timer:** Customize study and break intervals to optimize learning performance.
*   **Session Tracking:** Save completed study sessions to the database to track actual focus duration.

### Study Pet & Gamification
*   **Flame Game Engine:** Interactive virtual study pet rendered and controlled using the Flame Engine.
*   **XP & Leveling System:** Pets earn experience points (XP) and level up as users complete tasks or focus sessions.
*   **Achievements & Badges:** Unlock achievements and display unique badges on the user profile.
*   **Daily Streak:** Keep a daily study streak alive, complete with reminder alerts before the streak expires.

### Document OCR Scanning
*   **Text Recognition:** Integrated with Google ML Kit Text Recognition to scan printed or handwritten text from the camera or gallery.
*   **Image Processing:** Supports image compression (flutter_image_compress) and cropping/rotation (image_cropper) before OCR processing.
*   **Document Management:** Save scanned documents to the server with storage quota tracking (StorageQuota). Includes a secure Trash folder supporting restoration or permanent deletion (individual or batch).
*   **Text Search:** Instantly search through scanned documents using the recognized text content.

### Notifications & Settings
*   **Local & Push Notifications:** Schedule smart reminders using flutter_local_notifications synchronized with the device's local timezone.
*   **Localization & Themes:** Fully supports multilingual localization and seamless Light/Dark mode switching.

---

## Technology Stack

### Frontend (Mobile App)
*   **Language & Framework:** Dart & Flutter SDK
*   **State Management:** Provider (ChangeNotifierProvider, MultiProvider, Consumer)
*   **UI & Animations:** Lottie & Flutter Animate
*   **Data Visualization:** FL Chart (for study statistics)
*   **Game Engine:** Flame Engine (for virtual study pet)
*   **AI/OCR Integration:** Google ML Kit Text Recognition
*   **Local Cache:** Shared Preferences (for lightweight caching & configurations)
*   **Authentication:** Firebase Authentication (supporting Email/Password & Google Sign-In)

### Backend (API Server)
*   **Language & Framework:** C# & ASP.NET Core (Web API .NET 8)
*   **Database:** PostgreSQL (connected via Npgsql.EntityFrameworkCore.PostgreSQL, ready for semantic search & AI suggestions using the pgvector extension)
*   **ORM:** Entity Framework Core (auto-applies pending migrations on startup)
*   **Authentication:** Firebase JWT Bearer Token verification
*   **Hosted Background Services:**
    *   `ReminderWorker`: Scans schedules and triggers push/local notifications.
    *   `TrashCleanupService`: Automatically deletes expired files in the trash.

---

## Project Directory Structure

### Frontend (Flutter)
```text
studyflow/
├── lib/
│   ├── core/                 # Shared configurations and system utilities
│   │   ├── di/               # Dependency Injection setup (getProviders)
│   │   ├── providers/        # Global system providers (Language, Performance)
│   │   ├── services/         # Global notification, AuthGate, and SnackBar services
│   │   ├── theme/            # Theme Configuration (Light & Dark Theme)
│   │   └── widgets/          # Global reusable widgets (AnimatedBackground, etc.)
│   ├── features/             # Feature-driven Clean Architecture modules
│   │   ├── auth/             # Login (Email, Google), Sign-up, and Profiles
│   │   ├── focus/            # Pomodoro timer and focus analytics
│   │   ├── gamification/     # Point systems, badges, and virtual pet UI (PetViewModel)
│   │   ├── home/             # Main navigation hub
│   │   ├── notification/     # User notifications and notification settings
│   │   ├── scan/             # OCR Scanning, document search, and trash management
│   │   ├── schedule/         # Weekly/monthly calendar schedules
│   │   ├── streak/           # Daily study streak calculators & widgets
│   │   └── task/             # Task CRUD operations (TaskViewModel)
│   ├── shared/               # Global constants and helpers
│   ├── l10n/                 # App localization files (multilingual support)
│   └── main.dart             # Application entry point
├── assets/                   # Lottie animations, static images, and pet assets
└── pubspec.yaml              # Flutter dependencies and assets config
```

### Backend (.NET API)
```text
StudyFlowBackend/
└── StudyFlowBackend/
    ├── Configurations/       # Service configurations
    ├── Controllers/          # API Controllers (Tasks, Focus, ScannedDocuments, Pets, etc.)
    ├── Data/                 # DB Context and Entity Framework Migrations
    ├── Models/               # DB Entity models (User, StudyTask, StudyPet, etc.)
    ├── Repositories/         # Repository pattern implementations
    ├── Services/             # Business logic & hosted background workers
    ├── Program.cs            # API middleware pipelines and services registry
    └── appsettings.json      # PostgreSQL connection string and environment variables
```

---

## Getting Started

### Prerequisites
*   Flutter SDK (latest version)
*   .NET SDK 8
*   PostgreSQL Database instance

### Environment Setup
1.  **Frontend (.env):** Create a `.env` file in the root of your Flutter project:
    ```env
    API_URL=http://localhost:5000/api
    ```
2.  **Backend (appsettings.json):** Set up your PostgreSQL Connection String:
    ```json
    {
      "ConnectionStrings": {
        "DefaultConnection": "Host=localhost;Database=studyflow;Username=your_username;Password=your_password"
      }
    }
    ```

### Running the Backend (.NET API)
1.  Navigate to the backend directory:
    ```bash
    cd StudyFlowBackend/StudyFlowBackend
    ```
2.  Run the application:
    ```bash
    dotnet run
    ```
    *The server will automatically apply any pending Entity Framework database migrations on startup.*

### Running the Frontend (Flutter)
1.  Retrieve dependencies:
    ```bash
    flutter pub get
    ```
2.  Start the app on an emulator, simulator, or physical device:
    ```bash
    flutter run
    ```

---

## Contributing
Contributions are welcome! Please open an issue or submit a pull request on the repository to suggest improvements or report bugs.
