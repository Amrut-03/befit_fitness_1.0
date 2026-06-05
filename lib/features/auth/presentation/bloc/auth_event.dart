part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthGuestSignInRequested extends AuthEvent {
  const AuthGuestSignInRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthDeleteRequested extends AuthEvent {
  const AuthDeleteRequested();
}

class _AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  const _AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
