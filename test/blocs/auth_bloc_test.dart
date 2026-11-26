import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/usecases/delete_account.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGoogle extends Mock implements SignInWithGoogle {}

class _MockGuest extends Mock implements SignInAsGuest {}

class _MockSignOut extends Mock implements SignOut {}

class _MockDelete extends Mock implements DeleteAccount {}

void main() {
  late _MockGoogle google;
  late _MockGuest guest;
  late _MockSignOut signOut;

  const user = UserEntity(uid: 'u1', isGuest: false);
  const guestUser = UserEntity(uid: 'g1', isGuest: true);

  setUp(() {
    google = _MockGoogle();
    guest = _MockGuest();
    signOut = _MockSignOut();
  });

  AuthBloc build() => AuthBloc(
    signInWithGoogle: google,
    signInAsGuest: guest,
    signOut: signOut,
    deleteAccount: _MockDelete(),
  );

  group('Google sign-in', () {
    blocTest<AuthBloc, AuthState>(
      'success → loading, authenticated',
      setUp: () => when(() => google()).thenAnswer((_) async => user),
      build: build,
      act: (b) => b.add(const AuthGoogleSignInRequested()),
      expect: () => const [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'user closes the picker → loading, unauthenticated',
      setUp: () => when(() => google()).thenAnswer((_) async => null),
      build: build,
      act: (b) => b.add(const AuthGoogleSignInRequested()),
      expect: () => const [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'failure → loading, friendly error',
      setUp: () => when(() => google()).thenThrow(Exception('raw details')),
      build: build,
      act: (b) => b.add(const AuthGoogleSignInRequested()),
      expect: () => const [
        AuthLoading(),
        AuthError('Google sign-in failed. Please try again.'),
      ],
    );
  });

  blocTest<AuthBloc, AuthState>(
    'guest sign-in → loading, authenticated guest',
    setUp: () => when(() => guest()).thenAnswer((_) async => guestUser),
    build: build,
    act: (b) => b.add(const AuthGuestSignInRequested()),
    expect: () => const [AuthLoading(), AuthAuthenticated(guestUser)],
  );

  group('logout', () {
    blocTest<AuthBloc, AuthState>(
      'success → loading, unauthenticated',
      setUp: () => when(() => signOut()).thenAnswer((_) async {}),
      build: build,
      act: (b) => b.add(const AuthLogoutRequested()),
      expect: () => const [AuthLoading(), AuthUnauthenticated()],
      verify: (_) => verify(() => signOut()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'failure → loading, error',
      setUp: () => when(() => signOut()).thenThrow(Exception()),
      build: build,
      act: (b) => b.add(const AuthLogoutRequested()),
      expect: () => const [AuthLoading(), AuthError('Logout failed')],
    );
  });
}
