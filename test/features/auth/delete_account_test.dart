import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/local/user_data_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/user_data_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/exceptions/account_deletion_exception.dart';
import 'package:fitness_app/features/auth/domain/usecases/delete_account.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every call so tests can assert ordering.
final calls = <String>[];

class _Remote extends Fake implements AuthRemoteDataSource {
  String? uid = 'alice';
  Object? reauthError;
  Object? deleteUserError;

  @override
  String? get currentUid => uid;

  @override
  Future<void> reauthenticate() async {
    calls.add('reauth');
    if (reauthError != null) throw reauthError!;
  }

  @override
  Future<void> deleteCurrentUser() async {
    calls.add('deleteUser');
    if (deleteUserError != null) throw deleteUserError!;
  }
}

class _UserDataRemote extends Fake implements UserDataRemoteDataSource {
  Object? error;

  @override
  Future<void> deleteAllUserData(String uid) async {
    calls.add('deleteData:$uid');
    if (error != null) throw error!;
  }
}

class _UserDataLocal extends Fake implements UserDataLocalDataSource {
  @override
  Future<void> clearAll() async => calls.add('clearBoxes');
}

class _AuthLocal extends Fake implements AuthLocalDataSource {
  @override
  Future<void> clearCache() async => calls.add('clearCache');
}

void main() {
  late _Remote remote;
  late _UserDataRemote userDataRemote;
  late AuthRepositoryImpl repo;

  setUp(() {
    calls.clear();
    remote = _Remote();
    userDataRemote = _UserDataRemote();
    repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: _AuthLocal(),
      userDataRemoteDataSource: userDataRemote,
      userDataLocalDataSource: _UserDataLocal(),
    );
  });

  Matcher failsWith(AccountDeletionFailure reason) => throwsA(
    isA<AccountDeletionException>().having((e) => e.reason, 'reason', reason),
  );

  group('AuthRepositoryImpl.deleteAccount', () {
    test('reauth → delete data → delete user → clear local, in order', () async {
      await repo.deleteAccount();
      expect(calls, [
        'reauth',
        'deleteData:alice',
        'deleteUser',
        'clearBoxes',
        'clearCache',
      ]);
    });

    test('not signed in: nothing happens', () async {
      remote.uid = null;
      await expectLater(
        repo.deleteAccount(),
        failsWith(AccountDeletionFailure.notSignedIn),
      );
      expect(calls, isEmpty);
    });

    test('cancelled Google prompt: no data deleted', () async {
      remote.reauthError = const AccountDeletionException(
        AccountDeletionFailure.cancelled,
      );
      await expectLater(
        repo.deleteAccount(),
        failsWith(AccountDeletionFailure.cancelled),
      );
      expect(calls, ['reauth']);
    });

    test('google_sign_in cancel PlatformException maps to cancelled', () async {
      remote.reauthError = PlatformException(code: 'sign_in_canceled');
      await expectLater(
        repo.deleteAccount(),
        failsWith(AccountDeletionFailure.cancelled),
      );
    });

    test('wrong Google account maps to wrongAccount', () async {
      remote.reauthError = FirebaseAuthException(code: 'user-mismatch');
      await expectLater(
        repo.deleteAccount(),
        failsWith(AccountDeletionFailure.wrongAccount),
      );
      expect(calls, ['reauth']);
    });

    test('offline Firestore: user kept, local data kept', () async {
      userDataRemote.error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
      await expectLater(
        repo.deleteAccount(),
        failsWith(AccountDeletionFailure.network),
      );
      expect(calls, ['reauth', 'deleteData:alice']);
    });

    test('requires-recent-login on user.delete is surfaced, local kept', () async {
      remote.deleteUserError = FirebaseAuthException(
        code: 'requires-recent-login',
      );
      await expectLater(
        repo.deleteAccount(),
        failsWith(AccountDeletionFailure.requiresRecentLogin),
      );
      expect(calls, isNot(contains('clearBoxes')));
    });
  });

  group('AuthBloc AuthDeleteRequested', () {
    AuthBloc buildBloc() => AuthBloc(
      signInWithGoogle: SignInWithGoogle(repo),
      signInAsGuest: SignInAsGuest(repo),
      getCurrentUser: GetCurrentUser(repo),
      watchAuthState: WatchAuthState(repo),
      signOut: SignOut(repo),
      deleteAccount: DeleteAccount(repo),
    );

    test('success emits deleting → deleted', () async {
      final bloc = buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthDeleteRequested());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      await sub.cancel();

      expect(states, [const AuthDeleting(), const AuthAccountDeleted()]);
    });

    test('failure emits an error message, then restores authenticated', () async {
      remote.reauthError = const AccountDeletionException(
        AccountDeletionFailure.network,
      );
      const user = UserEntity(uid: 'alice', isGuest: false);
      final bloc = buildBloc()..emit(const AuthAuthenticated(user));
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthDeleteRequested());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      await sub.cancel();

      expect(states, [
        const AuthDeleting(),
        AuthError(
          AuthBloc.deletionErrorMessage(AccountDeletionFailure.network),
        ),
        const AuthAuthenticated(user),
      ]);
    });
  });
}
