import 'package:hive/hive.dart';

/// Wipes every Hive box that holds per-user data.
class UserDataLocalDataSource {
  final List<Box<dynamic>> boxes;

  UserDataLocalDataSource(this.boxes);

  Future<void> clearAll() async {
    await Future.wait(boxes.map((box) => box.clear()));
  }
}
