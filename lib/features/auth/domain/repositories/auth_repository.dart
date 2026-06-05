import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInAsGuest();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> watchAuthState();
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> saveUserProfile(UserEntity user);
}
