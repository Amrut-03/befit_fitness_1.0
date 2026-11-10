import 'package:fitness_app/core/l10n/l10n.dart';
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
> - ⚠️ New `users/{uid}` subcollections must be added to `UserDataRemoteDataSource.userSubcollections`, and new user Hive boxes to `StorageModule.userScoped` (`lib/core/di/storage_module.dart`), which feeds `UserDataLocalDataSource`.

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

### ◐ 6. Fix logout so it uses AuthBloc and clears per-user state
> **Progress (2026-11-10):** ✅ Profile logout dispatches `AuthLogoutRequested`, which signs out of Google and Firebase and clears every user Hive box plus the cached user. ✅ The user-scoped blocs moved from `main.dart` into `UserScope`, a `MultiBlocProvider` **keyed by uid**, so a logout or user switch closes them (cancelling their Firestore streams) and recreates them empty. Providers are lazy, so nothing loads before sign-in. ✅ The logout dialog's Cancel button bug is fixed. ⏳ Verify on a device: log out, then sign in as a different user.

_Original plan:_
- `profile_screen.dart:645` calls `FirebaseAuth.instance.signOut()` directly. That skips `GoogleSignIn.signOut()` (the account picker is auto-skipped next time) and leaves the cached user in secure storage.
- All 12 blocs are app-scoped in `main.dart` and loaded **before login**. After logout, the next user sees the previous user's diet, food, streak, and profile.
- Hive boxes (`profile_box`, `food_box`, `diet_box`, `health_metrics_box`, `notifications`) are not keyed by uid and not cleared on logout.
- Fix: dispatch `AuthLogoutRequested` → clear the Hive boxes → reset or recreate the user-scoped blocs (or scope them below an authenticated shell route).
- **Done when:** logging out and signing in as a different user shows only that user's data.

### ◐ 7. Fix the auth/startup flow
> **Progress (2026-11-10):** ✅ `core/session/SessionNotifier` is the single source of truth (unknown, signedOut, needsProfile, ready, error). It checks the profile **once per sign-in**, caches it in memory, and is the router's `refreshListenable`. ✅ The redirect is a pure, unit-tested `SessionRedirect.resolve()` with **no Firestore reads per navigation**. ✅ `StartupPage` is now a splash with a Retry button for offline errors. `SplashRedirectPage`, `AuthStarted` and the unused `_AuthUserChanged` subscription are removed. ✅ No cached-user fallback in `getCurrentUser()`. ✅ Navigation always uses `go`, so back from Home exits the app. ⏳ Verify the cold-start paths on a device.

_Original plan:_
- `AuthRepositoryImpl.getCurrentUser()` falls back to the **cached** user when Firebase says no one is signed in, so the app can show "authenticated" with no Firebase session. Drop that fallback.
- `SplashRedirectPage` uses `context.push('/home')` / `push('/login')`, which stacks routes so back navigation returns to the splash screen. Use `context.go`.
- There are two sources of truth: the go_router `redirect` (which queries Firestore on **every** navigation via `_hasCompletedProfile`) and `StartupPage` / `OnboardingProfileBloc` / `AuthBloc`. Consolidate into one: an auth plus profile-completed notifier (`refreshListenable`), cached in memory.
- `AuthBloc._authSubscription` / `_AuthUserChanged` are declared but never subscribed.
- **Done when:** cold start → correct screen in a single redirect, there are no Firestore reads per navigation, and back from Home exits the app.

### ✅ 8. Fix the streak (it never increments)
> **Done (2026-11-10):** A pure `StreakCalculator` compares **local calendar days**, using UTC date arithmetic so DST shifts don't skew it. Updates run in a Firestore **transaction** that creates the doc if it's missing. `UpdateStreakEvent` is dispatched when a **workout is saved** or a **meal is marked eaten**. A broken streak (more than one day since the last activity) displays as 0. 14 tests cover same day, next day, gaps of 2+ days, late night to early morning, month and year rollover, DST, and a missing doc.

_Original plan:_
- `UpdateStreakEvent` is **never dispatched**, so the streak is stuck. Dispatch it on a meaningful action (a workout saved, meals completed, or app open, whichever you decide).
- `StreakRemoteDatasource.updateStreak()` compares raw timestamps with `.inDays`. For example, 11 PM → 8 AM the next day gives `0` days, so it counts as the "same day". Compare **local calendar dates** (`DateTime(y,m,d)`) instead.
- `.update()` throws if `users/{uid}` doesn't exist. Use `set(..., SetOptions(merge: true))`.
- Make it a Firestore transaction to avoid races.
- **Done when:** unit tests cover same day, next day, gap of 2+ days, and late-night to early-morning.

