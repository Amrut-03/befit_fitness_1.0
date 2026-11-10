import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BeFit'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get commonNoInternet;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String unitKg(String value);

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'{value} ml'**
  String unitMl(String value);

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String unitKcal(String value);

  /// No description provided for @unitGrams.
  ///
  /// In en, this message translates to:
  /// **'{value} g'**
  String unitGrams(String value);

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String unitMinutes(String value);

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'{value} cm'**
  String unitCm(String value);

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languageSystem;

  /// Always shown in its own language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Always shown in its own language.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// Always shown in its own language.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get languageMarathi;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get failureNetwork;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'This is taking too long. Please try again.'**
  String get failureTimeout;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'The service is unavailable right now. Please try again.'**
  String get failureServer;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that.'**
  String get failureNotFound;

  /// No description provided for @failureAuth.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get failureAuth;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts or diets to see history'**
  String get historyEmptyBody;

  /// No description provided for @historySummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get historySummary;

  /// No description provided for @historyDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get historyDetails;

  /// No description provided for @educationWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'Why it matters'**
  String get educationWhyItMatters;

  /// No description provided for @educationTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get educationTips;

  /// No description provided for @eduHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Overall Health Score'**
  String get eduHealthTitle;

  /// No description provided for @eduHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'This score combines your daily activity metrics including steps, calories burned, and movement minutes.'**
  String get eduHealthDescription;

  /// No description provided for @eduHealthWhy.
  ///
  /// In en, this message translates to:
  /// **'A higher score means you\'re consistently achieving your daily fitness goals and maintaining an active lifestyle.'**
  String get eduHealthWhy;

  /// No description provided for @eduHealthTip1.
  ///
  /// In en, this message translates to:
  /// **'Walk regularly throughout the day'**
  String get eduHealthTip1;

  /// No description provided for @eduHealthTip2.
  ///
  /// In en, this message translates to:
  /// **'Aim for your daily step target'**
  String get eduHealthTip2;

  /// No description provided for @eduHealthTip3.
  ///
  /// In en, this message translates to:
  /// **'Increase active movement minutes'**
  String get eduHealthTip3;

  /// No description provided for @eduHealthTip4.
  ///
  /// In en, this message translates to:
  /// **'Stay consistent every day'**
  String get eduHealthTip4;

  /// No description provided for @eduHealthTip5.
  ///
  /// In en, this message translates to:
  /// **'Combine cardio and strength training'**
  String get eduHealthTip5;

  /// No description provided for @eduBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive Body Chart'**
  String get eduBodyTitle;

  /// No description provided for @eduBodyDescription.
  ///
  /// In en, this message translates to:
  /// **'The Body Chart helps you visually select muscle groups and discover workouts tailored to those muscles.'**
  String get eduBodyDescription;

  /// No description provided for @eduBodyWhy.
  ///
  /// In en, this message translates to:
  /// **'Targeting specific muscle groups helps you train more effectively, maintain balance in your physique, and avoid neglecting important muscles.'**
  String get eduBodyWhy;

  /// No description provided for @eduBodyTip1.
  ///
  /// In en, this message translates to:
  /// **'Tap a muscle to select it'**
  String get eduBodyTip1;

  /// No description provided for @eduBodyTip2.
  ///
  /// In en, this message translates to:
  /// **'Select multiple muscles to focus on a workout area'**
  String get eduBodyTip2;

  /// No description provided for @eduBodyTip3.
  ///
  /// In en, this message translates to:
  /// **'Use Front and Back views to access all muscle groups'**
  String get eduBodyTip3;

  /// No description provided for @eduBodyTip4.
  ///
  /// In en, this message translates to:
  /// **'Press \'Search Workouts\' to find exercises for selected muscles'**
  String get eduBodyTip4;

  /// No description provided for @eduBodyTip5.
  ///
  /// In en, this message translates to:
  /// **'Long press a muscle to temporarily disable it'**
  String get eduBodyTip5;

  /// No description provided for @eduBodyTip6.
  ///
  /// In en, this message translates to:
  /// **'Train all major muscle groups throughout the week'**
  String get eduBodyTip6;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BeFit'**
  String get loginWelcome;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Track workouts, build healthy habits,\nand transform your fitness journey.'**
  String get loginTagline;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogle;

  /// No description provided for @loginGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get loginGuest;

  /// No description provided for @loginTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our\nTerms & Privacy Policy'**
  String get loginTerms;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleFailed;

  /// No description provided for @authGuestFailed.
  ///
  /// In en, this message translates to:
  /// **'Guest sign in failed'**
  String get authGuestFailed;

  /// No description provided for @authLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get authLogoutFailed;

  /// No description provided for @linkAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'That Google account already has a BeFit account. Choose a different Google account to keep your guest progress.'**
  String get linkAlreadyInUse;

  /// No description provided for @linkNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Your progress is safe; please try again.'**
  String get linkNetwork;

  /// No description provided for @linkNotGuest.
  ///
  /// In en, this message translates to:
  /// **'Your account is already linked to Google.'**
  String get linkNotGuest;

  /// No description provided for @linkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not link your Google account. Please try again.'**
  String get linkFailed;

  /// No description provided for @deleteCancelled.
  ///
  /// In en, this message translates to:
  /// **'Account deletion cancelled.'**
  String get deleteCancelled;

  /// No description provided for @deleteRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, please log out, sign in again, and then delete your account.'**
  String get deleteRecentLogin;

  /// No description provided for @deleteWrongAccount.
  ///
  /// In en, this message translates to:
  /// **'Please choose the Google account you signed in with.'**
  String get deleteWrongAccount;

  /// No description provided for @deleteNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Nothing was deleted. Please try again.'**
  String get deleteNetwork;

  /// No description provided for @deleteNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in.'**
  String get deleteNotSignedIn;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get deleteFailed;

  /// No description provided for @startupProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile.\nCheck your connection.'**
  String get startupProfileFailed;

  /// No description provided for @goalBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get goalBuildMuscle;

  /// No description provided for @goalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get goalLoseWeight;

  /// No description provided for @goalStayFit.
  ///
  /// In en, this message translates to:
  /// **'Stay Fit'**
  String get goalStayFit;

  /// No description provided for @goalImproveStrength.
  ///
  /// In en, this message translates to:
  /// **'Improve Strength'**
  String get goalImproveStrength;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderPreferNot.
  ///
  /// In en, this message translates to:
  /// **'Prefer Not To Say'**
  String get genderPreferNot;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get activityLight;

  /// No description provided for @activityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activityActive;

  /// No description provided for @activityAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get activityAthlete;

  /// No description provided for @onbTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Workouts'**
  String get onbTrackTitle;

  /// No description provided for @onbTrackBody.
  ///
  /// In en, this message translates to:
  /// **'Monitor your daily fitness journey.'**
  String get onbTrackBody;

  /// No description provided for @onbNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Healthy Nutrition'**
  String get onbNutritionTitle;

  /// No description provided for @onbNutritionBody.
  ///
  /// In en, this message translates to:
  /// **'Plan meals and calories smartly.'**
  String get onbNutritionBody;

  /// No description provided for @onbConsistentTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Consistent'**
  String get onbConsistentTitle;

  /// No description provided for @onbConsistentBody.
  ///
  /// In en, this message translates to:
  /// **'Build habits and reach your goals.'**
  String get onbConsistentBody;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onbGetStarted;

  /// No description provided for @onbGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s Your Goal?'**
  String get onbGoalTitle;

  /// No description provided for @onbGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize your fitness experience'**
  String get onbGoalSubtitle;

  /// No description provided for @onbGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get onbGenderTitle;

  /// No description provided for @onbGenderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your experience'**
  String get onbGenderSubtitle;

  /// No description provided for @onbActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get onbActivityTitle;

  /// No description provided for @onbActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your daily activity'**
  String get onbActivitySubtitle;

  /// No description provided for @onbMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Metrics'**
  String get onbMetricsTitle;

  /// No description provided for @onbMetricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us calculate your fitness data'**
  String get onbMetricsSubtitle;

  /// No description provided for @metricWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get metricWeight;

  /// No description provided for @metricHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get metricHeight;

  /// No description provided for @metricAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get metricAge;

  /// No description provided for @unitKgShort.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKgShort;

  /// No description provided for @unitCmShort.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCmShort;

  /// No description provided for @unitYearsShort.
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get unitYearsShort;

  /// No description provided for @onbProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get onbProfileNotFound;

  /// No description provided for @goalFitnessGoal.
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get goalFitnessGoal;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyDietTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet History'**
  String get historyDietTitle;

  /// No description provided for @historyDietSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View completed diet plans'**
  String get historyDietSubtitle;

  /// No description provided for @historyWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get historyWorkoutTitle;

  /// No description provided for @historyWorkoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View completed workouts'**
  String get historyWorkoutSubtitle;

  /// No description provided for @profileFitnessStats.
  ///
  /// In en, this message translates to:
  /// **'Fitness Stats'**
  String get profileFitnessStats;

  /// No description provided for @profileShareProgress.
  ///
  /// In en, this message translates to:
  /// **'Share Progress'**
  String get profileShareProgress;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutGuestWarning.
  ///
  /// In en, this message translates to:
  /// **'You\'re using a guest account. After logging out you can\'t get back to your data. Tap \'Save your progress\' first to keep it.'**
  String get profileLogoutGuestWarning;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get profileEnterName;

  /// No description provided for @profileGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get profileGoal;

  /// No description provided for @profileWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get profileWeightKg;

  /// No description provided for @profileEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get profileEnterWeight;

  /// No description provided for @profileHeightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get profileHeightCm;

  /// No description provided for @profileEnterHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter height'**
  String get profileEnterHeight;

  /// No description provided for @profileEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get profileEnterAge;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid weight'**
  String get profileInvalidWeight;

  /// No description provided for @profileInvalidHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid height'**
  String get profileInvalidHeight;

  /// No description provided for @profileInvalidAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid age'**
  String get profileInvalidAge;

  /// No description provided for @profilePositiveValues.
  ///
  /// In en, this message translates to:
  /// **'Weight and height must be positive values'**
  String get profilePositiveValues;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileSave;

  /// No description provided for @statWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get statWeight;

  /// No description provided for @statHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get statHeight;

  /// No description provided for @statAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get statAge;

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statStreak;

  /// No description provided for @statBmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get statBmi;

  /// No description provided for @statCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get statCalories;

  /// No description provided for @statSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get statSteps;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @shareDayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Day Streak} other{{count} Day Streak}}'**
  String shareDayStreak(int count);

  /// No description provided for @shareConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency creates results'**
  String get shareConsistency;

  /// No description provided for @shareQuote.
  ///
  /// In en, this message translates to:
  /// **'\"Discipline beats motivation.\"'**
  String get shareQuote;

  /// No description provided for @shareGeneratedWith.
  ///
  /// In en, this message translates to:
  /// **'Generated with BeFit'**
  String get shareGeneratedWith;

  /// No description provided for @shareSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery ✅'**
  String get shareSavedToGallery;

  /// No description provided for @shareSaveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get shareSaveToGallery;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Check out my fitness progress on BeFit 🔥'**
  String get shareText;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @accountDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting account…'**
  String get accountDeleting;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountDelete;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all your data: profile, diet plans, food items, workout history, health metrics and streak. This cannot be undone.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleteGoogleConfirm.
  ///
  /// In en, this message translates to:
  /// **'You will be asked to confirm with Google.'**
  String get accountDeleteGoogleConfirm;

  /// No description provided for @progressSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Progress saved to {email}.'**
  String progressSavedTo(String email);

  /// No description provided for @progressYourGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'your Google account'**
  String get progressYourGoogleAccount;

  /// No description provided for @progressLinking.
  ///
  /// In en, this message translates to:
  /// **'Linking…'**
  String get progressLinking;

  /// No description provided for @progressSave.
  ///
  /// In en, this message translates to:
  /// **'Save your progress'**
  String get progressSave;

  /// No description provided for @progressGuestHint.
  ///
  /// In en, this message translates to:
  /// **'You\'re using a guest account. Link Google to keep your data if you sign out or change phones.'**
  String get progressGuestHint;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get homeGoodEvening;

  /// No description provided for @homeTodaysGoals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goals'**
  String get homeTodaysGoals;

  /// No description provided for @homeHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get homeHeartRate;

  /// No description provided for @homeSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get homeSleep;

  /// No description provided for @homeMoveMin.
  ///
  /// In en, this message translates to:
  /// **'Move Min'**
  String get homeMoveMin;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @qaDietPlan.
  ///
  /// In en, this message translates to:
  /// **'Diet Plan'**
  String get qaDietPlan;

  /// No description provided for @qaDietPlanSub.
  ///
  /// In en, this message translates to:
  /// **'Track your macros'**
  String get qaDietPlanSub;

  /// No description provided for @qaWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get qaWorkout;

  /// No description provided for @qaWorkoutSub.
  ///
  /// In en, this message translates to:
  /// **'Training plans'**
  String get qaWorkoutSub;

  /// No description provided for @qaCalculator.
  ///
  /// In en, this message translates to:
  /// **'Health Calculator'**
  String get qaCalculator;

  /// No description provided for @qaCalculatorSub.
  ///
  /// In en, this message translates to:
  /// **'BMI & nutrition'**
  String get qaCalculatorSub;

  /// No description provided for @qaScanFood.
  ///
  /// In en, this message translates to:
  /// **'Scan Food'**
  String get qaScanFood;

  /// No description provided for @qaScanFoodSub.
  ///
  /// In en, this message translates to:
  /// **'Barcode scanner'**
  String get qaScanFoodSub;

  /// No description provided for @qaMyFoods.
  ///
  /// In en, this message translates to:
  /// **'My Foods'**
  String get qaMyFoods;

  /// No description provided for @qaMyFoodsSub.
  ///
  /// In en, this message translates to:
  /// **'Manage items'**
  String get qaMyFoodsSub;

  /// No description provided for @qaHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Diet & workouts'**
  String get qaHistorySub;

  /// No description provided for @dietCardAllDone.
  ///
  /// In en, this message translates to:
  /// **'Meals Completed 🎉'**
  String get dietCardAllDone;

  /// No description provided for @dietCardAllDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Awesome work! You completed all your meals for today.'**
  String get dietCardAllDoneBody;

  /// No description provided for @dietCardGoalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal Achieved'**
  String get dietCardGoalAchieved;

  /// No description provided for @dietCardResets.
  ///
  /// In en, this message translates to:
  /// **'Your tracking will reset tomorrow'**
  String get dietCardResets;

  /// No description provided for @dietCardNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No Active Plan'**
  String get dietCardNoPlan;

  /// No description provided for @dietCardNoPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Start a diet plan to track your progress'**
  String get dietCardNoPlanBody;

  /// No description provided for @dietCardExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Plans'**
  String get dietCardExplore;

  /// No description provided for @dietCardActivePlan.
  ///
  /// In en, this message translates to:
  /// **'Active Plan'**
  String get dietCardActivePlan;

  /// No description provided for @dietCardUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled Plan'**
  String get dietCardUntitled;

  /// No description provided for @dietCardActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get dietCardActiveBadge;

  /// No description provided for @dietCardMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get dietCardMeals;

  /// No description provided for @homeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get homeLoadFailed;

  /// No description provided for @healthConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect {store}'**
  String healthConnectTitle(String store);

  /// No description provided for @healthConnectInstallBody.
  ///
  /// In en, this message translates to:
  /// **'Install or update Health Connect to sync steps, calories, sleep and heart rate.'**
  String get healthConnectInstallBody;

  /// No description provided for @healthConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Sync steps, calories, sleep, heart rate and weight from your watch and other apps.'**
  String get healthConnectBody;

  /// No description provided for @healthInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get healthInstall;

  /// No description provided for @healthConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get healthConnect;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get insightsTitle;

  /// No description provided for @insightsAskCoach.
  ///
  /// In en, this message translates to:
  /// **'Ask coach'**
  String get insightsAskCoach;

  /// No description provided for @insightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No insights today. Try again later.'**
  String get insightsEmpty;

  /// No description provided for @insightsOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Insights will load when you\'re back online, or download the on-device model in AI Coach to get them offline.'**
  String get insightsOffline;

  /// No description provided for @insightsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load AI insights right now.'**
  String get insightsFailed;

  /// No description provided for @macroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// No description provided for @macroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get macroCarbs;

  /// No description provided for @macroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// No description provided for @macroCalShort.
  ///
  /// In en, this message translates to:
  /// **'Cal'**
  String get macroCalShort;

  /// No description provided for @macroCarbShort.
  ///
  /// In en, this message translates to:
  /// **'Carb'**
  String get macroCarbShort;

  /// No description provided for @macroProtShort.
  ///
  /// In en, this message translates to:
  /// **'Prot'**
  String get macroProtShort;

  /// No description provided for @macroSummary.
  ///
  /// In en, this message translates to:
  /// **'{protein}g Protein • {carbs}g Carbs • {fat}g Fat'**
  String macroSummary(int protein, int carbs, int fat);

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @foodUnitPiece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get foodUnitPiece;

  /// No description provided for @foodUnitSlice.
  ///
  /// In en, this message translates to:
  /// **'slice'**
  String get foodUnitSlice;

  /// No description provided for @foodUnitCup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get foodUnitCup;

  /// No description provided for @dietPlanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Planning'**
  String get dietPlanningTitle;

  /// No description provided for @dietNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No diet plans saved yet'**
  String get dietNoPlans;

  /// No description provided for @dietNoPlansHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to plan your diet'**
  String get dietNoPlansHint;

  /// No description provided for @dietPlanYourDiet.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Diet'**
  String get dietPlanYourDiet;

  /// No description provided for @dietDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Diet Plan'**
  String get dietDeleteTitle;

  /// No description provided for @dietDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String dietDeleteConfirm(String name);

  /// No description provided for @dietMealsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}}'**
  String dietMealsCount(int count);

  /// No description provided for @dietMealsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} meals completed'**
  String dietMealsCompleted(int done, int total);

  /// No description provided for @dietInactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get dietInactiveBadge;

  /// No description provided for @dietActivated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get dietActivated;

  /// No description provided for @dietSetActive.
  ///
  /// In en, this message translates to:
  /// **'Set Active'**
  String get dietSetActive;

  /// No description provided for @dietSavePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Diet Plan'**
  String get dietSavePlan;

  /// No description provided for @dietAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get dietAddFood;

  /// No description provided for @dietPendingMeals.
  ///
  /// In en, this message translates to:
  /// **'Pending Meals'**
  String get dietPendingMeals;

  /// No description provided for @dietCompletedMeals.
  ///
  /// In en, this message translates to:
  /// **'Completed Meals'**
  String get dietCompletedMeals;

  /// No description provided for @dietTotalNutrition.
  ///
  /// In en, this message translates to:
  /// **'Total Nutrition'**
  String get dietTotalNutrition;

  /// No description provided for @dietNoFood.
  ///
  /// In en, this message translates to:
  /// **'No food added yet'**
  String get dietNoFood;

  /// No description provided for @dietNoFoodHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Food\" to build your diet plan'**
  String get dietNoFoodHint;

  /// No description provided for @dietEditQuantity.
  ///
  /// In en, this message translates to:
  /// **'Edit Quantity'**
  String get dietEditQuantity;

  /// No description provided for @dietQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get dietQuantity;

  /// No description provided for @dietUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get dietUnit;

  /// No description provided for @dietUpdateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Update Quantity'**
  String get dietUpdateQuantity;

  /// No description provided for @dietConfirmMeal.
  ///
  /// In en, this message translates to:
  /// **'Confirm Meal'**
  String get dietConfirmMeal;

  /// No description provided for @dietConfirmMealBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you consumed {meal}?\n\nThis action cannot be undone today.'**
  String dietConfirmMealBody(String meal);

  /// No description provided for @dietConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dietConfirm;

  /// No description provided for @dietPlanName.
  ///
  /// In en, this message translates to:
  /// **'Diet Plan Name'**
  String get dietPlanName;

  /// No description provided for @dietEnterPlanName.
  ///
  /// In en, this message translates to:
  /// **'Enter diet plan name'**
  String get dietEnterPlanName;

  /// No description provided for @dietDailyMacros.
  ///
  /// In en, this message translates to:
  /// **'Daily Macros'**
  String get dietDailyMacros;

  /// No description provided for @dietSelectFood.
  ///
  /// In en, this message translates to:
  /// **'Select Food items'**
  String get dietSelectFood;

  /// No description provided for @dietSearchFood.
  ///
  /// In en, this message translates to:
  /// **'Search food...'**
  String get dietSearchFood;

  /// No description provided for @dietNoFoodFound.
  ///
  /// In en, this message translates to:
  /// **'No food items found'**
  String get dietNoFoodFound;

  /// No description provided for @dietAddNFood.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 food} other{Add {count} foods}}'**
  String dietAddNFood(int count);

  /// No description provided for @dietLoadPlansFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diet plans'**
  String get dietLoadPlansFailed;

  /// No description provided for @dietLoadHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diet history'**
  String get dietLoadHistoryFailed;

  /// No description provided for @dietSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save plan'**
  String get dietSaveFailed;

  /// No description provided for @dietActivateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update active plan'**
  String get dietActivateFailed;

  /// No description provided for @dietDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete plan'**
  String get dietDeleteFailed;

  /// No description provided for @dietUpdateMealsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update meals'**
  String get dietUpdateMealsFailed;

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutsTitle;

  /// No description provided for @workoutSearch.
  ///
  /// In en, this message translates to:
  /// **'Search workouts...'**
  String get workoutSearch;

  /// No description provided for @workoutNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get workoutNoExercises;

  /// No description provided for @workoutInYourWorkout.
  ///
  /// In en, this message translates to:
  /// **'In your workout'**
  String get workoutInYourWorkout;

  /// No description provided for @workoutAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to workout'**
  String get workoutAddTo;

  /// No description provided for @workoutExercisesSets.
  ///
  /// In en, this message translates to:
  /// **'{exercises, plural, =1{1 exercise} other{{exercises} exercises}} · {sets, plural, =1{1 set} other{{sets} sets}}'**
  String workoutExercisesSets(int exercises, int sets);

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workoutCompleted;

  /// No description provided for @workoutTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get workoutTarget;

  /// No description provided for @workoutDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get workoutDuration;

  /// No description provided for @workoutSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get workoutSets;

  /// No description provided for @workoutVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get workoutVolume;

  /// No description provided for @workoutDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard workout?'**
  String get workoutDiscardTitle;

  /// No description provided for @workoutDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your sets won\'t be saved and this won\'t count toward your streak.'**
  String get workoutDiscardBody;

  /// No description provided for @workoutKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get workoutKeepGoing;

  /// No description provided for @workoutDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get workoutDiscard;

  /// No description provided for @workoutDiscardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Discard workout'**
  String get workoutDiscardTooltip;

  /// No description provided for @workoutNoExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet. Add some to get started.'**
  String get workoutNoExercisesYet;

  /// No description provided for @workoutAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get workoutAddExercise;

  /// No description provided for @workoutFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get workoutFinish;

  /// No description provided for @workoutNoSession.
  ///
  /// In en, this message translates to:
  /// **'No workout in progress'**
  String get workoutNoSession;

  /// No description provided for @workoutNoSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Add exercises from the list to start a session.'**
  String get workoutNoSessionHint;

  /// No description provided for @workoutBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse exercises'**
  String get workoutBrowse;

  /// No description provided for @workoutSaved.
  ///
  /// In en, this message translates to:
  /// **'Workout saved 🔥'**
  String get workoutSaved;

  /// No description provided for @workoutLabelValue.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String workoutLabelValue(String label, String value);

  /// No description provided for @workoutVolumeTonnes.
  ///
  /// In en, this message translates to:
  /// **'{value} t'**
  String workoutVolumeTonnes(String value);

  /// No description provided for @workoutInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get workoutInstructions;

  /// No description provided for @workoutNoInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions available'**
  String get workoutNoInstructions;

  /// No description provided for @workoutCompletedToast.
  ///
  /// In en, this message translates to:
  /// **'Workout Completed 🔥'**
  String get workoutCompletedToast;

  /// No description provided for @workoutLogAsDone.
  ///
  /// In en, this message translates to:
  /// **'Log as done'**
  String get workoutLogAsDone;

  /// No description provided for @workoutOpen.
  ///
  /// In en, this message translates to:
  /// **'Open workout'**
  String get workoutOpen;

  /// No description provided for @workoutAddAndStart.
  ///
  /// In en, this message translates to:
  /// **'Add to workout & start'**
  String get workoutAddAndStart;

  /// No description provided for @workoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress · {count, plural, =1{1 exercise} other{{count} exercises}}'**
  String workoutInProgress(int count);

  /// No description provided for @workoutRemoveExercise.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get workoutRemoveExercise;

  /// No description provided for @workoutAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get workoutAddSet;

  /// No description provided for @workoutRemoveSet.
  ///
  /// In en, this message translates to:
  /// **'Remove set'**
  String get workoutRemoveSet;

  /// No description provided for @workoutColSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get workoutColSet;

  /// No description provided for @workoutColKg.
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get workoutColKg;

  /// No description provided for @workoutColReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get workoutColReps;

  /// No description provided for @workoutSetWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {n} weight in kg'**
  String workoutSetWeightLabel(int n);

  /// No description provided for @workoutSetRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {n} reps'**
  String workoutSetRepsLabel(int n);

  /// No description provided for @workoutSetUndone.
  ///
  /// In en, this message translates to:
  /// **'Mark set not done'**
  String get workoutSetUndone;

  /// No description provided for @workoutSetDone.
  ///
  /// In en, this message translates to:
  /// **'Complete set'**
  String get workoutSetDone;

  /// No description provided for @workoutLastTime.
  ///
  /// In en, this message translates to:
  /// **'Last time: {summary}'**
  String workoutLastTime(String summary);

  /// No description provided for @workoutRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get workoutRest;

  /// No description provided for @workoutRestRemaining.
  ///
  /// In en, this message translates to:
  /// **'Rest remaining'**
  String get workoutRestRemaining;

  /// No description provided for @workoutNeedOneSet.
  ///
  /// In en, this message translates to:
  /// **'Complete at least one set to save the workout.'**
  String get workoutNeedOneSet;

  /// No description provided for @workoutHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load workout history'**
  String get workoutHistoryFailed;

  /// No description provided for @bodyChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Chart'**
  String get bodyChartTitle;

  /// No description provided for @bodySearchWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Search Workouts'**
  String get bodySearchWorkouts;

  /// No description provided for @bodyFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get bodyFront;

  /// No description provided for @bodyBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get bodyBack;

  /// No description provided for @bodyMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get bodyMuscles;

  /// No description provided for @foodItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Food Items'**
  String get foodItemsTitle;

  /// No description provided for @foodSaved.
  ///
  /// In en, this message translates to:
  /// **'Food item saved successfully'**
  String get foodSaved;

  /// No description provided for @foodEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Food Item'**
  String get foodEditTitle;

  /// No description provided for @foodManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Food Entry'**
  String get foodManualTitle;

  /// No description provided for @foodCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Food'**
  String get foodCreateCustom;

  /// No description provided for @foodCreateCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Add your own food items with nutrition values'**
  String get foodCreateCustomHint;

  /// No description provided for @foodInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Food Information'**
  String get foodInfoSection;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @foodNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter food name'**
  String get foodNameHint;

  /// No description provided for @foodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Food name is required'**
  String get foodNameRequired;

  /// No description provided for @foodBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand (Optional)'**
  String get foodBrand;

  /// No description provided for @foodBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Ex. Homemade / Amul / Nestle'**
  String get foodBrandHint;

  /// No description provided for @foodServingSection.
  ///
  /// In en, this message translates to:
  /// **'Serving Information'**
  String get foodServingSection;

  /// No description provided for @foodQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get foodQuantity;

  /// No description provided for @foodPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get foodPositiveNumber;

  /// No description provided for @foodValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get foodValidNumber;

  /// No description provided for @foodUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get foodUnit;

  /// No description provided for @foodNutritionSection.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Values'**
  String get foodNutritionSection;

  /// No description provided for @foodUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Food Item'**
  String get foodUpdate;

  /// No description provided for @foodSave.
  ///
  /// In en, this message translates to:
  /// **'Save Food Item'**
  String get foodSave;

  /// No description provided for @foodEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Food Items'**
  String get foodEmpty;

  /// No description provided for @foodPer.
  ///
  /// In en, this message translates to:
  /// **'Per {quantity} {unit}'**
  String foodPer(String quantity, String unit);

  /// No description provided for @foodManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get foodManual;

  /// No description provided for @foodScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get foodScanned;

  /// No description provided for @foodDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Food Item'**
  String get foodDeleteTitle;

  /// No description provided for @foodDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String foodDeleteBody(String name);

  /// No description provided for @foodAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Food Item'**
  String get foodAddTitle;

  /// No description provided for @foodAddHow.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add food'**
  String get foodAddHow;

  /// No description provided for @foodScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get foodScanBarcode;

  /// No description provided for @foodScanBarcodeHint.
  ///
  /// In en, this message translates to:
  /// **'Quickly scan packaged food items'**
  String get foodScanBarcodeHint;

  /// No description provided for @foodAddManually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get foodAddManually;

  /// No description provided for @foodAddManuallyHint.
  ///
  /// In en, this message translates to:
  /// **'Create your own custom food item'**
  String get foodAddManuallyHint;

  /// No description provided for @foodLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load food items'**
  String get foodLoadFailed;

  /// No description provided for @foodDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete food item'**
  String get foodDeleteFailed;

  /// No description provided for @foodSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get foodSaveFailed;

  /// No description provided for @foodUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update food item'**
  String get foodUpdateFailed;

  /// No description provided for @scanUnknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get scanUnknownProduct;

  /// No description provided for @scanCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get scanCameraTitle;

  /// No description provided for @scanCameraBody.
  ///
  /// In en, this message translates to:
  /// **'Please allow camera access to scan food barcodes.'**
  String get scanCameraBody;

  /// No description provided for @scanGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get scanGrant;

  /// No description provided for @scanGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get scanGoBack;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Food Barcode'**
  String get scanTitle;

  /// No description provided for @scanAlign.
  ///
  /// In en, this message translates to:
  /// **'Align barcode inside the frame'**
  String get scanAlign;

  /// No description provided for @scanOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and scan again.'**
  String get scanOffline;

  /// No description provided for @scanNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this product. Try again or add it manually.'**
  String get scanNotFound;

  /// No description provided for @calcTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Calculators'**
  String get calcTitle;

  /// No description provided for @calcBmiTitle.
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator'**
  String get calcBmiTitle;

  /// No description provided for @calcBmiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check body mass index'**
  String get calcBmiSubtitle;

  /// No description provided for @calcWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get calcWaterTitle;

  /// No description provided for @calcWaterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily hydration goal'**
  String get calcWaterSubtitle;

  /// No description provided for @calcProteinTitle.
  ///
  /// In en, this message translates to:
  /// **'Protein Calculator'**
  String get calcProteinTitle;

  /// No description provided for @calcProteinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily protein target'**
  String get calcProteinSubtitle;

  /// No description provided for @calcCaloriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Calories Calculator'**
  String get calcCaloriesTitle;

  /// No description provided for @calcCaloriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance calories'**
  String get calcCaloriesSubtitle;

  /// No description provided for @calcTypeBmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get calcTypeBmi;

  /// No description provided for @calcTypeWater.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get calcTypeWater;

  /// No description provided for @calcTypeProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get calcTypeProtein;

  /// No description provided for @calcTypeCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calcTypeCalories;

  /// No description provided for @calcWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get calcWeightHint;

  /// No description provided for @calcHeightHint.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get calcHeightHint;

  /// No description provided for @calcGoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get calcGoalMaintain;

  /// No description provided for @calcGoalFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Fat Loss'**
  String get calcGoalFatLoss;

  /// No description provided for @calcGoalMuscleGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get calcGoalMuscleGain;

  /// No description provided for @calcActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get calcActivityLevel;

  /// No description provided for @calcErrWeightHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid positive weight and height'**
  String get calcErrWeightHeight;

  /// No description provided for @calcErrWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid positive weight'**
  String get calcErrWeight;

  /// No description provided for @calcErrAll.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid positive weight, height and age'**
  String get calcErrAll;

  /// No description provided for @calcCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calcCalculate;

  /// No description provided for @calcTagline.
  ///
  /// In en, this message translates to:
  /// **'Track your fitness smarter'**
  String get calcTagline;

  /// No description provided for @calcNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get calcNoResults;

  /// No description provided for @calcNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a calculation to see results here.'**
  String get calcNoResultsBody;

  /// No description provided for @calcBmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get calcBmiUnderweight;

  /// No description provided for @calcBmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get calcBmiNormal;

  /// No description provided for @calcBmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get calcBmiOverweight;

  /// No description provided for @calcBmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get calcBmiObese;

  /// No description provided for @calcBmiDescription.
  ///
  /// In en, this message translates to:
  /// **'Your BMI is in the {category} range.'**
  String calcBmiDescription(String category);

  /// No description provided for @calcProteinResult.
  ///
  /// In en, this message translates to:
  /// **'Protein Intake'**
  String get calcProteinResult;

  /// No description provided for @calcProteinDescription.
  ///
  /// In en, this message translates to:
  /// **'Recommended protein intake per day.'**
  String get calcProteinDescription;

  /// No description provided for @calcCaloriesResult.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Calories'**
  String get calcCaloriesResult;

  /// No description provided for @calcCaloriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Calories needed to maintain your weight.'**
  String get calcCaloriesDescription;

  /// No description provided for @calcWaterResult.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Intake'**
  String get calcWaterResult;

  /// No description provided for @calcWaterDescription.
  ///
  /// In en, this message translates to:
  /// **'General guideline: weight (kg) × 0.035 liters. Adjust for climate, activity, and personal needs.'**
  String get calcWaterDescription;

  /// No description provided for @metricNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get metricNoData;

  /// No description provided for @metricAddManually.
  ///
  /// In en, this message translates to:
  /// **'Add data manually'**
  String get metricAddManually;

  /// No description provided for @metricLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get metricLast7Days;

  /// No description provided for @metricAddWeight.
  ///
  /// In en, this message translates to:
  /// **'Add Weight'**
  String get metricAddWeight;

  /// No description provided for @metricAddHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Add Heart Rate'**
  String get metricAddHeartRate;

  /// No description provided for @metricAddSleep.
  ///
  /// In en, this message translates to:
  /// **'Add Sleep'**
  String get metricAddSleep;

  /// No description provided for @metricUnitBpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get metricUnitBpm;

  /// No description provided for @metricUnitHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get metricUnitHours;

  /// No description provided for @metricEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter {unit}'**
  String metricEnter(String unit);

  /// Toggle for weekly chart, one letter
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get metricWeekShort;

  /// Toggle for monthly chart, one letter
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get metricMonthShort;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get reportTitle;

  /// No description provided for @reportLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load. Retry'**
  String get reportLoadFailed;

  /// No description provided for @reportWeightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight trend'**
  String get reportWeightTrend;

  /// No description provided for @reportWeightTrendSub.
  ///
  /// In en, this message translates to:
  /// **'Weekly average, last 8 weeks'**
  String get reportWeightTrendSub;

  /// No description provided for @reportWeightTrendLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest {weight} · weekly average, last 8 weeks'**
  String reportWeightTrendLatest(String weight);

  /// No description provided for @reportMacroAdherence.
  ///
  /// In en, this message translates to:
  /// **'Macro adherence'**
  String get reportMacroAdherence;

  /// No description provided for @reportMacroSub.
  ///
  /// In en, this message translates to:
  /// **'Eaten vs. your daily goals'**
  String get reportMacroSub;

  /// No description provided for @reportMacroOnTarget.
  ///
  /// In en, this message translates to:
  /// **'{pct}% on target over {days} logged days'**
  String reportMacroOnTarget(int pct, int days);

  /// No description provided for @reportPrevWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get reportPrevWeek;

  /// No description provided for @reportNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get reportNextWeek;

  /// No description provided for @reportGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get reportGoal;

  /// No description provided for @reportScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get reportScore;

  /// No description provided for @reportMacrosOnTarget.
  ///
  /// In en, this message translates to:
  /// **'Macros on target'**
  String get reportMacrosOnTarget;

  /// No description provided for @reportWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get reportWorkouts;

  /// No description provided for @reportWaterGoal.
  ///
  /// In en, this message translates to:
  /// **'Water goal'**
  String get reportWaterGoal;

  /// No description provided for @reportVsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs last week'**
  String get reportVsLastWeek;

  /// No description provided for @reportLatest.
  ///
  /// In en, this message translates to:
  /// **'latest'**
  String get reportLatest;

  /// No description provided for @reportLoggedDays.
  ///
  /// In en, this message translates to:
  /// **'logged {logged}/{days} days'**
  String reportLoggedDays(int logged, int days);

  /// No description provided for @reportSetsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String reportSetsCount(int count);

  /// No description provided for @reportThisWeekCaption.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get reportThisWeekCaption;

  /// No description provided for @reportDaysMet.
  ///
  /// In en, this message translates to:
  /// **'days met'**
  String get reportDaysMet;

  /// No description provided for @reportWeightEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log your weight to see the trend.'**
  String get reportWeightEmpty;

  /// No description provided for @reportWeightTrendLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight trend: {values}'**
  String reportWeightTrendLabel(String values);

  /// No description provided for @reportSetMacroGoals.
  ///
  /// In en, this message translates to:
  /// **'Set macro goals in your profile to track adherence.'**
  String get reportSetMacroGoals;

  /// No description provided for @reportTickMeals.
  ///
  /// In en, this message translates to:
  /// **'Tick off meals in your diet plan to see your macros.'**
  String get reportTickMeals;

  /// No description provided for @reportWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly progress'**
  String get reportWeeklyProgress;

  /// No description provided for @reportFull.
  ///
  /// In en, this message translates to:
  /// **'Full report'**
  String get reportFull;

  /// No description provided for @reportThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get reportThisWeek;

  /// No description provided for @reportLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get reportLastWeek;

  /// No description provided for @waterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterTitle;

  /// No description provided for @waterDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily water goal'**
  String get waterDailyGoal;

  /// No description provided for @waterRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for your weight: {amount}'**
  String waterRecommended(String amount);

  /// No description provided for @waterAdd.
  ///
  /// In en, this message translates to:
  /// **'Add water'**
  String get waterAdd;

  /// No description provided for @waterEditGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get waterEditGoal;

  /// No description provided for @waterReminders.
  ///
  /// In en, this message translates to:
  /// **'Hydration reminders'**
  String get waterReminders;

  /// No description provided for @waterRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Every 2 hours, 10 AM to 6 PM. Paused for the day once you hit your goal.'**
  String get waterRemindersHint;

  /// No description provided for @waterCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get waterCustom;

  /// No description provided for @waterNothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Tap an amount above.'**
  String get waterNothingLogged;

  /// No description provided for @waterSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to remove an entry.'**
  String get waterSwipeHint;

  /// No description provided for @waterLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your water log.'**
  String get waterLoadFailed;

  /// No description provided for @waterTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Water today: {total} of {goal}'**
  String waterTodayLabel(String total, String goal);

  /// No description provided for @waterGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached 🎉'**
  String get waterGoalReached;

  /// No description provided for @waterToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String waterToGo(String amount);

  /// No description provided for @waterEnterBetween.
  ///
  /// In en, this message translates to:
  /// **'Enter between {min} and {max} ml'**
  String waterEnterBetween(int min, int max);

  /// No description provided for @waterAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get waterAmount;

  /// No description provided for @waterGoalMet.
  ///
  /// In en, this message translates to:
  /// **'Goal met {count}/7'**
  String waterGoalMet(int count);

  /// No description provided for @waterInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between 1 and 3000 ml.'**
  String get waterInvalidAmount;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Notifications Yet'**
  String get notifEmpty;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notifSettingsTitle;

  /// No description provided for @notifDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for BeFit. Enable them in your device settings to receive reminders.'**
  String get notifDisabled;

  /// No description provided for @notifReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifReminders;

  /// No description provided for @notifWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout Reminder'**
  String get notifWorkout;

  /// No description provided for @notifWorkoutHint.
  ///
  /// In en, this message translates to:
  /// **'Daily workout motivation'**
  String get notifWorkoutHint;

  /// No description provided for @notifWater.
  ///
  /// In en, this message translates to:
  /// **'Water Reminder'**
  String get notifWater;

  /// No description provided for @notifWaterHint.
  ///
  /// In en, this message translates to:
  /// **'Every 2 hours, 10 AM–6 PM. Paused once you hit your goal'**
  String get notifWaterHint;

  /// No description provided for @notifMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal Reminder'**
  String get notifMeal;

  /// No description provided for @notifMealHint.
  ///
  /// In en, this message translates to:
  /// **'Track your daily meals'**
  String get notifMealHint;

  /// No description provided for @notifStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak Reminder'**
  String get notifStreak;

  /// No description provided for @notifStreakHint.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak alive'**
  String get notifStreakHint;

  /// No description provided for @notifReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get notifReminderTime;

  /// No description provided for @notifWorkoutTime.
  ///
  /// In en, this message translates to:
  /// **'Workout Reminder Time'**
  String get notifWorkoutTime;

  /// No description provided for @reminderWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'💪 Time to move'**
  String get reminderWorkoutTitle;

  /// No description provided for @reminderWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Your workout is waiting. A short session still counts!'**
  String get reminderWorkoutBody;

  /// No description provided for @reminderMealTitle.
  ///
  /// In en, this message translates to:
  /// **'🍽️ Log your meal'**
  String get reminderMealTitle;

  /// No description provided for @reminderMealBody.
  ///
  /// In en, this message translates to:
  /// **'Tick off your meal to stay on track with your plan.'**
  String get reminderMealBody;

  /// No description provided for @reminderWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'💧 Hydration check'**
  String get reminderWaterTitle;

  /// No description provided for @reminderWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Time for a glass of water. Tap to log it in BeFit.'**
  String get reminderWaterBody;

  /// No description provided for @reminderStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'🔥 Streak at risk'**
  String get reminderStreakTitle;

  /// No description provided for @reminderStreakBody.
  ///
  /// In en, this message translates to:
  /// **'Log a workout or meal today to keep your streak alive.'**
  String get reminderStreakBody;

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get coachTitle;

  /// No description provided for @coachSuggest1.
  ///
  /// In en, this message translates to:
  /// **'How am I doing this week?'**
  String get coachSuggest1;

  /// No description provided for @coachSuggest2.
  ///
  /// In en, this message translates to:
  /// **'How can I hit my protein goal?'**
  String get coachSuggest2;

  /// No description provided for @coachSuggest3.
  ///
  /// In en, this message translates to:
  /// **'Plan a 30-minute workout for today'**
  String get coachSuggest3;

  /// No description provided for @coachSuggest4.
  ///
  /// In en, this message translates to:
  /// **'What should I eat after a workout?'**
  String get coachSuggest4;

  /// No description provided for @coachRemoveModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove on-device model?'**
  String get coachRemoveModelTitle;

  /// No description provided for @coachRemoveModelBody.
  ///
  /// In en, this message translates to:
  /// **'This frees up storage. The coach will use cloud AI until you download the model again.'**
  String get coachRemoveModelBody;

  /// No description provided for @coachMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get coachMore;

  /// No description provided for @coachClearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get coachClearChat;

  /// No description provided for @coachRemoveModel.
  ///
  /// In en, this message translates to:
  /// **'Remove on-device model'**
  String get coachRemoveModel;

  /// No description provided for @coachIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about training, food or recovery.'**
  String get coachIntro;

  /// No description provided for @coachIntroHint.
  ///
  /// In en, this message translates to:
  /// **'I use your profile, today\'s activity and this week\'s report to tailor answers. General guidance, not medical advice.'**
  String get coachIntroHint;

  /// No description provided for @coachAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your coach…'**
  String get coachAskHint;

  /// No description provided for @coachStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get coachStop;

  /// No description provided for @coachSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get coachSend;

  /// No description provided for @coachOnDevice.
  ///
  /// In en, this message translates to:
  /// **'On-device'**
  String get coachOnDevice;

  /// No description provided for @coachCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get coachCloud;

  /// No description provided for @coachThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get coachThinking;

  /// No description provided for @coachDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading Gemma… {progress}%'**
  String coachDownloading(int progress);

  /// No description provided for @coachRunOffline.
  ///
  /// In en, this message translates to:
  /// **'Run the coach offline'**
  String get coachRunOffline;

  /// No description provided for @coachDownloadHint.
  ///
  /// In en, this message translates to:
  /// **'Download Gemma once ({size}, Wi-Fi recommended). Answers are then generated on your phone, and your data never leaves it.'**
  String coachDownloadHint(String size);

  /// No description provided for @coachDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get coachDownload;

  /// No description provided for @coachUsingCloud.
  ///
  /// In en, this message translates to:
  /// **'Using cloud AI'**
  String get coachUsingCloud;

  /// No description provided for @coachLowMemory.
  ///
  /// In en, this message translates to:
  /// **'This phone doesn\'t have enough memory for the on-device model, so answers come from Gemini over the internet.'**
  String get coachLowMemory;

  /// No description provided for @coachModelSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'The model downloaded but couldn\'t be set up.'**
  String get coachModelSetupFailed;

  /// No description provided for @coachDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection and try again.'**
  String get coachDownloadFailed;

  /// No description provided for @coachOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Download the on-device model to chat without internet.'**
  String get coachOffline;

  /// No description provided for @coachError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the coach right now. Try again.'**
  String get coachError;

  /// No description provided for @coachEmpty.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t come up with an answer. Try rephrasing your question.'**
  String get coachEmpty;

  /// No description provided for @coachStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped.'**
  String get coachStopped;

  /// No description provided for @coachEmergency.
  ///
  /// In en, this message translates to:
  /// **'This could be serious, so please don\'t rely on an app for it. Stop exercising and contact a doctor or your local emergency number (112 in India) right away. If you are thinking about harming yourself, please reach out to someone you trust or a helpline such as Tele-MANAS (14416) now.'**
  String get coachEmergency;

  /// No description provided for @coachProfessional.
  ///
  /// In en, this message translates to:
  /// **'That\'s a topic where advice needs to fit your health history, so I can\'t give guidance on it. Please talk to a doctor or a registered dietitian. I can still help with general training, steps, water and balanced eating.'**
  String get coachProfessional;

  /// No description provided for @a11yProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get a11yProfile;

  /// No description provided for @a11yLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get a11yLearnMore;

  /// No description provided for @bodyShowBack.
  ///
  /// In en, this message translates to:
  /// **'Show back view'**
  String get bodyShowBack;

  /// No description provided for @bodyShowFront.
  ///
  /// In en, this message translates to:
  /// **'Show front view'**
  String get bodyShowFront;

  /// Screen-reader hint for long press on a muscle
  ///
  /// In en, this message translates to:
  /// **'exclude from workout search'**
  String get bodyExcludeHint;

  /// No description provided for @bodyExcluded.
  ///
  /// In en, this message translates to:
  /// **'Excluded'**
  String get bodyExcluded;

  /// No description provided for @waterOfGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String waterOfGoal(String goal);

  /// No description provided for @a11yTorch.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get a11yTorch;

  /// No description provided for @a11yClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get a11yClearSearch;

  /// No description provided for @metricWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get metricWeek;

  /// No description provided for @metricMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get metricMonth;

  /// No description provided for @a11yOverallHealth.
  ///
  /// In en, this message translates to:
  /// **'Overall health {percent}%: {steps} steps, {calories} kcal, {minutes} active minutes'**
  String a11yOverallHealth(
    String percent,
    int steps,
    int calories,
    int minutes,
  );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
