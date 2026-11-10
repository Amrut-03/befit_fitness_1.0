# BeFit: Project Audit & Prioritized Task List

_Audit date: 2026-11-09 · ~21k lines of Dart across 15 features · Clean Architecture + flutter_bloc + get_it + go_router + Firebase + Hive_

Work through the tasks **in order**. Each one is sized to fit a single focused session or PR. Tick them off as you go.

---

## Snapshot

| Area | State |
|---|---|
| `flutter analyze` | 0 errors, 0 warnings, **252 infos**: 204 `deprecated_member_use` (mostly `withOpacity`), 30 `avoid_print`, 12 `unnecessary_underscores`, 3 `use_build_context_synchronously` |
| Tests | 1 file (`test/widget_test.dart`) covering only `GoalCalculator` / `MacroCalculator` |
| Repo | **Public** on GitHub (`Amrut-03/befit_fitness_1.0`) |
| Platforms | Android only. iOS has no Firebase config and still uses the `com.example.fitnessApp` bundle ID |
| Firestore rules | None in the repo (`firestore.rules` is missing) |
| Uncommitted | Gradle/Kotlin DSL migration, `http` dep, analyzer excludes, `android_backup/`, `ios/Podfile`, `GoogleService-Info.plist` |

### What's working well
- A consistent feature-first Clean Architecture layout (data / domain / presentation) in most features.
- `secrets.dart` is gitignored and has never been committed. `secrets.example.dart` is provided.
- Release signing now reads from `key.properties`, with a debug fallback.
- The step and calorie estimation (`ActivityEstimator`) and goal and macro calculators are pure and testable.

---

## P0: Security & release blockers (do these first)

### ◐ 1. Rotate the leaked upload keystore
> **Progress (2026-11-09):** ✅ Purged `upload-keystore.jks` and `upload_certificate.pem` from all history and force-pushed (`c7a8e39` → `31f0dbd`). ✅ Backup bundle and old key saved to `~/keystores/befit/`. ✅ `android/key.properties` template created (gitignored). ⏳ Generate the new key, set the passwords, and do the Play upload-key reset if the app is on Play. ⏳ Ask GitHub Support to purge cached views of the old commits.

- `upload-keystore.jks` was committed and then deleted in `4e9b355`. **It's still in the public git history.**
- If that keystore was ever registered as your Play upload key, request an **upload key reset** in Play Console and generate a new keystore.
- Optional: purge it from history with `git filter-repo --path upload-keystore.jks --invert-paths` and force-push. The rotation is the real fix, because anyone may already have cloned the file.
- Also review whether `upload_certificate.pem` (tracked at the root) needs to be public. It's only a cert, so this is low risk, but move it out of the repo.
- **Done when:** a new upload key is active and the old `.jks` can't be used.

### ◐ 2. Take API keys out of the app binary
> **Progress (2026-11-09):** Both old keys were already dead (Gemini: "API key not valid"; RapidAPI: "not subscribed", so Workouts was broken). Instead of Cloud Functions (which need the Blaze plan):
> - ✅ Workouts now use the **free OSS ExerciseDB** (`oss.exercisedb.dev/api/v1`, no key) with server-side `bodyParts` filtering and cursor pagination. This also covers most of task 11.
> - ✅ AI Insights now use **Firebase AI Logic** (`firebase_ai` 4.0.0, `gemini-3.1-flash-lite`, structured JSON output). No key in the app.
> - ✅ `secrets.dart` and `secrets.example.dart` deleted, README updated, 11 new tests (16 total, all passing), debug APK builds.
> - ⏳ **You:** enable AI Logic in Firebase Console (Gemini Developer API), then delete the old Gemini key in Google Cloud → Credentials and the RapidAPI app key.
> - ⏳ App Check enforcement for AI Logic is part of task 3.

_Original plan:_
- `Secrets.exerciseDbApiKey` (RapidAPI) and `Secrets.googleGeminiApiKey` are compiled into the APK. Anyone can extract them with `strings`/`jadx`.
- Move both calls behind a **Firebase Cloud Function** (callable, gated by Firebase Auth plus App Check). The app calls the function, and the keys live in Secret Manager.
  - `lib/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart` (Gemini; the key is also sent in the URL query string)
  - `lib/features/workout/data/datasources/remote/workout_remote_datasource.dart` (RapidAPI header)