### ◐ 9. Wire up notifications (currently dead code)
> **Progress (2026-11-10):** ✅ `NotificationService.initialize()` is called in `main()`. It sets up the time zone, initializes the plugin with Android and Darwin settings, creates the channel, and handles foreground FCM by showing the notification and saving it to the list. ✅ A `firebaseMessagingBackgroundHandler` writes background messages to a pending box, which is drained into the list on startup and when a notification is tapped. ✅ Notification ids are capped to 32 bits. ✅ A new `ReminderScheduler` replaces `notification_schedular_service.dart`, using **inexact** daily alarms: workout at the user's chosen time, water, meals, and a streak reminder at 8 PM that's skipped once there's activity that day. ✅ Settings persist in Hive through `NotificationSettingsCubit` and reschedule on every change. `ReminderSync` applies them on sign-in and cancels them on logout. Permission is requested after sign-in, not on first launch. ✅ The settings page moved to `notifications/.../notification_settings_page.dart` as `NotificationSettingsPage`. ✅ The notification list page crashed (provider read in `initState`); that's fixed. ✅ Manifest: dropped `SCHEDULE_EXACT_ALARM`; added `RECEIVE_BOOT_COMPLETED`, the scheduled-notification receivers, and the FCM default channel. ⏳ Verify on a device: reminders fire, and a test FCM message from the Console appears in the list. iOS push also needs an APNs key and the Push capability (task 13).

_Original plan:_
- `NotificationService.instance.initialize()` is **never called**, so FCM, local notifications, and the in-app notification list never work.
- `NotificationSchedulerService` (`core/services/notification_schedular_service.dart`) isn't referenced anywhere.
- The notification settings toggles (`profile/presentation/pages/notification_page.dart`) are `setState` only. They don't persist and don't schedule anything.
- The notification `id: DateTime.now().millisecondsSinceEpoch` exceeds 32-bit int, which **crashes on Android**. Use `% 0x7fffffff` or a counter.
- There's no `FirebaseMessaging.onBackgroundMessage` handler, no iOS `DarwinInitializationSettings`, and `tz.initializeTimeZones()` / `flutter_timezone` need to be set up before `zonedSchedule`.
- Remove the duplicate `NotificationPage`s (`features/notifications/...` vs `features/profile/.../notification_page.dart`): rename the settings one to `notification_settings_page.dart`.
- **Done when:** toggles persist, reminders fire at the scheduled time, and FCM messages appear in the list.

### ✅ 10. Re-enable AI Insights properly
> **Done (2026-11-10):** `AIInsightsSection` is back on Home, fed by real data: steps and calories from `HealthBloc`, the streak from `StreakBloc`, and BMI from the profile. It loads once those are ready. `AIInsightsLocalDatasource` (Hive) caches insights **per user per day**; the box is cleared on logout and deletion, and Retry forces a refresh. There are loading, error-with-retry and offline states. Structured JSON capped at 4 came with task 2. The "duplicate" card was really a section widget; it moved to `ai_insights/presentation/widgets/ai_insights_section.dart`. 5 tests.

_Original plan:_
- `LoadAIInsightsEvent` is commented out in `home_page.dart`, and when it was enabled it used hardcoded fake data (`steps: 12450, streak: 18`).
- Feed real values from `HealthBloc`, `StreakBloc`, and profile BMI.
- Cache insights per day. `ai_insights_local_datasource.dart` is an empty 1-line file, so implement it (Hive) to avoid calling the API on every home load.
- Parsing is fragile: `data['candidates'][0]...` with no null checks, and it returns however many lines the model sends. Use structured JSON output (`responseMimeType: application/json`) and cap at 4.
- Check that the `gemini-2.0-flash` / `v1` endpoint is still available and move to a current model if needed. This is done server-side, via task 2.
- There are two `ai_insight_card.dart` widgets (`ai_insights/...` and `home/...`). Keep one.
- **Done when:** Home shows real, cached, once-a-day insights with loading, error, and offline states.

### ✅ 11. Fix the body-part workout filter
> **Done (2026-11-10):** Server-side `bodyParts` filtering, cursor pagination and infinite scroll came with task 2. Fixed the selector mapping: forearms → `lower arms`, calves → `lower legs`. Every mapped value was checked against the live API and returns results. The RapidAPI quota no longer applies, so instead of Hive there's an in-memory page cache (1-hour TTL) in `WorkoutRepositoryImpl`.

_Original plan:_
- `getExercises()` fetches only 20 exercises and then filters by body part **client-side**, so most body parts show an empty list.
- Use ExerciseDB's `/exercises/bodyPart/{bodyPart}` endpoint with pagination (`limit`/`offset`), and add infinite scroll in `WorkoutListPage`.
- Cache the exercise list (Hive) because RapidAPI quota is limited.
- **Done when:** every selectable body part returns results and scrolling loads more.

### ✅ 12. Remove crash-prone `currentUser!`
> **Done (2026-11-10):** `core/error/UnauthenticatedException`. The diet, food item and workout data sources use a `_uid` getter. Streams build their query lazily (`_userStream`), so a missing user becomes a **stream error** instead of a synchronous throw, and the `doc(null)` random-path bug is gone. Blocs no longer call `emit` from `listen(onError:)`, which bloc rejects with an assertion; they dispatch `*StreamFailed` events instead. Subscriptions are cancelled when the uid-keyed blocs close on logout (task 6).

_Original plan:_
- `diet_remote_datasource.dart` (lines 66, 75, 140) and `workout_remote_datasource.dart` (lines 58, 72) force-unwrap `auth.currentUser!`. These throw if a stream is still listening after logout.
- Use a shared `_uid` getter that throws a typed `UnauthenticatedException`, and cancel Firestore stream subscriptions on logout.
- **Done when:** a logout while on the Diet or Workout screens doesn't crash.

