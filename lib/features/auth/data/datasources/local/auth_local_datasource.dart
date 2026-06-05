import 'dart:convert';
import 'package:fitness_app/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSource(this.storage);

  static const String _userKey = ' cached_user';

  Future<void> cacheUser(UserModel user) async {
    final jsonString = jsonEncode(user.toMap());

    await storage.write(key: _userKey, value: jsonString);
  }

  Future<UserModel?> getCachedUser() async {
    final data = await storage.read(key: _userKey);

    if (data == null) return null;

    final map = jsonDecode(data) as Map<String, dynamic>;

    return UserModel.fromMap(map);
  }

  Future<void> clearCache() async {
    await storage.delete(key: _userKey);
  }
}
