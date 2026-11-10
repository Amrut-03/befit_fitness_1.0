import 'package:fitness_app/features/notifications/data/models/notification_model.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Opens every Hive box once at startup and registers it in get_it.
///
/// Untyped boxes are registered by name (`sl<Box>(instanceName: ...)`).
/// The notifications box is typed (`Box<NotificationModel>`) and is opened in
/// `main()` after its adapter is registered.
abstract final class StorageModule {
  static const diet = 'diet_box';
  static const food = 'food_box';
  static const healthMetrics = 'health_metrics_box';
  static const calculator = 'calculator_box';
  static const profile = 'profile_box';
  static const aiInsights = 'ai_insights_box';
  static const notificationSettings = 'notification_settings';
  static const notifications = 'notifications';

  /// Boxes that hold per-user data, cleared on logout and account deletion.
  static const userScoped = [
    diet,
    food,
    healthMetrics,
    calculator,
    profile,
    aiInsights,
  ];

  static const _all = [...userScoped, notificationSettings];

  static Future<void> register(GetIt sl) async {
    for (final name in _all) {
      final box = await Hive.openBox(name);
      sl.registerSingleton<Box>(box, instanceName: name);
    }
    sl.registerSingleton<Box<NotificationModel>>(
      Hive.box<NotificationModel>(notifications),
    );
  }
}