### ◐ 13. Make iOS work (or explicitly drop it)
> **Progress (2026-11-10):** ✅ `DefaultFirebaseOptions.ios` was added from the existing `GoogleService-Info.plist`, so the app no longer throws on startup. ✅ Info.plist: `CFBundleURLTypes` (REVERSED_CLIENT_ID), `GIDClientID`, `NSCameraUsageDescription`, `NSPhotoLibraryAddUsageDescription`, `UIBackgroundModes: remote-notification`, and display name **BeFit**. ✅ iOS deployment target set to 15.0 (Podfile and pbxproj), as Firebase requires. ✅ Android label is now **BeFit**. ⏳ **You:** the bundle ID is still `com.example.fitnessApp`, because that's the only iOS app registered in Firebase. To change it, pick an ID (e.g. `com.befitfitness.app`), set it in Xcode, then run `flutterfire configure --platforms=ios`. That registers a new iOS app and regenerates the plist and `firebase_options.dart`; then update the URL scheme and `GIDClientID`. ⏳ **You:** add the Push Notifications capability and upload an APNs key to Firebase. ⏳ Not built or run yet: CocoaPods isn't installed on this machine. Run `pod install` and test on a real iPhone.

_Original plan:_
- `DefaultFirebaseOptions.currentPlatform` only has `android`, so the iOS app **throws on startup**. Run `flutterfire configure` for iOS.
- Change the bundle ID from `com.example.fitnessApp` to e.g. `com.befit.fitness`.
- Add `NSCameraUsageDescription` to `Info.plist` (the barcode scanner crashes without it), plus Google Sign-In `CFBundleURLTypes` (`REVERSED_CLIENT_ID`).
- Set the display name to "BeFit" on both platforms (Android `android:label="fitness_app"`, iOS "Fitness App").
- **Done when:** the app launches, signs in, and scans on a real iPhone.

### ✅ 14. Open Food Facts integration
> **Done (2026-11-10):** Uses `/api/v2/product/{barcode}?fields=…` with the descriptive `AppConfig.userAgent` (contact is the repo URL) and a 12-second timeout; the UA and timeout are also applied to ExerciseDB. A typed `FoodLookupException` (offline, timeout, server) maps to clear messages. 404 and `status: 0` mean "not found, add it manually". Product names fall back from `product_name` to `product_name_en` to `generic_name`, and energy given only in kJ is converted to kcal. Checked against the live API. 6 tests.

_Original plan:_
- It uses the legacy `/api/v0/product/{barcode}.json`. Move to `/api/v2/product/{barcode}?fields=...` to cut payload size.
- OFF asks apps to send a descriptive `User-Agent` (`BeFit/1.0 (contact)`). Add one.
- Handle no network or timeouts (no `timeout` is set on `http` calls anywhere).
- **Done when:** the scanner works with v2 and shows clean not-found and offline states.

---

## P2: Architecture & code quality

### ✅ 15. Introduce error handling with `Failure` / `Either`
> **Progress (2026-11-10):** ✅ `core/error/failures.dart`: a sealed `Failure` (`Network`, `Timeout`, `Server`, `NotFound`, `Auth`, `Unknown`) with `Failure.fromException()`, which also maps Firebase codes to friendly messages. ✅ `core/error/result.dart`: a sealed `Result<T>` (`Ok`/`Err`) with `guard()` and `fold()`. I used this instead of adding fpdart. ✅ `core/network/api_client.dart`: `ApiClient` with timeout, User-Agent and typed exceptions, injected through get_it. Workouts and Food Scanner use it end to end, with `Result`-returning repos and use cases and blocs that fold. ✅ No bloc shows `e.toString()` any more. Firestore-backed repos still throw, and their blocs map errors with `Failure.fromException`.

_Original plan:_
- Repos throw raw `Exception(response.body)` and blocs put `e.toString()` straight into the UI.
- Add `core/error/failures.dart` and `exceptions.dart`, and have repos return `Either<Failure, T>` (`fpdart`) or a sealed `Result<T>`. Map failures to user-friendly messages.
- Add a shared `ApiClient` wrapper around `http` with timeouts, User-Agent, and error mapping. Inject it through get_it instead of using top-level `http.get`.

### ◐ 16. Fix the layering leaks
> **Progress (2026-11-10):** ✅ The router uses `SessionNotifier` (task 7). `HomeBloc` uses the `GetCurrentUser` use case. ✅ `HealthRepositoryImpl` takes the `GetUserProfile` use case. ✅ `NotificationService` gets `saveNotification` injected. ✅ `FoodItemsRepositoryImpl.getFoodItems()` emits the cache, then the live stream, and lets errors reach the bloc. ✅ The onboarding bloc no longer touches FirebaseAuth. ✅ **Bug fixed:** editing the profile used to overwrite `users/{uid}` and wipe `profileCompleted`, `lastActiveDate` and streak. It now merges, and a test covers it. ⏳ Deferred: merging the onboarding and profile repos into one `UserProfile` repo.