- Rotate both keys after the move.
- **Done when:** `grep -r "Secrets\." lib` returns nothing and the APK contains no keys.

### ◐ 3. Add Firestore security rules
> **Progress (2026-11-10):**
> - ✅ `firestore.rules`: owner-only access to `users/{uid}` and every subcollection under it, default deny for everything else. Wired into `firebase.json` (plus a Firestore emulator config). `.firebaserc` defaults to `fitness-app-9dac8`.
> - ✅ Emulator tests in `firestore_tests/` (`cd firestore_tests && npm install && npm test`): 11 tests, all passing. Covers the owner, another user, an anonymous guest, unauthenticated access, all 5 subcollections, listing `users`, and default deny.
> - ✅ App Check client: `firebase_app_check` 0.4.9 is activated in `main.dart` (Play Integrity / App Attest in release, the debug provider otherwise). Firebase AI Logic picks it up automatically. Debug APK builds and all 16 Dart tests pass.
> - ⏳ **You:** run `firebase deploy --only firestore:rules`.
> - ⏳ **You:** in Console → App Check, register the Android app with Play Integrity (add the SHA-256 of the **new** upload key from task 1, plus the Play app-signing key) and add your debug token. Watch the metrics for a few days, then **Enforce** for Cloud Firestore and Firebase AI Logic. There are no Cloud Functions yet, so nothing to enforce there.

