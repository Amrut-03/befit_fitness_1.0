// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BeFit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonDone => 'Done';

  @override
  String get commonOk => 'OK';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get commonNoInternet => 'No internet connection.';

  @override
  String unitKg(String value) {
    return '$value kg';
  }

  @override
  String unitMl(String value) {
    return '$value ml';
  }

  @override
  String unitKcal(String value) {
    return '$value kcal';
  }

  @override
  String unitGrams(String value) {
    return '$value g';
  }

  @override
  String unitMinutes(String value) {
    return '$value min';
  }

  @override
  String unitCm(String value) {
    return '$value cm';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get failureNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get failureTimeout => 'This is taking too long. Please try again.';

  @override
  String get failureServer =>
      'The service is unavailable right now. Please try again.';

  @override
  String get failureNotFound => 'We couldn\'t find that.';

  @override
  String get failureAuth => 'Please sign in again.';

  @override
  String get historyEmptyTitle => 'No history yet';

  @override
  String get historyEmptyBody => 'Complete workouts or diets to see history';

  @override
  String get historySummary => 'Summary';

  @override
  String get historyDetails => 'Details';

  @override
  String get educationWhyItMatters => 'Why it matters';

  @override
  String get educationTips => 'Tips';

  @override
  String get eduHealthTitle => 'Overall Health Score';

  @override
  String get eduHealthDescription =>
      'This score combines your daily activity metrics including steps, calories burned, and movement minutes.';

  @override
  String get eduHealthWhy =>
      'A higher score means you\'re consistently achieving your daily fitness goals and maintaining an active lifestyle.';

  @override
  String get eduHealthTip1 => 'Walk regularly throughout the day';

  @override
  String get eduHealthTip2 => 'Aim for your daily step target';

  @override
  String get eduHealthTip3 => 'Increase active movement minutes';

  @override
  String get eduHealthTip4 => 'Stay consistent every day';

  @override
  String get eduHealthTip5 => 'Combine cardio and strength training';

  @override
  String get eduBodyTitle => 'Interactive Body Chart';

  @override
  String get eduBodyDescription =>
      'The Body Chart helps you visually select muscle groups and discover workouts tailored to those muscles.';

  @override
  String get eduBodyWhy =>
      'Targeting specific muscle groups helps you train more effectively, maintain balance in your physique, and avoid neglecting important muscles.';

  @override
  String get eduBodyTip1 => 'Tap a muscle to select it';

  @override
  String get eduBodyTip2 =>
      'Select multiple muscles to focus on a workout area';

  @override
  String get eduBodyTip3 =>
      'Use Front and Back views to access all muscle groups';

  @override
  String get eduBodyTip4 =>
      'Press \'Search Workouts\' to find exercises for selected muscles';

  @override
  String get eduBodyTip5 => 'Long press a muscle to temporarily disable it';

  @override
  String get eduBodyTip6 => 'Train all major muscle groups throughout the week';

  @override
  String get loginWelcome => 'Welcome to BeFit';

  @override
  String get loginTagline =>
      'Track workouts, build healthy habits,\nand transform your fitness journey.';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginGuest => 'Continue as Guest';

  @override
  String get loginTerms =>
      'By continuing you agree to our\nTerms & Privacy Policy';

  @override
  String get authGoogleFailed => 'Google sign-in failed. Please try again.';

  @override
  String get authGuestFailed => 'Guest sign in failed';

  @override
  String get authLogoutFailed => 'Logout failed';

  @override
  String get linkAlreadyInUse =>
      'That Google account already has a BeFit account. Choose a different Google account to keep your guest progress.';

  @override
  String get linkNetwork =>
      'No internet connection. Your progress is safe; please try again.';

  @override
  String get linkNotGuest => 'Your account is already linked to Google.';

  @override
  String get linkFailed =>
      'Could not link your Google account. Please try again.';

  @override
  String get deleteCancelled => 'Account deletion cancelled.';

  @override
  String get deleteRecentLogin =>
      'For your security, please log out, sign in again, and then delete your account.';

  @override
  String get deleteWrongAccount =>
      'Please choose the Google account you signed in with.';

  @override
  String get deleteNetwork =>
      'No internet connection. Nothing was deleted. Please try again.';

  @override
  String get deleteNotSignedIn => 'You are not signed in.';

  @override
  String get deleteFailed => 'Could not delete your account. Please try again.';

  @override
  String get startupProfileFailed =>
      'Couldn\'t load your profile.\nCheck your connection.';

  @override
  String get goalBuildMuscle => 'Build Muscle';

  @override
  String get goalLoseWeight => 'Lose Weight';

  @override
  String get goalStayFit => 'Stay Fit';

  @override
  String get goalImproveStrength => 'Improve Strength';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderPreferNot => 'Prefer Not To Say';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activityLight => 'Lightly Active';

  @override
  String get activityActive => 'Active';

  @override
  String get activityAthlete => 'Athlete';

  @override
  String get onbTrackTitle => 'Track Workouts';

  @override
  String get onbTrackBody => 'Monitor your daily fitness journey.';

  @override
  String get onbNutritionTitle => 'Healthy Nutrition';

  @override
  String get onbNutritionBody => 'Plan meals and calories smartly.';

  @override
  String get onbConsistentTitle => 'Stay Consistent';

  @override
  String get onbConsistentBody => 'Build habits and reach your goals.';

  @override
  String get onbGetStarted => 'Get Started';

  @override
  String get onbGoalTitle => 'What\'s Your Goal?';

  @override
  String get onbGoalSubtitle => 'Personalize your fitness experience';

  @override
  String get onbGenderTitle => 'Select Gender';

  @override
  String get onbGenderSubtitle => 'Help us personalize your experience';

  @override
  String get onbActivityTitle => 'Activity Level';

  @override
  String get onbActivitySubtitle => 'Tell us about your daily activity';

  @override
  String get onbMetricsTitle => 'Body Metrics';

  @override
  String get onbMetricsSubtitle => 'Help us calculate your fitness data';

  @override
  String get metricWeight => 'Weight';

  @override
  String get metricHeight => 'Height';

  @override
  String get metricAge => 'Age';

  @override
  String get unitKgShort => 'kg';

  @override
  String get unitCmShort => 'cm';

  @override
  String get unitYearsShort => 'yrs';

  @override
  String get onbProfileNotFound => 'Profile not found';

  @override
  String get goalFitnessGoal => 'Fitness Goal';

  @override
  String get historyTitle => 'History';

  @override
  String get historyDietTitle => 'Diet History';

  @override
  String get historyDietSubtitle => 'View completed diet plans';

  @override
  String get historyWorkoutTitle => 'Workout History';

  @override
  String get historyWorkoutSubtitle => 'View completed workouts';

  @override
  String get profileFitnessStats => 'Fitness Stats';

  @override
  String get profileShareProgress => 'Share Progress';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileLogoutGuestWarning =>
      'You\'re using a guest account. After logging out you can\'t get back to your data. Tap \'Save your progress\' first to keep it.';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileEnterName => 'Enter name';

  @override
  String get profileGoal => 'Goal';

  @override
  String get profileWeightKg => 'Weight (kg)';

  @override
  String get profileEnterWeight => 'Enter weight';

  @override
  String get profileHeightCm => 'Height (cm)';

  @override
  String get profileEnterHeight => 'Enter height';

  @override
  String get profileEnterAge => 'Enter age';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileInvalidWeight => 'Please enter valid weight';

  @override
  String get profileInvalidHeight => 'Please enter valid height';

  @override
  String get profileInvalidAge => 'Please enter valid age';

  @override
  String get profilePositiveValues =>
      'Weight and height must be positive values';

  @override
  String get profileSave => 'Save Profile';

  @override
  String get statWeight => 'Weight';

  @override
  String get statHeight => 'Height';

  @override
  String get statAge => 'Age';

  @override
  String get statStreak => 'Streak';

  @override
  String get statBmi => 'BMI';

  @override
  String get statCalories => 'Calories';

  @override
  String get statSteps => 'Steps';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String shareDayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Day Streak',
      one: '1 Day Streak',
    );
    return '$_temp0';
  }

  @override
  String get shareConsistency => 'Consistency creates results';

  @override
  String get shareQuote => '\"Discipline beats motivation.\"';

  @override
  String get shareGeneratedWith => 'Generated with BeFit';

  @override
  String get shareSavedToGallery => 'Image saved to gallery ✅';

  @override
  String get shareSaveToGallery => 'Save to Gallery';

  @override
  String get shareText => 'Check out my fitness progress on BeFit 🔥';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get accountDeleting => 'Deleting account…';

  @override
  String get accountDelete => 'Delete Account';

  @override
  String get accountDeleteTitle => 'Delete account?';

  @override
  String get accountDeleteBody =>
      'This permanently deletes your account and all your data: profile, diet plans, food items, workout history, health metrics and streak. This cannot be undone.';

  @override
  String get accountDeleteGoogleConfirm =>
      'You will be asked to confirm with Google.';

  @override
  String progressSavedTo(String email) {
    return 'Progress saved to $email.';
  }

  @override
  String get progressYourGoogleAccount => 'your Google account';

  @override
  String get progressLinking => 'Linking…';

  @override
  String get progressSave => 'Save your progress';

  @override
  String get progressGuestHint =>
      'You\'re using a guest account. Link Google to keep your data if you sign out or change phones.';

  @override
  String get homeGoodMorning => 'Good Morning';

  @override
  String get homeGoodAfternoon => 'Good Afternoon';

  @override
  String get homeGoodEvening => 'Good Evening';

  @override
  String get homeTodaysGoals => 'Today\'s Goals';

  @override
  String get homeHeartRate => 'Heart Rate';

  @override
  String get homeSleep => 'Sleep';

  @override
  String get homeMoveMin => 'Move Min';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get qaDietPlan => 'Diet Plan';

  @override
  String get qaDietPlanSub => 'Track your macros';

  @override
  String get qaWorkout => 'Workout';

  @override
  String get qaWorkoutSub => 'Training plans';

  @override
  String get qaCalculator => 'Health Calculator';

  @override
  String get qaCalculatorSub => 'BMI & nutrition';

  @override
  String get qaScanFood => 'Scan Food';

  @override
  String get qaScanFoodSub => 'Barcode scanner';

  @override
  String get qaMyFoods => 'My Foods';

  @override
  String get qaMyFoodsSub => 'Manage items';

  @override
  String get qaHistorySub => 'Diet & workouts';

  @override
  String get dietCardAllDone => 'Meals Completed 🎉';

  @override
  String get dietCardAllDoneBody =>
      'Awesome work! You completed all your meals for today.';

  @override
  String get dietCardGoalAchieved => 'Daily Goal Achieved';

  @override
  String get dietCardResets => 'Your tracking will reset tomorrow';

  @override
  String get dietCardNoPlan => 'No Active Plan';

  @override
  String get dietCardNoPlanBody => 'Start a diet plan to track your progress';

  @override
  String get dietCardExplore => 'Explore Plans';

  @override
  String get dietCardActivePlan => 'Active Plan';

  @override
  String get dietCardUntitled => 'Untitled Plan';

  @override
  String get dietCardActiveBadge => 'ACTIVE';

  @override
  String get dietCardMeals => 'Meals';

  @override
  String get homeLoadFailed => 'Failed to load dashboard';

  @override
  String healthConnectTitle(String store) {
    return 'Connect $store';
  }

  @override
  String get healthConnectInstallBody =>
      'Install or update Health Connect to sync steps, calories, sleep and heart rate.';

  @override
  String get healthConnectBody =>
      'Sync steps, calories, sleep, heart rate and weight from your watch and other apps.';

  @override
  String get healthInstall => 'Install';

  @override
  String get healthConnect => 'Connect';

  @override
  String get insightsTitle => 'AI Insights';

  @override
  String get insightsAskCoach => 'Ask coach';

  @override
  String get insightsEmpty => 'No insights today. Try again later.';

  @override
  String get insightsOffline =>
      'You\'re offline. Insights will load when you\'re back online, or download the on-device model in AI Coach to get them offline.';

  @override
  String get insightsFailed => 'Couldn\'t load AI insights right now.';

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroFat => 'Fat';

  @override
  String get macroCalShort => 'Cal';

  @override
  String get macroCarbShort => 'Carb';

  @override
  String get macroProtShort => 'Prot';

  @override
  String macroSummary(int protein, int carbs, int fat) {
    return '${protein}g Protein • ${carbs}g Carbs • ${fat}g Fat';
  }

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get foodUnitPiece => 'piece';

  @override
  String get foodUnitSlice => 'slice';

  @override
  String get foodUnitCup => 'cup';

  @override
  String get dietPlanningTitle => 'Diet Planning';

  @override
  String get dietNoPlans => 'No diet plans saved yet';

  @override
  String get dietNoPlansHint => 'Tap the button below to plan your diet';

  @override
  String get dietPlanYourDiet => 'Plan Your Diet';

  @override
  String get dietDeleteTitle => 'Delete Diet Plan';

  @override
  String dietDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String dietMealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String dietMealsCompleted(int done, int total) {
    return '$done/$total meals completed';
  }

  @override
  String get dietInactiveBadge => 'INACTIVE';

  @override
  String get dietActivated => 'Activated';

  @override
  String get dietSetActive => 'Set Active';

  @override
  String get dietSavePlan => 'Save Diet Plan';

  @override
  String get dietAddFood => 'Add Food';

  @override
  String get dietPendingMeals => 'Pending Meals';

  @override
  String get dietCompletedMeals => 'Completed Meals';

  @override
  String get dietTotalNutrition => 'Total Nutrition';

  @override
  String get dietNoFood => 'No food added yet';

  @override
  String get dietNoFoodHint => 'Tap \"Add Food\" to build your diet plan';

  @override
  String get dietEditQuantity => 'Edit Quantity';

  @override
  String get dietQuantity => 'Quantity';

  @override
  String get dietUnit => 'Unit';

  @override
  String get dietUpdateQuantity => 'Update Quantity';

  @override
  String get dietConfirmMeal => 'Confirm Meal';

  @override
  String dietConfirmMealBody(String meal) {
    return 'Are you sure you consumed $meal?\n\nThis action cannot be undone today.';
  }

  @override
  String get dietConfirm => 'Confirm';

  @override
  String get dietPlanName => 'Diet Plan Name';

  @override
  String get dietEnterPlanName => 'Enter diet plan name';

  @override
  String get dietDailyMacros => 'Daily Macros';

  @override
  String get dietSelectFood => 'Select Food items';

  @override
  String get dietSearchFood => 'Search food...';

  @override
  String get dietNoFoodFound => 'No food items found';

  @override
  String dietAddNFood(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count foods',
      one: 'Add 1 food',
    );
    return '$_temp0';
  }

  @override
  String get dietLoadPlansFailed => 'Failed to load diet plans';

  @override
  String get dietLoadHistoryFailed => 'Failed to load diet history';

  @override
  String get dietSaveFailed => 'Failed to save plan';

  @override
  String get dietActivateFailed => 'Failed to update active plan';

  @override
  String get dietDeleteFailed => 'Failed to delete plan';

  @override
  String get dietUpdateMealsFailed => 'Failed to update meals';

  @override
  String get workoutsTitle => 'Workouts';

  @override
  String get workoutSearch => 'Search workouts...';

  @override
  String get workoutNoExercises => 'No exercises found';

  @override
  String get workoutInYourWorkout => 'In your workout';

  @override
  String get workoutAddTo => 'Add to workout';

  @override
  String workoutExercisesSets(int exercises, int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercises',
      one: '1 exercise',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get workoutCompleted => 'Completed';

  @override
  String get workoutTarget => 'Target';

  @override
  String get workoutDuration => 'Duration';

  @override
  String get workoutSets => 'Sets';

  @override
  String get workoutVolume => 'Volume';

  @override
  String get workoutDiscardTitle => 'Discard workout?';

  @override
  String get workoutDiscardBody =>
      'Your sets won\'t be saved and this won\'t count toward your streak.';

  @override
  String get workoutKeepGoing => 'Keep going';

  @override
  String get workoutDiscard => 'Discard';

  @override
  String get workoutDiscardTooltip => 'Discard workout';

  @override
  String get workoutNoExercisesYet =>
      'No exercises yet. Add some to get started.';

  @override
  String get workoutAddExercise => 'Add exercise';

  @override
  String get workoutFinish => 'Finish workout';

  @override
  String get workoutNoSession => 'No workout in progress';

  @override
  String get workoutNoSessionHint =>
      'Add exercises from the list to start a session.';

  @override
  String get workoutBrowse => 'Browse exercises';

  @override
  String get workoutSaved => 'Workout saved 🔥';

  @override
  String workoutLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String workoutVolumeTonnes(String value) {
    return '$value t';
  }

  @override
  String get workoutInstructions => 'Instructions';

  @override
  String get workoutNoInstructions => 'No instructions available';

  @override
  String get workoutCompletedToast => 'Workout Completed 🔥';

  @override
  String get workoutLogAsDone => 'Log as done';

  @override
  String get workoutOpen => 'Open workout';

  @override
  String get workoutAddAndStart => 'Add to workout & start';

  @override
  String workoutInProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return 'Workout in progress · $_temp0';
  }

  @override
  String get workoutRemoveExercise => 'Remove exercise';

  @override
  String get workoutAddSet => 'Add set';

  @override
  String get workoutRemoveSet => 'Remove set';

  @override
  String get workoutColSet => 'SET';

  @override
  String get workoutColKg => 'KG';

  @override
  String get workoutColReps => 'REPS';

  @override
  String workoutSetWeightLabel(int n) {
    return 'Set $n weight in kg';
  }

  @override
  String workoutSetRepsLabel(int n) {
    return 'Set $n reps';
  }

  @override
  String get workoutSetUndone => 'Mark set not done';

  @override
  String get workoutSetDone => 'Complete set';

  @override
  String workoutLastTime(String summary) {
    return 'Last time: $summary';
  }

  @override
  String get workoutRest => 'Rest';

  @override
  String get workoutRestRemaining => 'Rest remaining';

  @override
  String get workoutNeedOneSet =>
      'Complete at least one set to save the workout.';

  @override
  String get workoutHistoryFailed => 'Failed to load workout history';

  @override
  String get bodyChartTitle => 'Body Chart';

  @override
  String get bodySearchWorkouts => 'Search Workouts';

  @override
  String get bodyFront => 'Front';

  @override
  String get bodyBack => 'Back';

  @override
  String get bodyMuscles => 'Muscles';

  @override
  String get foodItemsTitle => 'My Food Items';

  @override
  String get foodSaved => 'Food item saved successfully';

  @override
  String get foodEditTitle => 'Edit Food Item';

  @override
  String get foodManualTitle => 'Manual Food Entry';

  @override
  String get foodCreateCustom => 'Create Custom Food';

  @override
  String get foodCreateCustomHint =>
      'Add your own food items with nutrition values';

  @override
  String get foodInfoSection => 'Food Information';

  @override
  String get foodName => 'Food Name';

  @override
  String get foodNameHint => 'Enter food name';

  @override
  String get foodNameRequired => 'Food name is required';

  @override
  String get foodBrand => 'Brand (Optional)';

  @override
  String get foodBrandHint => 'Ex. Homemade / Amul / Nestle';

  @override
  String get foodServingSection => 'Serving Information';

  @override
  String get foodQuantity => 'Quantity';

  @override
  String get foodPositiveNumber => 'Enter a positive number';

  @override
  String get foodValidNumber => 'Enter a valid number';

  @override
  String get foodUnit => 'Unit';

  @override
  String get foodNutritionSection => 'Nutrition Values';

  @override
  String get foodUpdate => 'Update Food Item';

  @override
  String get foodSave => 'Save Food Item';

  @override
  String get foodEmpty => 'No Food Items';

  @override
  String foodPer(String quantity, String unit) {
    return 'Per $quantity $unit';
  }

  @override
  String get foodManual => 'Manual';

  @override
  String get foodScanned => 'Scanned';

  @override
  String get foodDeleteTitle => 'Delete Food Item';

  @override
  String foodDeleteBody(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get foodAddTitle => 'Add Food Item';

  @override
  String get foodAddHow => 'Choose how you want to add food';

  @override
  String get foodScanBarcode => 'Scan Barcode';

  @override
  String get foodScanBarcodeHint => 'Quickly scan packaged food items';

  @override
  String get foodAddManually => 'Add Manually';

  @override
  String get foodAddManuallyHint => 'Create your own custom food item';

  @override
  String get foodLoadFailed => 'Failed to load food items';

  @override
  String get foodDeleteFailed => 'Failed to delete food item';

  @override
  String get foodSaveFailed => 'Failed to save';

  @override
  String get foodUpdateFailed => 'Failed to update food item';

  @override
  String get scanUnknownProduct => 'Unknown Product';

  @override
  String get scanCameraTitle => 'Camera Permission Required';

  @override
  String get scanCameraBody =>
      'Please allow camera access to scan food barcodes.';

  @override
  String get scanGrant => 'Grant Permission';

  @override
  String get scanGoBack => 'Go Back';

  @override
  String get scanTitle => 'Scan Food Barcode';

  @override
  String get scanAlign => 'Align barcode inside the frame';

  @override
  String get scanOffline =>
      'No internet connection. Check your connection and scan again.';

  @override
  String get scanNotFound =>
      'We couldn\'t find this product. Try again or add it manually.';

  @override
  String get calcTitle => 'Health Calculators';

  @override
  String get calcBmiTitle => 'BMI Calculator';

  @override
  String get calcBmiSubtitle => 'Check body mass index';

  @override
  String get calcWaterTitle => 'Water Intake';

  @override
  String get calcWaterSubtitle => 'Daily hydration goal';

  @override
  String get calcProteinTitle => 'Protein Calculator';

  @override
  String get calcProteinSubtitle => 'Daily protein target';

  @override
  String get calcCaloriesTitle => 'Calories Calculator';

  @override
  String get calcCaloriesSubtitle => 'Maintenance calories';

  @override
  String get calcTypeBmi => 'BMI';

  @override
  String get calcTypeWater => 'Water Intake';

  @override
  String get calcTypeProtein => 'Protein';

  @override
  String get calcTypeCalories => 'Calories';

  @override
  String get calcWeightHint => 'Weight (kg)';

  @override
  String get calcHeightHint => 'Height (cm)';

  @override
  String get calcGoalMaintain => 'Maintain';

  @override
  String get calcGoalFatLoss => 'Fat Loss';

  @override
  String get calcGoalMuscleGain => 'Muscle Gain';

  @override
  String get calcActivityLevel => 'Activity Level';

  @override
  String get calcErrWeightHeight =>
      'Please enter valid positive weight and height';

  @override
  String get calcErrWeight => 'Please enter valid positive weight';

  @override
  String get calcErrAll => 'Please enter valid positive weight, height and age';

  @override
  String get calcCalculate => 'Calculate';

  @override
  String get calcTagline => 'Track your fitness smarter';

  @override
  String get calcNoResults => 'No results';

  @override
  String get calcNoResultsBody => 'Complete a calculation to see results here.';

  @override
  String get calcBmiUnderweight => 'Underweight';

  @override
  String get calcBmiNormal => 'Normal';

  @override
  String get calcBmiOverweight => 'Overweight';

  @override
  String get calcBmiObese => 'Obese';

  @override
  String calcBmiDescription(String category) {
    return 'Your BMI is in the $category range.';
  }

  @override
  String get calcProteinResult => 'Protein Intake';

  @override
  String get calcProteinDescription => 'Recommended protein intake per day.';

  @override
  String get calcCaloriesResult => 'Maintenance Calories';

  @override
  String get calcCaloriesDescription =>
      'Calories needed to maintain your weight.';

  @override
  String get calcWaterResult => 'Daily Water Intake';

  @override
  String get calcWaterDescription =>
      'General guideline: weight (kg) × 0.035 liters. Adjust for climate, activity, and personal needs.';

  @override
  String get metricNoData => 'No data yet';

  @override
  String get metricAddManually => 'Add data manually';

  @override
  String get metricLast7Days => 'Last 7 days';

  @override
  String get metricAddWeight => 'Add Weight';

  @override
  String get metricAddHeartRate => 'Add Heart Rate';

  @override
  String get metricAddSleep => 'Add Sleep';

  @override
  String get metricUnitBpm => 'BPM';

  @override
  String get metricUnitHours => 'Hours';

  @override
  String metricEnter(String unit) {
    return 'Enter $unit';
  }

  @override
  String get metricWeekShort => 'W';

  @override
  String get metricMonthShort => 'M';

  @override
  String get reportTitle => 'Weekly report';

  @override
  String get reportLoadFailed => 'Couldn\'t load. Retry';

  @override
  String get reportWeightTrend => 'Weight trend';

  @override
  String get reportWeightTrendSub => 'Weekly average, last 8 weeks';

  @override
  String reportWeightTrendLatest(String weight) {
    return 'Latest $weight · weekly average, last 8 weeks';
  }

  @override
  String get reportMacroAdherence => 'Macro adherence';

  @override
  String get reportMacroSub => 'Eaten vs. your daily goals';

  @override
  String reportMacroOnTarget(int pct, int days) {
    return '$pct% on target over $days logged days';
  }

  @override
  String get reportPrevWeek => 'Previous week';

  @override
  String get reportNextWeek => 'Next week';

  @override
  String get reportGoal => 'Goal';

  @override
  String get reportScore => 'Score';

  @override
  String get reportMacrosOnTarget => 'Macros on target';

  @override
  String get reportWorkouts => 'Workouts';

  @override
  String get reportWaterGoal => 'Water goal';

  @override
  String get reportVsLastWeek => 'vs last week';

  @override
  String get reportLatest => 'latest';

  @override
  String reportLoggedDays(int logged, int days) {
    return 'logged $logged/$days days';
  }

  @override
  String reportSetsCount(int count) {
    return '$count sets';
  }

  @override
  String get reportThisWeekCaption => 'this week';

  @override
  String get reportDaysMet => 'days met';

  @override
  String get reportWeightEmpty => 'Log your weight to see the trend.';

  @override
  String reportWeightTrendLabel(String values) {
    return 'Weight trend: $values';
  }

  @override
  String get reportSetMacroGoals =>
      'Set macro goals in your profile to track adherence.';

  @override
  String get reportTickMeals =>
      'Tick off meals in your diet plan to see your macros.';

  @override
  String get reportWeeklyProgress => 'Weekly progress';

  @override
  String get reportFull => 'Full report';

  @override
  String get reportThisWeek => 'This week';

  @override
  String get reportLastWeek => 'Last week';

  @override
  String get waterTitle => 'Water';

  @override
  String get waterDailyGoal => 'Daily water goal';

  @override
  String waterRecommended(String amount) {
    return 'Recommended for your weight: $amount';
  }

  @override
  String get waterAdd => 'Add water';

  @override
  String get waterEditGoal => 'Edit goal';

  @override
  String get waterReminders => 'Hydration reminders';

  @override
  String get waterRemindersHint =>
      'Every 2 hours, 10 AM to 6 PM. Paused for the day once you hit your goal.';

  @override
  String get waterCustom => 'Custom';

  @override
  String get waterNothingLogged => 'Nothing logged yet. Tap an amount above.';

  @override
  String get waterSwipeHint => 'Swipe left to remove an entry.';

  @override
  String get waterLoadFailed => 'Couldn\'t load your water log.';

  @override
  String waterTodayLabel(String total, String goal) {
    return 'Water today: $total of $goal';
  }

  @override
  String get waterGoalReached => 'Goal reached 🎉';

  @override
  String waterToGo(String amount) {
    return '$amount to go';
  }

  @override
  String waterEnterBetween(int min, int max) {
    return 'Enter between $min and $max ml';
  }

  @override
  String get waterAmount => 'Amount';

  @override
  String waterGoalMet(int count) {
    return 'Goal met $count/7';
  }

  @override
  String get waterInvalidAmount => 'Enter an amount between 1 and 3000 ml.';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifEmpty => 'No Notifications Yet';

  @override
  String get notifSettingsTitle => 'Notification Settings';

  @override
  String get notifDisabled =>
      'Notifications are turned off for BeFit. Enable them in your device settings to receive reminders.';

  @override
  String get notifReminders => 'Reminders';

  @override
  String get notifWorkout => 'Workout Reminder';

  @override
  String get notifWorkoutHint => 'Daily workout motivation';

  @override
  String get notifWater => 'Water Reminder';

  @override
  String get notifWaterHint =>
      'Every 2 hours, 10 AM–6 PM. Paused once you hit your goal';

  @override
  String get notifMeal => 'Meal Reminder';

  @override
  String get notifMealHint => 'Track your daily meals';

  @override
  String get notifStreak => 'Streak Reminder';

  @override
  String get notifStreakHint => 'Keep your streak alive';

  @override
  String get notifReminderTime => 'Reminder Time';

  @override
  String get notifWorkoutTime => 'Workout Reminder Time';

  @override
  String get reminderWorkoutTitle => '💪 Time to move';

  @override
  String get reminderWorkoutBody =>
      'Your workout is waiting. A short session still counts!';

  @override
  String get reminderMealTitle => '🍽️ Log your meal';

  @override
  String get reminderMealBody =>
      'Tick off your meal to stay on track with your plan.';

  @override
  String get reminderWaterTitle => '💧 Hydration check';

  @override
  String get reminderWaterBody =>
      'Time for a glass of water. Tap to log it in BeFit.';

  @override
  String get reminderStreakTitle => '🔥 Streak at risk';

  @override
  String get reminderStreakBody =>
      'Log a workout or meal today to keep your streak alive.';

  @override
  String get coachTitle => 'AI Coach';

  @override
  String get coachSuggest1 => 'How am I doing this week?';

  @override
  String get coachSuggest2 => 'How can I hit my protein goal?';

  @override
  String get coachSuggest3 => 'Plan a 30-minute workout for today';

  @override
  String get coachSuggest4 => 'What should I eat after a workout?';

  @override
  String get coachRemoveModelTitle => 'Remove on-device model?';

  @override
  String get coachRemoveModelBody =>
      'This frees up storage. The coach will use cloud AI until you download the model again.';

  @override
  String get coachMore => 'More';

  @override
  String get coachClearChat => 'Clear chat';

  @override
  String get coachRemoveModel => 'Remove on-device model';

  @override
  String get coachIntro => 'Ask me anything about training, food or recovery.';

  @override
  String get coachIntroHint =>
      'I use your profile, today\'s activity and this week\'s report to tailor answers. General guidance, not medical advice.';

  @override
  String get coachAskHint => 'Ask your coach…';

  @override
  String get coachStop => 'Stop';

  @override
  String get coachSend => 'Send';

  @override
  String get coachOnDevice => 'On-device';

  @override
  String get coachCloud => 'Cloud';

  @override
  String get coachThinking => 'Thinking…';

  @override
  String coachDownloading(int progress) {
    return 'Downloading Gemma… $progress%';
  }

  @override
  String get coachRunOffline => 'Run the coach offline';

  @override
  String coachDownloadHint(String size) {
    return 'Download Gemma once ($size, Wi-Fi recommended). Answers are then generated on your phone, and your data never leaves it.';
  }

  @override
  String get coachDownload => 'Download';

  @override
  String get coachUsingCloud => 'Using cloud AI';

  @override
  String get coachLowMemory =>
      'This phone doesn\'t have enough memory for the on-device model, so answers come from Gemini over the internet.';

  @override
  String get coachModelSetupFailed =>
      'The model downloaded but couldn\'t be set up.';

  @override
  String get coachDownloadFailed =>
      'Download failed. Check your connection and try again.';

  @override
  String get coachOffline =>
      'You\'re offline. Download the on-device model to chat without internet.';

  @override
  String get coachError => 'Couldn\'t reach the coach right now. Try again.';

  @override
  String get coachEmpty =>
      'I couldn\'t come up with an answer. Try rephrasing your question.';

  @override
  String get coachStopped => 'Stopped.';

  @override
  String get coachEmergency =>
      'This could be serious, so please don\'t rely on an app for it. Stop exercising and contact a doctor or your local emergency number (112 in India) right away. If you are thinking about harming yourself, please reach out to someone you trust or a helpline such as Tele-MANAS (14416) now.';

  @override
  String get coachProfessional =>
      'That\'s a topic where advice needs to fit your health history, so I can\'t give guidance on it. Please talk to a doctor or a registered dietitian. I can still help with general training, steps, water and balanced eating.';

  @override
  String get a11yProfile => 'Profile';

  @override
  String get a11yLearnMore => 'Learn more';

  @override
  String get bodyShowBack => 'Show back view';

  @override
  String get bodyShowFront => 'Show front view';

  @override
  String get bodyExcludeHint => 'exclude from workout search';

  @override
  String get bodyExcluded => 'Excluded';

  @override
  String waterOfGoal(String goal) {
    return 'of $goal';
  }

  @override
  String get a11yTorch => 'Flashlight';

  @override
  String get a11yClearSearch => 'Clear search';

  @override
  String get metricWeek => 'Week';

  @override
  String get metricMonth => 'Month';

  @override
  String a11yOverallHealth(
    String percent,
    int steps,
    int calories,
    int minutes,
  ) {
    return 'Overall health $percent%: $steps steps, $calories kcal, $minutes active minutes';
  }
}