_Original plan:_
- `AppRouter` and `HomeBloc` call `FirebaseAuth.instance` / `FirebaseFirestore.instance` directly. Go through use cases instead.
- `HealthRepositoryImpl` depends on `OnboardingRepository`, a cross-feature repo. Inject a `GetUserProfile` use case or a shared profile source.
- The profile data lives in two features (onboarding and profile) that both read `users/{uid}`. Merge them into one `UserProfile` repository.
- `NotificationService` pulls dependencies from the `sl` service locator internally. Inject them instead.
- `FoodItemsRepositoryImpl.getFoodItems()`: one stream error stops the stream permanently and falls back to cache. Use `handleError` and keep listening, or rely on Firestore's built-in offline persistence and drop the manual Hive cache.

### ✅ 17. Scope blocs correctly
> **Progress (2026-11-10):** ✅ Only `AuthBloc` is app-global. Blocs shared across routes live in `UserScope`, which is lazy and keyed by uid (task 6), so nothing loads before sign-in. ✅ Page-local blocs moved down: `FoodScannerBloc` is provided at the `/barcode-scanner` route, `BodySelectionBloc` inside `BodyChartWidget`, and `HealthMetricsBloc` per `HealthMetricCard`. I kept `AIInsightsBloc` in `UserScope` so Home doesn't regenerate insights on rebuild. I didn't use a `ShellRoute`, because `UserScope` already covers authenticated pages.

_Original plan:_
- Only truly global blocs (Auth, maybe Profile) belong in `main.dart`. Feature blocs (Workout, Diet, FoodItems, FoodScanner, BodySelection, HealthCalculator) should be provided at their route, or under a `ShellRoute` for authenticated pages.
- That stops 5 network calls from firing at app launch before the user is known.

### ✅ 18. Split `injection_container.dart` (450 lines)
> **Progress (2026-11-10):** ✅ `injection_container.dart` is down to ~40 lines. `core/di/storage_module.dart` opens the Hive boxes, has box-name constants and `userScoped`. `core/di/core_module.dart` has Firebase, `ApiClient` and `SessionNotifier`. Each feature has its own `<feature>_injection.dart`. ✅ A DI smoke test resolves every bloc. I didn't adopt `injectable`, because manual registration is small enough now.

_Original plan:_
- Create a per-feature `register<Feature>Dependencies()` in each feature folder and call them from `init()`.
- Consider `injectable` for codegen.
- Move Hive box opening into a `StorageModule`.

### ✅ 19. Clean the analyzer to 0 issues
> **Progress (2026-11-10):** ✅ `flutter analyze` reports **0 issues**, with stricter lints enabled: `always_declare_return_types`, `avoid_dynamic_calls`, `cancel_subscriptions`, `prefer_const_*`, `prefer_final_locals`, `unawaited_futures`. ✅ Converted `withValues`, removed every `print`, switched to `SharePlus.instance.share`, added `context.mounted` guards, and renamed all the misspelled files and folders. ✅ `core/utils/json_read.dart` gives safe JSON number and map reads for `avoid_dynamic_calls`.

_Original plan:_
- Replace `withOpacity(x)` → `withValues(alpha: x)` (204 hits; a mechanical sed is safe).
- Replace `print` → `dart:developer` `log` or a `logger` package (37 calls, some log user objects). Strip them in release builds.
- `Share.shareXFiles` → `SharePlus.instance.share(ShareParams(...))`; `Switch.activeColor` → `activeThumbColor`.
- Fix the 3 `use_build_context_synchronously` cases with `if (!context.mounted) return;`.
- Rename `core/widgets/showHistoryDetailBottomSheet.dart` → `show_history_detail_bottom_sheet.dart`.
- Fix typos in paths: `entites/` → `entities/`, `notifation_repository.dart`, `health_calculator_reposittory.dart`, `notification_schedular_service.dart`, `diet_planing_page.dart`, and `domain/repository/` (streak) vs `repositories/`.
- Then enable stricter lints (`very_good_analysis`, or add `prefer_const_constructors`, `always_declare_return_types`, `unawaited_futures`).

### ✅ 20. Delete dead code
> **Progress (2026-11-10):** ✅ Deleted `macros_chart_card`, `guest_signin_button`, `diet_local_datasource` and `diet_detail_bottom_sheet`. `food_entry_card` turned out to be in use (via `food_entry_list`), so I kept it. `ai_insights_local_datasource` is now implemented (task 10). ✅ Moved `hive_generator` and `build_runner` to `dev_dependencies`. ✅ Removed about 175 lines of commented-out meal-alarm code from the diet detail sheet.

_Original plan:_
Unreferenced files:
- `features/home/presentation/widgets/macros_chart_card.dart`
- `features/auth/presentation/widgets/guest_signin_button.dart`
- `features/diet/data/datasources/local/diet_local_datasource.dart`
- `features/diet/presentation/widgets/diet_detail_bottom_sheet.dart`
- `features/diet/presentation/widgets/food_entry_card.dart`
- `features/ai_insights/data/datasources/local/ai_insights_local_datasource.dart` (empty; implement it in task 10 or delete it)

Also move `hive_generator` and `build_runner` from `dependencies` to `dev_dependencies` in `pubspec.yaml`.

