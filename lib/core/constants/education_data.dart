import '../models/education_info.dart';

class EducationData {
  static const overallHealth = EducationInfo(
    emoji: "❤️",

    title: "Overall Health Score",

    description:
        "This score combines your daily activity metrics including steps, calories burned, and movement minutes.",

    whyImportant:
        "A higher score means you're consistently achieving your daily fitness goals and maintaining an active lifestyle.",

    tips: [
      "Walk regularly throughout the day",

      "Aim for your daily step target",

      "Increase active movement minutes",

      "Stay consistent every day",

      "Combine cardio and strength training",
    ],
  );

  static const bodyChart = EducationInfo(
    emoji: "💪",

    title: "Interactive Body Chart",

    description:
        "The Body Chart helps you visually select muscle groups and discover workouts tailored to those muscles.",

    whyImportant:
        "Targeting specific muscle groups helps you train more effectively, maintain balance in your physique, and avoid neglecting important muscles.",

    tips: [
      "Tap a muscle to select it",

      "Select multiple muscles to focus on a workout area",

      "Use Front and Back views to access all muscle groups",

      "Press 'Search Workouts' to find exercises for selected muscles",

      "Long press a muscle to temporarily disable it",

      "Train all major muscle groups throughout the week",
    ],
  );
}
