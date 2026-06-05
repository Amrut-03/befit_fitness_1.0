import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_as_guest.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInAsGuest signInAsGuest;
  final GetCurrentUser getCurrentUser;
  final WatchAuthState watchAuthState;
  final SignOut signOut;
  final DeleteAccount deleteAccount;

  StreamSubscription<UserEntity?>? _authSubscription;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInAsGuest,
    required this.getCurrentUser,
    required this.watchAuthState,
    required this.signOut,
    required this.deleteAccount,
  }) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthGuestSignInRequested>(_onGuestSignIn);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthDeleteRequested>(_onDeleteAccount);
    on<_AuthUserChanged>(_onUserChanged);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    print("AuthStarted called");

    emit(AuthLoading());

    try {
      final user = await getCurrentUser();

      print("User result: $user");

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print("Auth error: $e");
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = await signInWithGoogle();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      print("GOOGLE SIGN IN ERROR: ${e.toString()}");
      print(stackTrace);

      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGuestSignIn(
    AuthGuestSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = await signInAsGuest();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Guest sign in failed'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed'));
    }
  }

  Future<void> _onDeleteAccount(
    AuthDeleteRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await deleteAccount();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Delete account failed'));
    }
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
