import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'pump_app.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late _MockAuthBloc bloc;

  setUpAll(() => registerFallbackValue(const AuthLogoutRequested()));

  setUp(() => bloc = _MockAuthBloc());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpApp(
      BlocProvider<AuthBloc>.value(value: bloc, child: const LoginPage()),
    );
    await tester.pumpForLoaders();
  }

  testWidgets('shows both sign-in options', (tester) async {
    when(() => bloc.state).thenReturn(const AuthInitial());
    await pump(tester);

    expect(find.text('Welcome to BeFit'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });

  testWidgets('tapping the buttons dispatches the sign-in events', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(const AuthInitial());
    await pump(tester);

    await tester.tap(find.text('Continue with Google'));
    await tester.tap(find.text('Continue as Guest'));

    verify(() => bloc.add(const AuthGoogleSignInRequested())).called(1);
    verify(() => bloc.add(const AuthGuestSignInRequested())).called(1);
  });

  testWidgets('loading state shows loaders and ignores taps', (tester) async {
    when(() => bloc.state).thenReturn(const AuthLoading());
    await pump(tester);

    expect(find.byType(AppLoader), findsNWidgets(2));
    expect(find.text('Continue with Google'), findsNothing);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('an auth error is shown in a snackbar', (tester) async {
    whenListen(
      bloc,
      Stream<AuthState>.value(const AuthError('Google sign-in failed.')),
      initialState: const AuthInitial(),
    );
    await pump(tester);

    expect(find.text('Google sign-in failed.'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
