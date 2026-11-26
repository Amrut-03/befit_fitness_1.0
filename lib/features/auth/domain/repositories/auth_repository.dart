import 'package:fitness_app/features/auth/domain/exceptions/account_link_exception.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInAsGuest();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> watchAuthState();
  Future<void> signOut();
  Future<void> deleteAccount();

  /// Throws [AccountLinkException] on failure.
  Future<UserEntity> linkGuestWithGoogle();
}