### ◐ 21. Centralize theme & design tokens
> **Progress (2026-11-10):** ✅ Added `core/theme/app_colors.dart` (brand, surface and text tokens), `app_text_styles.dart` and `app_theme.dart` (a dark M3 `ThemeData`), wired into `MaterialApp.router`. ✅ Migrated about 190 hex literals in 43 files to `AppColors.*`, covering every colour used more than once. ⏳ About 28 one-off hex values and the `Colors.white70`-style usages remain. Move them screen by screen as you touch them. ⚠️ The app now has a dark default theme where it used to be light, so unstyled dialogs, sheets and text are now dark-on-white → white-on-dark. Check this on a device.

_Original plan:_
- There's no `ThemeData`, and there are **739** hardcoded `Colors.*` / `Color(0x…)` usages.
- Create `core/theme/app_colors.dart`, `app_text_styles.dart`, and `app_theme.dart` (dark theme), then pass `theme:` to `MaterialApp.router`.
- Migrate screen by screen, starting with the biggest: `profile_screen.dart` (782 lines), `overall_health_card.dart` (691), `diet_detail_page.dart` (624).

### ◐ 22. Break up the large widgets
> **Progress (2026-11-10):** ✅ `profile_screen` went from 787 to 83 lines (`ProfileHeader`, `ProfileStatsGrid`/`ProfileStatCard`, `ProfileShareSection`, `ProfileSettingsSection`/`SettingsTile`). ✅ `overall_health_card` went from 693 to 251, split into `concentric_arcs_painter`, `calculator_readings_widget` and `fitness_reading_item`. ✅ `diet_detail_page` went from 630 to 258 (`MealCard`). ✅ `home_page` went from 470 to 334 (`GoalProgressBar`, `health_metrics/…/HealthMetricCard`). ✅ `manual_food_entry_page`, `health_calculator_page` and `edit_profile_screen` are all under 400, with form fields extracted to `food_form_fields`, `calculator_inputs`/`calculator_result_card` and `profile_text_field`. ⏳ `health_metrics_chart` (440) and `body_part_selection` (415) are already split into focused private methods. They're left for later.

_Original plan:_
Files over 400 lines: `profile_screen`, `overall_health_card`, `diet_detail_page`, `manual_food_entry_page`, `home_page`, `health_calculator_page`, `edit_profile_screen`, `health_metrics_chart`. Extract private widgets into `widgets/` and keep each page under ~250 lines.

### ✅ 23. Typed routing
> **Progress (2026-11-10):** ✅ `core/routes/routes.dart` holds all paths as a `Routes` constants class, and every `push`/`go`/`path:` uses it. ✅ No hard `state.extra as T` casts remain: `_extra<T>()` is null-safe, `/edit-profile` without a `ProfileEntity` redirects to `/profile`, and the calculator type is a query param (`Routes.healthCalculator(type)`) that falls back to the list. I didn't adopt `go_router_builder`.

_Original plan:_
- Routes rely on `state.extra as String` / `as ProfileEntity` (non-nullable casts), which crash on deep links or restored state. Use `go_router_builder` typed routes, or path/query params with null-safe fallbacks.
- Move route paths into a `Routes` constants class.

---

## P3: Testing, CI, release polish

### ✅ 24. Unit tests for domain and data
> **Progress (2026-11-10):** ✅ `ActivityEstimator`, all four health-calculator use cases (Mifflin-St Jeor, BMI boundaries, activity clamp), model JSON round-trips including Firestore `Timestamp`s (meal, diet plan, food item, health metric, profile, onboarding), and repository error mapping (`FoodScannerRepositoryImpl` → `Failure` types). The streak logic was already covered in task 8. ✅ Also fixed: profile/onboarding `int` fields now go through `asInt`, so a `2600.0` stored in Firestore no longer crashes parsing. ⚠️ I dropped `hive_generator` and `build_runner`: they pin `analyzer < 7`, which blocks `bloc_test`. `notification_model.g.dart` is checked in. If you need codegen again, move to `hive_ce` + `hive_ce_generator`.

_Original plan:_
- Priority targets: `ActivityEstimator`, streak date logic (after task 8), the health calculator use cases, model `fromJson`/`toJson`, and repository error mapping.
- Use `mocktail` for repos and datasources, and `fake_cloud_firestore` / `firebase_auth_mocks` for remote datasources.

### ✅ 25. Bloc tests
> **Progress (2026-11-10):** ✅ `bloc_test` + `mocktail` suites in `test/blocs/` for AuthBloc (Google, guest, logout; deletion was already covered), StreakBloc, DietBloc (load, stream error, refresh, history saved once on completion), FoodItemsBloc (cache then live, retry after error) and WorkoutBloc (success, failure, search, history error).

_Original plan:_
- Use `bloc_test` for AuthBloc, StreakBloc, DietBloc, FoodItemsBloc, and WorkoutBloc (load, success, error, refresh).

