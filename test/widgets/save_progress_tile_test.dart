import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/profile/presentation/widgets/save_progress_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'pump_app.dart';

class _Auth extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class _Profile extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class _Home extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  late _Auth auth;
  late _Profile profile;
  late _Home home;

  setUpAll(() {
    registerFallbackValue(const AuthLogoutRequested());
    registerFallbackValue(LoadProfileEvent());
    registerFallbackValue(RefreshHomeDashboard());
  });

  setUp(() {
    auth = _Auth();
    profile = _Profile();
    home = _Home();
    when(() => profile.state).thenReturn(ProfileInitial());
    when(() => home.state).thenReturn(HomeInitial());
  });

  Future<void> pump(WidgetTester tester, {required bool isGuest}) async {
    await tester.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: auth),
          BlocProvider<ProfileBloc>.value(value: profile),
          BlocProvider<HomeBloc>.value(value: home),
        ],
        child: Scaffold(body: SaveProgressTile(isGuest: () async => isGuest)),
      ),
    );
    await tester.pump();
  }

  testWidgets('hidden for Google users', (tester) async {
    when(() => auth.state).thenReturn(const AuthInitial());
    await pump(tester, isGuest: false);

    expect(find.text('Save your progress'), findsNothing);
  });

  testWidgets('guests can tap it to link Google', (tester) async {
    when(() => auth.state).thenReturn(const AuthInitial());
    await pump(tester, isGuest: true);

    await tester.tap(find.text('Save your progress'));
    verify(() => auth.add(const AuthLinkGoogleRequested())).called(1);
  });

  testWidgets('after linking it disappears and reloads the profile', (
    tester,
  ) async {
    whenListen(
      auth,
      Stream<AuthState>.fromIterable(const [
        AuthLinking(),
        AuthAuthenticated(
          UserEntity(uid: 'u', isGuest: false, email: 'a@example.com'),
        ),
      ]),
      initialState: const AuthInitial(),
    );
    await pump(tester, isGuest: true);
    await tester.pump();

    expect(find.text('Save your progress'), findsNothing);
    expect(find.text('Progress saved to a@example.com.'), findsOneWidget);
    verify(() => profile.add(any(that: isA<LoadProfileEvent>()))).called(1);
    verify(() => home.add(any(that: isA<RefreshHomeDashboard>()))).called(1);
  });
}
