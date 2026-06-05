# BeFit — Fitness & Nutrition App

A cross-platform Flutter fitness app for tracking workouts, planning meals, monitoring health metrics. Built with **Clean Architecture**, **BLoC** state management, and **Firebase** backend.

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![BLoC](https://img.shields.io/badge/State%20Management-BLoC-8B5CF6)](https://bloclibrary.dev)

---

## Features

### Authentication & Onboarding
- Google Sign-In and guest login via Firebase Auth
- Guided onboarding flow (goals, gender, body metrics, activity level)
- Secure local session storage

### Home Dashboard
- Overall health overview with streak tracking
- Active diet plan summary
- Quick actions for core features
- Pull-to-refresh data sync

### Workouts
- Browse exercises from the [ExerciseDB API](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb)
- Filter workouts by body part with an interactive body selector
- Exercise details and workout history stored in Firestore

### Diet & Nutrition
- Create and manage custom diet plans
- Track daily macros (protein, carbs, fats, calories)
- Mark meals as completed
- View diet history

### Food Tracking
- Barcode scanner powered by [Open Food Facts](https://world.openfoodfacts.org)
- Manual food entry and food library management
- Local caching with Hive

### Health Tools
- BMI, water intake, protein, and calorie calculators
- Health metrics charts with `fl_chart`
- Google Fit integration for steps and activity data

---

## Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter, Dart |
| **State Management** | flutter_bloc, equatable |
| **Navigation** | go_router |
| **Backend** | Firebase Auth, Cloud Firestore |
| **Local Storage** | Hive, flutter_secure_storage |
| **DI** | get_it |
| **UI** | flutter_screenutil, lottie, flutter_animate, fl_chart, flutter_svg |
| **APIs** | ExerciseDB (RapidAPI), Open Food Facts |

---

## Architecture

The project follows **Clean Architecture** with a feature-first folder structure:

```
lib/
├── core/                  # Shared config, DI, routes, widgets, services
├── features/
│   ├── auth/              # Google & guest authentication
│   ├── onboarding/        # First-time user setup
│   ├── home/              # Dashboard
│   ├── workout/           # Exercises & workout history
│   ├── diet/              # Diet plans & macro tracking
│   ├── food_item/         # Food library management
│   ├── food_scanner/      # Barcode scanning
│   ├── health/            # Health data overview
│   ├── health_calculator/ # BMI, protein, water, calories
│   ├── health_metrics/    # Metrics charts & Google Fit
│   ├── ai_insights/       # Gemini-powered insights
│   ├── streak/            # Workout streak tracking
│   ├── profile/           # User profile & settings
│   ├── notifications/     # Local & push notifications
│   └── body_part_selection/
└── main.dart
```

Each feature is organized into:

- `data/` — models, datasources, repository implementations
- `domain/` — entities, repositories (interfaces), use cases
- `presentation/` — BLoC, pages, widgets

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.3`
- [Dart SDK](https://dart.dev/get-sdk) `^3.11.3`
- Android Studio / VS Code with Flutter extensions
- A [Firebase](https://console.firebase.google.com/) project
- API keys for:
  - [RapidAPI ExerciseDB](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb)
  - [Google Gemini API](https://aistudio.google.com/app/apikey)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Amrut-03/befit_fitness_1.0.git
cd befit_fitness_1.0
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure API keys

`lib/core/config/secrets.dart` is gitignored. Create it from the example template:

```bash
cp lib/core/config/secrets.example.dart lib/core/config/secrets.dart
```

Then add your keys:

```dart
class Secrets {
  static String exerciseDbApiKey = 'YOUR_RAPIDAPI_KEY';
  static String googleGeminiApiKey = 'YOUR_GEMINI_API_KEY';
}
```

### 4. Set up Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Google Sign-In provider)
3. Create a **Cloud Firestore** database
4. Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` and platform config files (`google-services.json`, etc.).

### 5. Generate Hive adapters (if needed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Run the app

```bash
flutter run
```

---

## Supported Platforms

| Platform | Status |
|----------|--------|
| Android | Supported |
| iOS | Supported |
| Windows | Supported |
| macOS | Supported |
| Linux | Supported |
| Web | Not configured |

---

## Environment Notes

- **Android package**: `com.befit_fitness.app`
- **Design size**: 375 × 812 (iPhone X baseline via `flutter_screenutil`)
- **Minimum Android SDK**: Configured in `android/app/build.gradle.kts`
- Camera permission is required for the barcode scanner feature

---

## Project Scripts

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run on connected device/emulator |
| `flutter build apk` | Build Android APK |
| `flutter build appbundle` | Build Android App Bundle |
| `flutter analyze` | Run static analysis |
| `dart run build_runner build` | Generate Hive type adapters |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## Author

**Amrut** — [GitHub](https://github.com/Amrut-03)

---

## Acknowledgements

- [ExerciseDB API](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb) for workout data
- [Open Food Facts](https://world.openfoodfacts.org) for nutrition data

## App Screenshots

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/08d9246e-d0d7-4f35-9345-50c4a37db609" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/24b94609-531f-4b97-b1e1-65a7de154515" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/8208a1eb-d1d7-40c0-8eb9-94d500263dc5" width="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/40417eb1-6544-4bc8-b99f-f5e0507fe470" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/13e03828-7655-4e8d-9ae6-f09c0c29b9ff" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/f615861a-171c-40fe-8fc6-e97943e48946" width="250"/></td>
  </tr>
</table>
