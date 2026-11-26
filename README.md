# BeFit — Fitness & Nutrition App

A Flutter fitness app for Android and iOS: workouts, meal plans, health metrics and an AI coach that runs **on the device** (Gemma) with a cloud fallback (Gemini). Built with **Clean Architecture**, **BLoC** state management and a **Firebase** backend.

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM%20%7C%20AI%20Logic-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![BLoC](https://img.shields.io/badge/State%20Management-BLoC-8B5CF6)](https://bloclibrary.dev)
[![CI](https://github.com/Amrut-03/befit_fitness_1.0/actions/workflows/ci.yml/badge.svg)](https://github.com/Amrut-03/befit_fitness_1.0/actions/workflows/ci.yml)

---

## Features

### AI Coach (on-device first)
- Chat coach that streams answers token by token, grounded in the user's own goals, diet and activity
- Runs **Gemma 3 1B (int4)** on the device through MediaPipe LLM Inference (`flutter_edge_ai`): no network, no API key
- Model is downloaded on demand (with progress and cancel) and only offered on devices with enough RAM
- Falls back to **Gemini via Firebase AI Logic** when the on-device model isn't installed, isn't supported or fails
- Safety layer: emergency and medical questions (English, Hindi, Marathi) get a fixed safe reply instead of generated text
- AI insights on the Home dashboard, using the same on-device → cloud strategy

### Authentication & Onboarding
- Google Sign-In and guest login via Firebase Auth, with guest → Google account upgrade
- Guided onboarding flow (goals, gender, body metrics, activity level)
- Account deletion removes all of the user's data

### Home Dashboard
- Health overview with streak tracking, active diet plan summary and quick actions
- Pull-to-refresh data sync

### Workouts
- Browse 1,500+ exercises from the open-source [ExerciseDB API](https://docs.exercisedb.dev)
- Filter by muscle with an interactive body diagram ([`flutter_body_part_selector`](https://pub.dev/packages/flutter_body_part_selector), my own package)
- Workout session mode: sets, rest timer and workout streak
- Workout history stored in Firestore

### Diet & Nutrition
- Create and manage diet plans, track daily macros, mark meals as completed, view history
- Barcode scanner powered by [Open Food Facts](https://world.openfoodfacts.org)
- Food library with local caching in Hive

### Health
- **Health Connect** (Android) and **Apple Health** (iOS) integration for steps and activity
- Water intake tracker with goal-aware reminders
- BMI, water, protein and calorie calculators
- Health metric charts with `fl_chart`
- Weekly progress report with weight trend and macro adherence

### Localization & Accessibility
- English, Hindi and Marathi with an in-app language picker
- Text scaling up to the largest system size without overflow, contrast checks and screen-reader labels (verified in widget tests)

---

## Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter, Dart |
| **Architecture** | Clean Architecture, feature-first |
| **State Management** | flutter_bloc (BLoC + Cubit), equatable |
| **DI** | get_it |
| **Navigation** | go_router |
| **Backend** | Firebase Auth, Cloud Firestore (security rules), FCM, App Check |
| **AI** | Gemma on-device (flutter_edge_ai + MediaPipe), Gemini via Firebase AI Logic |
| **Observability** | Firebase Crashlytics, Firebase Analytics |
| **Local Storage** | Hive, flutter_secure_storage |
| **Health** | health (Health Connect / HealthKit), pedometer_2 |
| **UI** | flutter_screenutil, lottie, flutter_animate, fl_chart, flutter_svg |
| **APIs** | ExerciseDB (open source), Open Food Facts |
| **Testing** | flutter_test, bloc_test, mocktail, fake_cloud_firestore, golden tests, Firestore emulator rule tests |

---

## Architecture

Clean Architecture with a feature-first folder structure:

```
lib/
├── core/                  # DI, routes, theme, l10n, AI runtime, health, observability, shared widgets
├── features/
│   ├── auth/              # Google & guest authentication
│   ├── onboarding/        # First-time user setup
│   ├── home/              # Dashboard
│   ├── ai_coach/          # On-device / cloud AI coach chat
│   ├── ai_insights/       # AI insights on Home
│   ├── workout/           # Exercises, sessions & history
│   ├── streak/            # Workout streak tracking
│   ├── body_part_selection/
│   ├── diet/              # Diet plans & macro tracking
│   ├── food_item/         # Food library management
│   ├── food_scanner/      # Barcode scanning
│   ├── health/            # Health Connect / Apple Health
│   ├── health_calculator/ # BMI, protein, water, calories
│   ├── health_metrics/    # Metric charts
│   ├── water_intake/      # Water tracker & reminders
│   ├── progress_report/   # Weekly report
│   ├── notifications/     # Local & push notifications
│   └── profile/           # Profile, language & settings
└── main.dart
```

Each feature is split into:

- `data/` — models, datasources, repository implementations
- `domain/` — entities, repository interfaces, use cases
- `presentation/` — BLoC/Cubit, pages, widgets

### On-device AI design

- `OnDeviceLlm` (domain-facing interface) is implemented by `GemmaOnDeviceLlm`; the coach repository tries it first and falls back to Gemini.
- MediaPipe instead of LiteRT-LM because LiteRT-LM needs Android minSdk 30 and BeFit supports API 29.
- The engine initialises lazily, so app start-up pays nothing until AI is used.
- Generation is serialised (one session at a time) so the coach and Home insights never overlap.
- Android loads the model on the GPU and retries on CPU; iOS uses CPU, since GPU loading exceeds the iOS memory limit.

---

## Quality

- **Tests:** unit, BLoC, widget, golden and accessibility tests (`flutter test`), plus Firestore security-rule tests against the emulator (`firestore_tests/`)
- **CI:** GitHub Actions runs format check, `flutter analyze --fatal-infos`, tests with coverage, a debug APK build and the rules tests on every PR
- **Release:** obfuscated builds with Dart symbols kept for Crashlytics (`tool/build_release.sh`, see `docs/RELEASE.md`)
- **Security:** no API keys in the app binary; AI goes through Firebase AI Logic protected by App Check

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.3`
- Android Studio / Xcode
- A [Firebase](https://console.firebase.google.com/) project
- No third-party API keys are needed.

---

## Getting Started

### 1. Clone and install

```bash
git clone https://github.com/Amrut-03/befit_fitness_1.0.git
cd befit_fitness_1.0
flutter pub get
```

### 2. Set up Firebase

1. Create a Firebase project
2. Enable **Authentication** (Google Sign-In provider)
3. Create a **Cloud Firestore** database and deploy `firestore.rules`
4. Enable **AI Logic** → **Gemini Developer API** (works on the free Spark plan)
5. Run `flutterfire configure` to generate `lib/firebase_options.dart` and the platform config files

### 3. Run

```bash
flutter run
```

To enable the on-device coach, upload a Gemma `.task` model and pass its URL:

```bash
flutter run --dart-define=GEMMA_MODEL_URL=https://.../gemma3-1b-it-int4.task
```

Without it the coach uses Gemini in the cloud.

---

## Supported Platforms

| Platform | Status |
|----------|--------|
| Android | Supported (API 29+) |
| iOS | Supported |

---

## Project Scripts

| Command | Description |
|---------|-------------|
| `flutter run` | Run on a connected device/emulator |
| `flutter test` | Run the test suite |
| `flutter analyze` | Static analysis |
| `tool/build_release.sh` | Release AAB + per-ABI APKs, obfuscated |

---

## Author

**Amrut Khochikar** — [GitHub](https://github.com/Amrut-03) · [LinkedIn](https://www.linkedin.com/in/amrut-khochikar/)
