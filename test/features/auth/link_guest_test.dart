import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/local/user_data_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/user_data_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/models/user_model.dart';
import 'package:fitness_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/exceptions/account_link_exception.dart';
import 'package:fitness_app/features/auth/domain/usecases/delete_account.dart';
import 'package:fitness_app/features/auth/domain/usecases/link_guest_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Remote extends Mock implements AuthRemoteDataSource {}

class _Local extends Mock implements AuthLocalDataSource {}

class _UserDataLocal extends Mock implements UserDataLocalDataSource {}

class _Link extends Mock implements LinkGuestWithGoogle {}

class _Google extends Mock implements SignInWithGoogle {}

class _Guest extends Mock implements SignInAsGuest {}

class _SignOut extends Mock implements SignOut {}

class _Delete extends Mock implements DeleteAccount {}

void main() {
  final linkedUser = UserModel(
    uid: 'guest-uid',
    name: 'Amrut',
    email: 'amrut@example.com',
    isGuest: false,
    createdAt: DateTime(2026),
  );

  setUpAll(() => registerFallbackValue(linkedUser));

  group('AuthRepositoryImpl.linkGuestWithGoogle', () {
    late _Remote remote;
    late _Local local;
    late FakeFirebaseFirestore firestore;
    late AuthRepositoryImpl repo;

    setUp(() async {
      remote = _Remote();
      local = _Local();
      firestore = FakeFirebaseFirestore();
      when(() => local.cacheUser(any())).thenAnswer((_) async {});
      repo = AuthRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        userDataRemoteDataSource: UserDataRemoteDataSource(
          firestore: firestore,
        ),
        userDataLocalDataSource: _UserDataLocal(),
      );
      await firestore.doc('users/guest-uid').set({
        'goal': 'Build Muscle',
        'profileCompleted': true,
        'streak': 5,
      });
    });

    test('keeps the uid and existing profile, adds name and email', () async {
      when(
        () => remote.linkGuestWithGoogle(),
      ).thenAnswer((_) async => linkedUser);

      final user = await repo.linkGuestWithGoogle();

      expect(user.uid, 'guest-uid');
      expect(user.isGuest, isFalse);
      verify(() => local.cacheUser(linkedUser)).called(1);

      final doc = (await firestore.doc('users/guest-uid').get()).data()!;
      expect(doc['name'], 'Amrut');
      expect(doc['email'], 'amrut@example.com');
      // Guest progress is untouched.
      expect(doc['goal'], 'Build Muscle');
      expect(doc['profileCompleted'], isTrue);
      expect(doc['streak'], 5);
    });

    test('a closed Google picker maps to cancelled', () async {
      when(
        () => remote.linkGuestWithGoogle(),
      ).thenThrow(PlatformException(code: 'sign_in_canceled'));

      expect(
        repo.linkGuestWithGoogle,
        throwsA(
          isA<AccountLinkException>().having(
            (e) => e.reason,
            'reason',
            AccountLinkFailure.cancelled,
          ),
        ),
      );
    });

    test('typed link failures pass through unchanged', () async {
      when(
        () => remote.linkGuestWithGoogle(),
      ).thenThrow(const AccountLinkException(AccountLinkFailure.alreadyInUse));

      await expectLater(
        repo.linkGuestWithGoogle,
        throwsA(
          isA<AccountLinkException>().having(
            (e) => e.reason,
            'reason',
            AccountLinkFailure.alreadyInUse,
          ),
        ),
      );
      verifyNever(() => local.cacheUser(any()));
    });
  });

  group('AuthBloc AuthLinkGoogleRequested', () {
    late _Link link;
    const guest = UserEntity(uid: 'guest-uid', isGuest: true);

    setUp(() => link = _Link());

    AuthBloc build() => AuthBloc(
      signInWithGoogle: _Google(),
      signInAsGuest: _Guest(),
      signOut: _SignOut(),
      deleteAccount: _Delete(),
      linkGuestWithGoogle: link,
    );

    blocTest<AuthBloc, AuthState>(
      'success → linking, authenticated as a Google user',
      setUp: () => when(() => link()).thenAnswer((_) async => linkedUser),
      build: build,
      seed: () => const AuthAuthenticated(guest),
      act: (b) => b.add(const AuthLinkGoogleRequested()),
      expect: () => [const AuthLinking(), AuthAuthenticated(linkedUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'account already in use → error, then back to the guest state',
      setUp: () => when(
        () => link(),
      ).thenThrow(const AccountLinkException(AccountLinkFailure.alreadyInUse)),
      build: build,
      seed: () => const AuthAuthenticated(guest),
      act: (b) => b.add(const AuthLinkGoogleRequested()),
      expect: () => [
        const AuthLinking(),
        AuthError(AuthBloc.linkErrorMessage(AccountLinkFailure.alreadyInUse)),
        const AuthAuthenticated(guest),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'cancelling the picker shows no error',
      setUp: () => when(
        () => link(),
      ).thenThrow(const AccountLinkException(AccountLinkFailure.cancelled)),
      build: build,
      seed: () => const AuthAuthenticated(guest),
      act: (b) => b.add(const AuthLinkGoogleRequested()),
      expect: () => [const AuthLinking(), const AuthAuthenticated(guest)],
    );
  });
}