### ✅ 26. Widget & golden tests
> **Progress (2026-11-10):** ✅ Widget tests in `test/widgets/` (helper `pump_app.dart`): Login (options, events, loading, error snackbar) and Home (loading/error/loaded). ✅ The onboarding → home flow test drives the real pages, bloc and `SessionRedirect` with only the Firestore write mocked. I wrote it as a widget test rather than an `integration_test`, because the real flow needs Firebase on a device. ✅ Goldens in `test/goldens/` are tagged `golden` and skipped in CI. Regenerate with `flutter test --update-goldens --tags golden`. ✅ The tests caught real overflows on small screens or large text, now fixed: the login column scrolls, the auth button label shrinks, the button loader is sized to fit, quick-action subtitles ellipsize, and the body-metrics header row no longer overflows.

_Original plan:_
- Cover Login, onboarding steps, and the Home dashboard states (loading, loaded, error). Add an integration test for the onboarding → home flow.

### ✅ 27. CI pipeline
> **Progress (2026-11-10):** ✅ `.github/workflows/ci.yml` has two jobs. Flutter 3.47.7: format check, `analyze --fatal-infos`, `test --coverage` (excluding goldens; lcov uploaded as an artifact), debug APK. Firestore rules: the emulator tests from task 3. ✅ No `secrets.dart` needed (task 2). The Firebase config files are committed and contain only public identifiers. Coverage is 42.9% of lines.

_Original plan:_
- Add `.github/workflows/ci.yml`: `flutter analyze --fatal-infos`, `dart format --set-exit-if-changed`, `flutter test --coverage`, and `flutter build apk --debug`.
- Generate `secrets.dart` from the example in CI, or drop it entirely after task 2.

### ✅ 28. Crash reporting & analytics
> **Progress (2026-11-10):** ✅ Crashlytics catches `FlutterError.onError` and `PlatformDispatcher.onError`, and collection is off in debug builds (`core/observability/observability.dart`). Crash reports and analytics are tagged with the uid only (never email), and the tag is cleared on sign-out. ✅ Analytics sits behind an `AppAnalytics` interface, so blocs don't import Firebase. Events: `login` (google/guest/google_link), `workout_saved`, `meal_completed`, `diet_plan_completed`, `food_scanned` (found). Tests in `test/blocs/analytics_events_test.dart`. ✅ Added the Crashlytics Gradle plugin and bumped google-services to 4.4.2. ⏳ **You:** enable Crashlytics in the Firebase console. On iOS, run `pod install` and add the dSYM upload script.

_Original plan:_
- Add `firebase_crashlytics` (wire `FlutterError.onError` and `PlatformDispatcher.onError`) and `firebase_analytics` for key events (sign-in, workout saved, meal completed, scan).