_Original plan:_
- No `firestore.rules` exists, so your production rules are whatever is set in the console.
- Add `firestore.rules` restricting `users/{uid}/**` to `request.auth.uid == uid`, and wire it into `firebase.json`. Deploy with `firebase deploy --only firestore:rules`.
- Enable **App Check** (Play Integrity) for Firestore and Functions.
- **Done when:** the rules are versioned, deployed, and tested in the emulator (another user's doc is denied).

### ◐ 4. Make "Delete account" actually delete data (Play Store policy)
> **Progress (2026-11-10):** Done on the client side, with no Cloud Function needed (no Blaze plan). The owner-only rules from task 3 allow the deletes.
> - ✅ `AuthRepositoryImpl.deleteAccount()`: re-authenticate with Google first (anonymous users skip this) → delete `users/{uid}` and all 5 subcollections in batches (`UserDataRemoteDataSource`, server reads so it fails fast when offline) → `user.delete()` + `googleSignIn.disconnect()` → clear all user Hive boxes (`UserDataLocalDataSource`) and the cached user.
> - ✅ A typed `AccountDeletionException` covers cancelled, requires-recent-login, wrong account, network, and unknown, with a friendly message for each. When deletion fails, the bloc restores `AuthAuthenticated`.
> - ✅ A "Delete Account" tile in Profile (`profile/presentation/widgets/delete_account_tile.dart`) shows a confirmation dialog and a progress indicator, then goes to `/login`.
> - ✅ Also fixed: the logout dialog's **Cancel** button logged you out (`pop(true)`). `SplashRedirectPage` now uses `context.go`, part of task 7, so deletion errors don't bounce you to `/login`.
> - ✅ 11 new tests (27 total, all passing).
> - ⏳ **You:** Play also requires a **web** URL where users can request deletion without the app (Data safety → Data deletion). Host a simple page or form, e.g. on Firebase Hosting or GitHub Pages, that explains the in-app path and gives a contact email. This ties into task 29.
> - ⚠️ New `users/{uid}` subcollections must be added to `UserDataRemoteDataSource.userSubcollections`, and new user Hive boxes to the `UserDataLocalDataSource` registration in `injection_container.dart`.

_Original plan:_
- `AuthRemoteDataSource.deleteAccount()` only calls `user.delete()`. The `users/{uid}` doc and its subcollections (`workoutHistory`, diet, food, metrics) are orphaned, and Hive boxes aren't cleared.
- `user.delete()` throws `requires-recent-login` for older sessions, and that error is swallowed as "Delete account failed".
- Fix: delete user data server-side (a Cloud Function, or the "Delete User Data" extension), handle reauth, then clear local storage.
- Also: `AuthDeleteRequested` is never dispatched anywhere in the UI. Wire it into Profile.
- **Done when:** deleting an account removes all Firestore and local data, and Play's data-deletion form can point to this flow.

### ✅ 5. Commit and clean the current working tree
> **Done (2026-11-10)** on branch `chore/p0-security-cleanup`, in 5 commits: build/config → task 2 → task 3 → task 4 → this file.
> - `android_backup/` moved to `~/flutter_projects/befit_backups/android_backup_2026-11-05`. It held only the old Gradle setup, no keystores.
> - `/android/build/` added to `.gitignore`.
> - Both `google-services.json` and `GoogleService-Info.plist` are tracked. They hold public identifiers, protected by the rules from task 3 and App Check. Both still reference the iOS bundle ID `com.example.fitnessApp`, which task 13 will change.

_Original plan:_
- Review and commit the pending Gradle (Kotlin `compilerOptions`, signing), `pubspec` (`http`), and `analysis_options` changes.
- Delete `android_backup/` (or move it outside the repo). Add `android/build/` to `.gitignore`.
- Decide whether `google-services.json` and `GoogleService-Info.plist` should be tracked. They aren't secret, but they should be consistent across platforms.
- **Done when:** `git status` is clean.

---

## P1: Broken or half-wired features (user-visible bugs)

### ☐ 6. Fix logout so it uses AuthBloc and clears per-user state
- `profile_screen.dart:645` calls `FirebaseAuth.instance.signOut()` directly. That skips `GoogleSignIn.signOut()` (the account picker is auto-skipped next time) and leaves the cached user in secure storage.
- All 12 blocs are app-scoped in `main.dart` and loaded **before login**. After logout, the next user sees the previous user's diet, food, streak, and profile.
- Hive boxes (`profile_box`, `food_box`, `diet_box`, `health_metrics_box`, `notifications`) are not keyed by uid and not cleared on logout.
- Fix: dispatch `AuthLogoutRequested` → clear the Hive boxes → reset or recreate the user-scoped blocs (or scope them below an authenticated shell route).
- **Done when:** logging out and signing in as a different user shows only that user's data.

### ☐ 7. Fix the auth/startup flow
- `AuthRepositoryImpl.getCurrentUser()` falls back to the **cached** user when Firebase says no one is signed in, so the app can show "authenticated" with no Firebase session. Drop that fallback.
- `SplashRedirectPage` uses `context.push('/home')` / `push('/login')`, which stacks routes so back navigation returns to the splash screen. Use `context.go`.
- There are two sources of truth: the go_router `redirect` (which queries Firestore on **every** navigation via `_hasCompletedProfile`) and `StartupPage` / `OnboardingProfileBloc` / `AuthBloc`. Consolidate into one: an auth plus profile-completed notifier (`refreshListenable`), cached in memory.
- `AuthBloc._authSubscription` / `_AuthUserChanged` are declared but never subscribed.
- **Done when:** cold start → correct screen in a single redirect, there are no Firestore reads per navigation, and back from Home exits the app.

### ☐ 8. Fix the streak (it never increments)
- `UpdateStreakEvent` is **never dispatched**, so the streak is stuck. Dispatch it on a meaningful action (a workout saved, meals completed, or app open, whichever you decide).
- `StreakRemoteDatasource.updateStreak()` compares raw timestamps with `.inDays`. For example, 11 PM → 8 AM the next day gives `0` days, so it counts as the "same day". Compare **local calendar dates** (`DateTime(y,m,d)`) instead.
- `.update()` throws if `users/{uid}` doesn't exist. Use `set(..., SetOptions(merge: true))`.
- Make it a Firestore transaction to avoid races.
- **Done when:** unit tests cover same day, next day, gap of 2+ days, and late-night to early-morning.

### ☐ 9. Wire up notifications (currently dead code)
- `NotificationService.instance.initialize()` is **never called**, so FCM, local notifications, and the in-app notification list never work.
- `NotificationSchedulerService` (`core/services/notification_schedular_service.dart`) isn't referenced anywhere.
- The notification settings toggles (`profile/presentation/pages/notification_page.dart`) are `setState` only. They don't persist and don't schedule anything.
- The notification `id: DateTime.now().millisecondsSinceEpoch` exceeds 32-bit int, which **crashes on Android**. Use `% 0x7fffffff` or a counter.
- There's no `FirebaseMessaging.onBackgroundMessage` handler, no iOS `DarwinInitializationSettings`, and `tz.initializeTimeZones()` / `flutter_timezone` need to be set up before `zonedSchedule`.
- Remove the duplicate `NotificationPage`s (`features/notifications/...` vs `features/profile/.../notification_page.dart`): rename the settings one to `notification_settings_page.dart`.
- **Done when:** toggles persist, reminders fire at the scheduled time, and FCM messages appear in the list.

### ☐ 10. Re-enable AI Insights properly
- `LoadAIInsightsEvent` is commented out in `home_page.dart`, and when it was enabled it used hardcoded fake data (`steps: 12450, streak: 18`).
- Feed real values from `HealthBloc`, `StreakBloc`, and profile BMI.
- Cache insights per day. `ai_insights_local_datasource.dart` is an empty 1-line file, so implement it (Hive) to avoid calling the API on every home load.
- Parsing is fragile: `data['candidates'][0]...` with no null checks, and it returns however many lines the model sends. Use structured JSON output (`responseMimeType: application/json`) and cap at 4.
- Check that the `gemini-2.0-flash` / `v1` endpoint is still available and move to a current model if needed. This is done server-side, via task 2.
- There are two `ai_insight_card.dart` widgets (`ai_insights/...` and `home/...`). Keep one.
- **Done when:** Home shows real, cached, once-a-day insights with loading, error, and offline states.

### ☐ 11. Fix the body-part workout filter
- `getExercises()` fetches only 20 exercises and then filters by body part **client-side**, so most body parts show an empty list.
- Use ExerciseDB's `/exercises/bodyPart/{bodyPart}` endpoint with pagination (`limit`/`offset`), and add infinite scroll in `WorkoutListPage`.
- Cache the exercise list (Hive) because RapidAPI quota is limited.
- **Done when:** every selectable body part returns results and scrolling loads more.

### ☐ 12. Remove crash-prone `currentUser!`
- `diet_remote_datasource.dart` (lines 66, 75, 140) and `workout_remote_datasource.dart` (lines 58, 72) force-unwrap `auth.currentUser!`. These throw if a stream is still listening after logout.
- Use a shared `_uid` getter that throws a typed `UnauthenticatedException`, and cancel Firestore stream subscriptions on logout.
- **Done when:** a logout while on the Diet or Workout screens doesn't crash.

### ☐ 13. Make iOS work (or explicitly drop it)
- `DefaultFirebaseOptions.currentPlatform` only has `android`, so the iOS app **throws on startup**. Run `flutterfire configure` for iOS.
- Change the bundle ID from `com.example.fitnessApp` to e.g. `com.befit.fitness`.
- Add `NSCameraUsageDescription` to `Info.plist` (the barcode scanner crashes without it), plus Google Sign-In `CFBundleURLTypes` (`REVERSED_CLIENT_ID`).
- Set the display name to "BeFit" on both platforms (Android `android:label="fitness_app"`, iOS "Fitness App").
- **Done when:** the app launches, signs in, and scans on a real iPhone.

### ☐ 14. Open Food Facts integration
- It uses the legacy `/api/v0/product/{barcode}.json`. Move to `/api/v2/product/{barcode}?fields=...` to cut payload size.
- OFF asks apps to send a descriptive `User-Agent` (`BeFit/1.0 (contact)`). Add one.
- Handle no network or timeouts (no `timeout` is set on `http` calls anywhere).
- **Done when:** the scanner works with v2 and shows clean not-found and offline states.

---

## P2: Architecture & code quality

### ☐ 15. Introduce error handling with `Failure` / `Either`
- Repos throw raw `Exception(response.body)` and blocs put `e.toString()` straight into the UI.
- Add `core/error/failures.dart` and `exceptions.dart`, and have repos return `Either<Failure, T>` (`fpdart`) or a sealed `Result<T>`. Map failures to user-friendly messages.
- Add a shared `ApiClient` wrapper around `http` with timeouts, User-Agent, and error mapping. Inject it through get_it instead of using top-level `http.get`.

### ☐ 16. Fix the layering leaks
- `AppRouter` and `HomeBloc` call `FirebaseAuth.instance` / `FirebaseFirestore.instance` directly. Go through use cases instead.
- `HealthRepositoryImpl` depends on `OnboardingRepository`, a cross-feature repo. Inject a `GetUserProfile` use case or a shared profile source.
- The profile data lives in two features (onboarding and profile) that both read `users/{uid}`. Merge them into one `UserProfile` repository.
- `NotificationService` pulls dependencies from the `sl` service locator internally. Inject them instead.
- `FoodItemsRepositoryImpl.getFoodItems()`: one stream error stops the stream permanently and falls back to cache. Use `handleError` and keep listening, or rely on Firestore's built-in offline persistence and drop the manual Hive cache.

### ☐ 17. Scope blocs correctly
- Only truly global blocs (Auth, maybe Profile) belong in `main.dart`. Feature blocs (Workout, Diet, FoodItems, FoodScanner, BodySelection, HealthCalculator) should be provided at their route, or under a `ShellRoute` for authenticated pages.
- That stops 5 network calls from firing at app launch before the user is known.

### ☐ 18. Split `injection_container.dart` (450 lines)
- Create a per-feature `register<Feature>Dependencies()` in each feature folder and call them from `init()`.
- Consider `injectable` for codegen.
- Move Hive box opening into a `StorageModule`.

### ☐ 19. Clean the analyzer to 0 issues
- Replace `withOpacity(x)` → `withValues(alpha: x)` (204 hits; a mechanical sed is safe).
- Replace `print` → `dart:developer` `log` or a `logger` package (37 calls, some log user objects). Strip them in release builds.
- `Share.shareXFiles` → `SharePlus.instance.share(ShareParams(...))`; `Switch.activeColor` → `activeThumbColor`.
- Fix the 3 `use_build_context_synchronously` cases with `if (!context.mounted) return;`.
- Rename `core/widgets/showHistoryDetailBottomSheet.dart` → `show_history_detail_bottom_sheet.dart`.
- Fix typos in paths: `entites/` → `entities/`, `notifation_repository.dart`, `health_calculator_reposittory.dart`, `notification_schedular_service.dart`, `diet_planing_page.dart`, and `domain/repository/` (streak) vs `repositories/`.
- Then enable stricter lints (`very_good_analysis`, or add `prefer_const_constructors`, `always_declare_return_types`, `unawaited_futures`).

### ☐ 20. Delete dead code
Unreferenced files:
- `features/home/presentation/widgets/macros_chart_card.dart`
- `features/auth/presentation/widgets/guest_signin_button.dart`
- `features/diet/data/datasources/local/diet_local_datasource.dart`
- `features/diet/presentation/widgets/diet_detail_bottom_sheet.dart`
- `features/diet/presentation/widgets/food_entry_card.dart`
- `features/ai_insights/data/datasources/local/ai_insights_local_datasource.dart` (empty; implement it in task 10 or delete it)

Also move `hive_generator` and `build_runner` from `dependencies` to `dev_dependencies` in `pubspec.yaml`.

### ☐ 21. Centralize theme & design tokens
- There's no `ThemeData`, and there are **739** hardcoded `Colors.*` / `Color(0x…)` usages.
- Create `core/theme/app_colors.dart`, `app_text_styles.dart`, and `app_theme.dart` (dark theme), then pass `theme:` to `MaterialApp.router`.
- Migrate screen by screen, starting with the biggest: `profile_screen.dart` (782 lines), `overall_health_card.dart` (691), `diet_detail_page.dart` (624).

### ☐ 22. Break up the large widgets
Files over 400 lines: `profile_screen`, `overall_health_card`, `diet_detail_page`, `manual_food_entry_page`, `home_page`, `health_calculator_page`, `edit_profile_screen`, `health_metrics_chart`. Extract private widgets into `widgets/` and keep each page under ~250 lines.

### ☐ 23. Typed routing
- Routes rely on `state.extra as String` / `as ProfileEntity` (non-nullable casts), which crash on deep links or restored state. Use `go_router_builder` typed routes, or path/query params with null-safe fallbacks.
- Move route paths into a `Routes` constants class.

---

## P3: Testing, CI, release polish

### ☐ 24. Unit tests for domain and data
- Priority targets: `ActivityEstimator`, streak date logic (after task 8), the health calculator use cases, model `fromJson`/`toJson`, and repository error mapping.
- Use `mocktail` for repos and datasources, and `fake_cloud_firestore` / `firebase_auth_mocks` for remote datasources.

### ☐ 25. Bloc tests
- Use `bloc_test` for AuthBloc, StreakBloc, DietBloc, FoodItemsBloc, and WorkoutBloc (load, success, error, refresh).

### ☐ 26. Widget & golden tests
- Cover Login, onboarding steps, and the Home dashboard states (loading, loaded, error). Add an integration test for the onboarding → home flow.

### ☐ 27. CI pipeline
- Add `.github/workflows/ci.yml`: `flutter analyze --fatal-infos`, `dart format --set-exit-if-changed`, `flutter test --coverage`, and `flutter build apk --debug`.
- Generate `secrets.dart` from the example in CI, or drop it entirely after task 2.

### ☐ 28. Crash reporting & analytics
- Add `firebase_crashlytics` (wire `FlutterError.onError` and `PlatformDispatcher.onError`) and `firebase_analytics` for key events (sign-in, workout saved, meal completed, scan).

### ☐ 29. Release hardening
- Android: enable R8 (`isMinifyEnabled`, `isShrinkResources`) with keep rules for Firebase and Hive. Bump `targetSdk` to the version Play currently requires. Check whether `SCHEDULE_EXACT_ALARM` is needed (Play restricts it), and use inexact alarms if possible.
- Add a native splash screen (`flutter_native_splash`, since `assets/splash_screen/` exists but is untracked) and run `flutter_launcher_icons` for both platforms.
- Prepare a privacy policy URL, the Data Safety form (health and fitness data, location none, camera), and the account-deletion URL (task 4).
- Bump the version in `pubspec.yaml`. Build the `appbundle` with `--obfuscate --split-debug-info`.

### ☐ 30. Guest account upgrade
- Anonymous guests lose all data if they uninstall or sign out. Offer "Save your progress" with `linkWithCredential(GoogleAuthProvider)` to convert a guest into a Google account.

---

## P4: Feature ideas (after the above)

- [ ] **Health Connect / HealthKit** (the `health` package) instead of only the raw pedometer, to get accurate steps, calories, sleep, and heart rate.
- [ ] **Water intake tracker** with reminders (ties into task 9).
- [ ] **Workout session mode**: sets, reps, rest timer, and the saved session feeding the streak.
- [ ] **Weekly progress report** charts (weight trend, macros adherence) on Home.
- [ ] **On-device AI coach** with Gemma via MediaPipe / TFLite (like ExpenseFlow), so insights work offline and need no API key.
- [ ] **Localization** (`flutter_localizations` + ARB), starting with English and Hindi/Kannada.
- [ ] **Accessibility pass**: semantics labels, text scaling (ScreenUtil plus `textScaler`), and contrast on the dark theme.

---

## Suggested order at a glance

```
Week 1  : 1 → 2 → 3 → 4 → 5          (security & compliance)
Week 2  : 6 → 7 → 8 → 12             (auth/state correctness)
Week 3  : 9 → 10 → 11 → 14 → 13      (finish half-built features, iOS)
Week 4  : 15 → 16 → 17 → 18 → 19 → 20 (architecture & lint cleanup)
Week 5  : 21 → 22 → 23               (UI structure)
Week 6+ : 24 → 30, then P4           (tests, CI, release, new features)
```
