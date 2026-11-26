import 'package:fitness_app/core/l10n/l10n.dart';
import 'dart:async';

import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/exceptions/account_deletion_exception.dart';
import '../../domain/exceptions/account_link_exception.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/link_guest_with_google.dart';
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
  final LinkGuestWithGoogle? linkGuestWithGoogle;
  final AppAnalytics analytics;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInAsGuest,
    required this.signOut,
    required this.deleteAccount,
    this.linkGuestWithGoogle,
    this.analytics = const NoopAnalytics(),
  }) : super(const AuthInitial()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthGuestSignInRequested>(_onGuestSignIn);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthDeleteRequested>(_onDeleteAccount);
    on<AuthLinkGoogleRequested>(_onLinkGoogle);
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
        unawaited(analytics.logLogin(method: 'google'));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(AppLocale.l10n.authGoogleFailed));
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
        unawaited(analytics.logLogin(method: 'guest'));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(AppLocale.l10n.authGuestFailed));
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
      emit(AuthError(AppLocale.l10n.authLogoutFailed));
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

  Future<void> _onLinkGoogle(
    AuthLinkGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    final link = linkGuestWithGoogle;
    if (link == null) return;

    final previous = state;
    try {
      emit(const AuthLinking());
      final user = await link();
      emit(AuthAuthenticated(user));
      unawaited(analytics.logLogin(method: 'google_link'));
    } catch (e) {
      final reason = e is AccountLinkException
          ? e.reason
          : AccountLinkFailure.unknown;
      if (reason == AccountLinkFailure.cancelled) {
        emit(previous);
        return;
      }
      emit(AuthError(linkErrorMessage(reason)));
      // Still signed in as the same guest.
      emit(previous);
    }
  }

  static String linkErrorMessage(AccountLinkFailure reason) {
    final l10n = AppLocale.l10n;
    return switch (reason) {
      AccountLinkFailure.alreadyInUse => l10n.linkAlreadyInUse,
      AccountLinkFailure.network => l10n.linkNetwork,
      AccountLinkFailure.notGuest => l10n.linkNotGuest,
      AccountLinkFailure.cancelled ||
      AccountLinkFailure.unknown => l10n.linkFailed,
    };
  }

  static String deletionErrorMessage(AccountDeletionFailure reason) {
    final l10n = AppLocale.l10n;
    return switch (reason) {
      AccountDeletionFailure.cancelled => l10n.deleteCancelled,
      AccountDeletionFailure.requiresRecentLogin => l10n.deleteRecentLogin,
      AccountDeletionFailure.wrongAccount => l10n.deleteWrongAccount,
      AccountDeletionFailure.network => l10n.deleteNetwork,
      AccountDeletionFailure.notSignedIn => l10n.deleteNotSignedIn,
      AccountDeletionFailure.unknown => l10n.deleteFailed,
    };
  }
}