### ◐ 29. Release hardening
> **Progress (2026-11-10):** ✅ R8 is explicit (`isMinifyEnabled`, `isShrinkResources`), and `proguard-rules.pro` covers flutter_local_notifications/Gson, Crashlytics line numbers and Play Core. ✅ `targetSdk` 36. ✅ `SCHEDULE_EXACT_ALARM` was already gone (task 9). ✅ A native splash (`flutter_native_splash`, #050505 + app icon, Android 12 style) is configured; launcher icons regenerated with `remove_alpha_ios`. ✅ Version 1.1.0+3. ✅ `docs/RELEASE.md` has the build and symbol-upload commands and a Data Safety table. ✅ `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols` runs through R8 and Dart obfuscation. It stops at signing, because `key.properties` points at the new keystore from task 1, which isn't on this machine yet. ⏳ **You:** create the upload keystore (task 1), publish the privacy policy and account-deletion web pages, fill in Data Safety, and test the release build on a device (R8 issues only show up there).

_Original plan:_
- Android: enable R8 (`isMinifyEnabled`, `isShrinkResources`) with keep rules for Firebase and Hive. Bump `targetSdk` to the version Play currently requires. Check whether `SCHEDULE_EXACT_ALARM` is needed (Play restricts it), and use inexact alarms if possible.
- Add a native splash screen (`flutter_native_splash`, since `assets/splash_screen/` exists but is untracked) and run `flutter_launcher_icons` for both platforms.
- Prepare a privacy policy URL, the Data Safety form (health and fitness data, location none, camera), and the account-deletion URL (task 4).
- Bump the version in `pubspec.yaml`. Build the `appbundle` with `--obfuscate --split-debug-info`.

### ✅ 30. Guest account upgrade
> **Progress (2026-11-10):** ✅ A "Save your progress" tile on Profile (guests only) calls `user.linkWithCredential(GoogleAuthProvider)` through `LinkGuestWithGoogle`. The uid doesn't change, so all Firestore data and the user scope stay intact. Name, email and photo are merged onto `users/{uid}`. ✅ Typed `AccountLinkException`: a Google account that already has a BeFit account gets a clear message and the user stays signed in as the guest; a cancelled picker is silent. ✅ The guest logout dialog now warns that their data will be unreachable. ✅ Tests: repository (data kept, fields merged, error mapping), bloc and widget. ⏳ Verify on a device with a fresh guest account.

_Original plan:_
- Anonymous guests lose all data if they uninstall or sign out. Offer "Save your progress" with `linkWithCredential(GoogleAuthProvider)` to convert a guest into a Google account.

---

## P4: Feature ideas (after the above)

- [x] **Health Connect / HealthKit** (the `health` package) instead of only the raw pedometer, to get accurate steps, calories, sleep, and heart rate.
  > **Done (2026-11-10):** `core/health/HealthPlatformService` (plugin-backed `HealthPluginService`, registered in `core_module`) offers read-only access to steps, active calories, heart rate, sleep and weight. `HealthRepositoryImpl` uses platform steps and active calories when connected, and falls back to the pedometer + `ActivityEstimator` when not connected, when the store has no steps, or when a read fails. `HealthMetricRepositoryImpl` merges 30 days of platform readings into the charts. A manual entry wins on the same day, and platform readings are never persisted. Daily aggregation is pure and tested: HR daily mean, last weight of the day, and sleep credited to the wake day with overlaps merged. Home has a "Connect Health Connect / Apple Health" card (Install when Health Connect is missing) and refreshes on app resume. Android: `FlutterFragmentActivity`, READ_* permissions, and `HealthPrivacyPolicyActivity` + `ViewPermissionUsageActivity` alias open the policy URL. iOS: `Runner.entitlements` (HealthKit) and `NSHealthShareUsageDescription`. 28 tests. ⏳ Real privacy URL in `strings.xml`. ⏳ iOS bundle ID is still `com.example.fitnessApp`, which can't get the HealthKit capability. ⏳ Verify on devices (Android 14+, Android 13 with the HC app, iPhone).
- [x] **Water intake tracker** with reminders (ties into task 9).
  > **Done (2026-11-10):** New `features/water_intake` (Clean Architecture + `WaterIntakeBloc` in `UserScope`). One Firestore doc per day at `users/{uid}/waterIntake/{yyyy-MM-dd}` (`date`, `goalMl`, `entries[{id, ml, at}]`). Writes use `arrayUnion`/`arrayRemove` with merge, never transactions, so logging works offline. The goal defaults to weight × 35 ml (rounded to 50 ml, 500–6000), is editable, and is stored as `users/{uid}.dailyWaterGoalMl`; each day keeps the goal it was logged against. UI: a Home card (+250/+500), a `/water` page (progress ring, quick-add 150/250/500/750 + custom, today's log with swipe-to-remove, a 7-day bar chart, goal sheet, link to reminder settings). Reminders: the existing 10 AM–6 PM water reminders are skipped for the rest of the day once the goal is met (`ReminderScheduler.skipWaterRemindersToday`) and restored if an undo drops below it. The day rolls over on app resume. `waterIntake` was added to account deletion's subcollection list, plus the `water_logged` analytics event. 28 tests. ⏳ Verify on a device: offline logging syncs, reminders pause after the goal.
- [x] **Workout session mode**: sets, reps, rest timer, and the saved session feeding the streak.
  > **Done (2026-11-10):** `WorkoutSessionCubit` (in `UserScope`) runs a session of exercises with sets (reps, optional kg, done). Sets are prefilled from the last time each exercise was logged, or 3 × 10, with a "Last time: …" hint. Ticking a set starts a rest timer (90 s default, ±15 s, Skip; buzz + alert sound when it ends). Timers are stored as timestamps, and the draft lives in the user-scoped `workout_session_box` (Hive), so a killed app resumes the session. Finish saves completed sets to `workoutHistory` with `exerciseLogs`, `durationSeconds` and a generated title, then fires `UpdateStreakEvent`; older entries still parse. Offline, a save still pending after 5 s counts as queued. UI: add buttons on exercise cards, "Add to workout & start" in the detail sheet (the old one-tap button is now "Log as done"), a "Workout in progress" bar on the exercise list and Home, `/workout-session` (stats strip, set table, rest panel, discard, summary dialog), and richer workout history details (sets, duration, volume). 26 tests. ⏳ Not yet: a rest-over notification while the app is in the background.
- [x] **Weekly progress report** charts (weight trend, macros adherence) on Home.
  > **Done (2026-11-10):** New `features/progress_report` (Clean Architecture + `WeeklyReportBloc`). Calendar weeks run Monday to Sunday. `ReportCalculator` (pure, tested) builds an 8-week weight trend from weekly averages (manual + Health Connect/HealthKit), the change vs last week, per-day macros, and adherence (mean over protein/carbs/fat of `1 − |eaten − goal| / goal`, averaged over logged days). Per-day intake comes from the new nutrition log `users/{uid}/nutritionLog/{yyyy-MM-dd}`, which `DietBloc` writes on every meal tick or untick. Older days fall back to completed plans in `dietHistory`. It also shows workouts (sets, minutes) and the days the water goal was met. Every source is best-effort, so one failing read doesn't blank the report. UI: a "Weekly progress" Home card (4 tiles + both charts, refreshes on pull and resume) and `/weekly-report` (week switcher up to 12 weeks back, charts, daily macro table). `nutritionLog` was added to account deletion. 30 tests. ⏳ The nutrition log only fills from now on. Goals come from the current profile, not per-day snapshots.
- [x] **On-device AI coach** with Gemma via MediaPipe / TFLite (like ExpenseFlow), so insights work offline and need no API key.
  > **Done (2026-11-10):** `core/ai/OnDeviceLlm` (`GemmaOnDeviceLlm`, `flutter_edge_ai` 2.6, formerly `flutter_gemma`, + `flutter_edge_ai_mediapipe`) runs Gemma 3 1B `.task` on the device. GPU on Android with a CPU fallback, CPU on iOS (a `.task` model on the iOS GPU exceeds the memory limit). Calls are serialised, the model is device-level (survives logout), and phones under 3.5 GB RAM count as unsupported. MediaPipe rather than LiteRT-LM because LiteRT-LM needs minSdk 30 and BeFit supports Android 10. The model URL comes from `--dart-define=GEMMA_MODEL_URL` (an https URL whose last path segment is a plain `.task` file name). Without it, on-device AI is off and everything uses Gemini. **Home insights:** on-device first when the model is ready (prompted JSON, parsed leniently), Gemini as the fallback, same daily cache. **Coach** (`features/ai_coach`, `/coach`, "Ask coach" on Home): a streaming chat grounded in profile, today's activity, water, streak and the weekly report. It replays the last 4 turns, has a stop button, and labels each answer On-device or Cloud. Rule-based safety replies cover emergencies (112, Tele-MANAS 14416) and topics that need a professional. `OnDeviceModelCubit` (app-level) handles download (with progress and cancel), retry and removal. Platform: iOS deployment target 16.0 + `use_frameworks! :linkage => :static`, OpenCL `uses-native-library` on Android. 50 tests. ⏳ Upload `gemma3-1b-it-int4.task` (litert-community/Gemma3-1B-IT, after accepting the Gemma license) to the root of a Storage bucket or other HTTPS host, and pass its URL with `--dart-define=GEMMA_MODEL_URL=…` (CI too). ⏳ Verify on devices: download, offline answers, speed on a mid-range phone, and an iPhone on CPU. ⏳ Chat history is in memory only (cleared on restart).
- [x] **Localization** (`flutter_localizations` + ARB), starting with English and Hindi/Marathi.
  > **Done (2026-11-10):** gen-l10n (`l10n.yaml`, `lib/l10n/app_{en,hi,mr}.arb`, 508 keys) covers every screen, bloc/failure message, reminder notification and AI prompt. It follows the phone language by default, and Profile → Language overrides it per device (`LocaleCubit`, Hive `app_settings_box`). Changing the language reschedules reminders so their text switches too. Widgets use `context.l10n`. Code without a context (blocs, `Failure.message`, `ReminderScheduler`, calculator use cases) uses `AppLocale.l10n`. Dates follow the language through `Intl.defaultLocale`; Marathi keeps Latin digits. Values stored in English (goal, gender, activity, meal names, food units, calculator types) stay English in Firestore and in calculations, and are mapped for display (`core/l10n/profile_labels.dart`, `calculator_labels.dart`). The coach and Home insights reply in the chosen language (on-device and Gemini). Insights are cached per language. Safety replies are localized, and the emergency check also matches common Hindi/Marathi phrases. Unit symbols (kg, g, kcal, ml, cm) stay Latin. Exercise names and instructions from ExerciseDB stay English (API content). Tests: ARB key/placeholder parity, `LocaleCubit`/`AppLocale`, AI language and cache, and Home in hi/mr without overflow (318 tests total). ⏳ Native-speaker review of the hi/mr strings (machine-quality wording in places). ⏳ Gemma 3 1B's Hindi/Marathi answers are weak; check them on device, and consider using cloud for those languages if they're poor. ⏳ Calculator results already saved keep the language they were calculated in.
- [x] **Accessibility pass**: semantics labels, text scaling (ScreenUtil plus `textScaler`), and contrast on the dark theme.
  > **Done (2026-11-10):** **Text scaling:** `AppTextScaling` follows the phone's font size up to 1.6× (applied in `main.dart` and the test harness). Fixed: the water ring (grows with text, contents scale down to fit), the water card header and the body-chart title, which had overflowed. **Contrast:** the cyan app bar had white text and icons at 1.5:1. They're now `AppColors.onPrimary` (near-black, 14:1). Placeholder, date and footer text at white 24–40% was raised to `textMuted` (≈6:1). `contrast_test.dart` pins every text colour on every surface to WCAG AA (4.5:1). **Semantics and touch targets:** every `IconButton` has a tooltip. Icon-only `GestureDetector`s became `IconButton`s or got button semantics and labels: profile avatar, scanner back/flashlight, food delete, metric add, search clear. A new `InfoButton` gives the "i" buttons a 48 dp target and a "Learn more" label. Chips and toggles report selected state (gender, W/M, muscles; muscles also have a long-press "exclude" hint). The body SVG is hidden from screen readers in favour of the equivalent muscle list. The overall-health ring reads as one sentence, as does the water ring. Text fields and the Explore / quantity / Ask coach buttons are at least 48 dp. `AppHeader` now honours `leading`. **Tests:** `test/widgets/a11y.dart` runs Flutter's tap-target (Android 48, iOS 44), labelled-tap-target and text-contrast guidelines plus a no-overflow check at 1.6×, on Home, Login, Coach, the workout session, Water, the weekly report and the full onboarding flow. ⏳ Manual TalkBack/VoiceOver run on a device (reading order, focus after dialogs and sheets). ⏳ Screens without widget tests (diet, profile, calculators, scanner, notifications) were fixed by inspection only. ⏳ Reduce-motion (`MediaQuery.disableAnimations`) for the Lottie and ring animations.

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
