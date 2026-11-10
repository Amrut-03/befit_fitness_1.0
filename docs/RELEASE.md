# Release checklist

## 1. Before building

- [ ] Bump `version:` in `pubspec.yaml` (name for users, `+N` build number must increase).
- [ ] `android/key.properties` points at the **new** upload keystore (TASKS.md task 1).
- [ ] CI is green on the release commit.

## 2. Build

```bash
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols
```

- R8 (shrink + obfuscate) is on for release builds; keep rules live in
  `android/app/proguard-rules.pro`. The Crashlytics Gradle plugin uploads the
  R8 mapping file during the build.
- Dart is obfuscated separately. Upload its symbols so Crashlytics can
  de-obfuscate Dart stack traces, and keep `build/symbols/` for this version:

```bash
firebase crashlytics:symbols:upload \
  --app=1:475383477382:android:0e3c563b237c312fc44d07 \
  build/symbols
```

- Smoke-test the release build on a device before uploading
  (`flutter install --release` with an APK build): sign-in, scanner, a
  scheduled reminder after reboot, share/save progress card. R8 problems
  only show up in release builds.

## 3. Play Console

**Target API:** `targetSdk = 36` (required for updates since 31 Aug 2026).
Android 16 enforces edge-to-edge, so check that no content sits under the
status or navigation bar.

**Privacy policy URL** (required, since the app handles health data). It
must cover: what's collected (below), why, Firebase/Google as processors,
retention, and how to delete the account.

**Account deletion URL** (Data safety → Data deletion): a web page that
explains the in-app path (Profile → Delete Account) and gives a contact
address for users who no longer have the app.

**Data safety form.** Everything is encrypted in transit, nothing is sold,
and users can request deletion.

| Data type | Collected | Purpose | Notes |
|---|---|---|---|
| Name, email address | Yes | Account management | From Google Sign-In; not for guests |
| User IDs | Yes | Account management, analytics | Firebase uid |
| Health info (weight, height, age, gender, goals) | Yes | App functionality, personalization | Onboarding/profile |
| Fitness info (steps, workouts, meals, heart rate, sleep) | Yes | App functionality, personalization | Steps, active calories, heart rate, sleep and weight read from Health Connect (read-only) or the pedometer; manual metric entries |
| App interactions | Yes | Analytics | Firebase Analytics events (login, workout saved, meal completed, scan) |
| Crash logs, diagnostics | Yes | App functionality | Crashlytics; release builds only |
| Device or other IDs | Yes | Analytics, notifications | Analytics app-instance ID, FCM token |
| Photos/videos | No | | The camera scans barcodes on-device; the progress card is saved locally, never uploaded |
| Location | No | | |

**Data sharing:** health and fitness data is sent to Firebase AI Logic
(Gemini) to generate daily insights. Google acts as a service provider
(processing on your behalf), which Play does not count as "sharing", but
the privacy policy must disclose it.

**Health apps declaration:** declare the fitness-tracking features in the
Health apps section of App content.

**Health Connect declaration** (App content → Health Connect permissions).
BeFit requests read-only access to Steps, Active calories burned, Heart
rate, Sleep and Weight. For each one, explain the user-facing feature: Home
activity rings and goals (steps, calories), and the 7/30-day charts (heart
rate, sleep, weight). Points to cover:

- The privacy policy URL in `android/app/src/main/res/values/strings.xml`
  (`health_privacy_policy_url`) must be the real policy. Health Connect
  links to it from its permission screen.
- Health Connect readings are **not** written to Hive or Firestore. They're
  read live and shown on the device. Today's steps and calories do go into
  the Gemini prompt for daily insights, so the policy has to disclose that
  Health Connect data is processed by Google as a service provider for
  that feature.
- If the declaration asks for a video, record Home → Connect Health
  Connect → grant → rings and charts filling in.

## 4. iOS (once APNs and the bundle ID are set up)

- `cd ios && pod install`, then archive in Xcode.
- **HealthKit:** enable the HealthKit capability on the App ID in the
  Apple Developer portal (the app already ships `Runner/Runner.entitlements`
  and `NSHealthShareUsageDescription`). App Store Connect → App Privacy must
  list Health & Fitness data, and review needs the HealthKit features to be
  visible in the UI (the "Connect Apple Health" card on Home).
- Add the Crashlytics dSYM upload run script (`flutterfire configure` can
  add it), and upload Dart symbols as above with the iOS app ID.
