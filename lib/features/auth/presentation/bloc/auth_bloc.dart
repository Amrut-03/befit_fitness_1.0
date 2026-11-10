import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/exceptions/account_deletion_exception.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/sign_in_as_guest.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInAsGuest signInAsGuest;
  final SignOut signOut;
  final DeleteAccount deleteAccount;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInAsGuest,
    required this.signOut,
    required this.deleteAccount,
  }) : super(const AuthInitial()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthGuestSignInRequested>(_onGuestSignIn);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthDeleteRequested>(_onDeleteAccount);
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final user = await signInWithGoogle();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthError('Google sign-in failed. Please try again.'));
    }
  }

  Future<void> _onGuestSignIn(
    AuthGuestSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final user = await signInAsGuest();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthError('Guest sign in failed'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      await signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError('Logout failed'));
    }
  }

  Future<void> _onDeleteAccount(
    AuthDeleteRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    try {
      emit(const AuthDeleting());
      await deleteAccount();
      emit(const AuthAccountDeleted());
    } catch (e) {
      final reason = e is AccountDeletionException
          ? e.reason
          : AccountDeletionFailure.unknown;
      emit(AuthError(deletionErrorMessage(reason)));
      // The user is still signed in, so restore the previous state.
      if (previous is AuthAuthenticated) emit(previous);
    }
  }

  static String deletionErrorMessage(AccountDeletionFailure reason) {
    switch (reason) {
      case AccountDeletionFailure.cancelled:
        return 'Account deletion cancelled.';
      case AccountDeletionFailure.requiresRecentLogin:
        return 'For your security, please log out, sign in again, and then '
            'delete your account.';
      case AccountDeletionFailure.wrongAccount:
        return 'Please choose the Google account you signed in with.';
      case AccountDeletionFailure.network:
        return 'No internet connection. Nothing was deleted. Please try again.';
      case AccountDeletionFailure.notSignedIn:
        return 'You are not signed in.';
      case AccountDeletionFailure.unknown:
        return 'Could not delete your account. Please try again.';
    }
  }
}
