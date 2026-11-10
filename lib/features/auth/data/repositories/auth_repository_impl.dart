import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/local/user_data_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/user_data_remote_datasource.dart';
import 'package:fitness_app/features/auth/domain/exceptions/account_deletion_exception.dart';
import 'package:flutter/services.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserDataRemoteDataSource userDataRemoteDataSource;
  final UserDataLocalDataSource userDataLocalDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userDataRemoteDataSource,
    required this.userDataLocalDataSource,
  });

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final user = await remoteDataSource.signInWithGoogle();

    if (user != null) {
      await localDataSource.cacheUser(user);
    }

    return user;
  }

  @override
  Future<UserEntity?> signInAsGuest() async {
    final user = await remoteDataSource.signInAsGuest();

    if (user != null) {
      await localDataSource.cacheUser(user);
    }

    return user;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final remoteUser = await remoteDataSource.getCurrentUser();

    if (remoteUser != null) {
      await localDataSource.cacheUser(remoteUser);
      return remoteUser;
    }

    return await localDataSource.getCachedUser();
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return remoteDataSource.watchAuthState();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearCache();
  }

  /// Order matters:
  /// 1. Re-authenticate first. It's the step most likely to fail (cancel,
  ///    offline), and nothing has been deleted yet if it does.
  /// 2. Delete Firestore data while the user still exists. The security
  ///    rules require `request.auth.uid == uid`.
  /// 3. Delete the Auth user and revoke Google access.
  /// 4. Clear local storage only after the remote steps succeed.
  @override
  Future<void> deleteAccount() async {
    try {
      final uid = remoteDataSource.currentUid;
      if (uid == null) {
        throw const AccountDeletionException(
          AccountDeletionFailure.notSignedIn,
        );
      }

      await remoteDataSource.reauthenticate();
      await userDataRemoteDataSource.deleteAllUserData(uid);
      await remoteDataSource.deleteCurrentUser();

      await userDataLocalDataSource.clearAll();
      await localDataSource.clearCache();
    } on AccountDeletionException {
      rethrow;
    } catch (e) {
      throw AccountDeletionException(_mapDeletionError(e), e);
    }
  }

  static AccountDeletionFailure _mapDeletionError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'requires-recent-login':
          return AccountDeletionFailure.requiresRecentLogin;
        case 'user-mismatch':
          return AccountDeletionFailure.wrongAccount;
        case 'network-request-failed':
          return AccountDeletionFailure.network;
      }
      return AccountDeletionFailure.unknown;
    }
    if (e is FirebaseException) {
      return e.code == 'unavailable'
          ? AccountDeletionFailure.network
          : AccountDeletionFailure.unknown;
    }
    if (e is PlatformException) {
      // google_sign_in error codes.
      switch (e.code) {
        case 'sign_in_canceled':
          return AccountDeletionFailure.cancelled;
        case 'network_error':
          return AccountDeletionFailure.network;
      }
    }
    return AccountDeletionFailure.unknown;
  }
}
