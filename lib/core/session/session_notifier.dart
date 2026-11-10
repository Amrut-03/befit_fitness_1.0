import 'dart:async';

import 'package:flutter/foundation.dart';

/// Where the current user is in the app lifecycle.
enum SessionStatus {
  /// Waiting for Firebase Auth or the profile check.
  unknown,

  signedOut,

  /// Signed in, but onboarding (profile) isn't complete.
  needsProfile,

  /// Signed in with a completed profile.
  ready,

  /// The profile check failed (usually offline with no cached doc).
  error,
}

/// The single source of truth for "who is signed in and have they finished
/// onboarding". The router redirects from it (as its `refreshListenable`),
/// and user-scoped blocs are keyed by [uid].
///
/// The profile check runs once per sign-in and is cached in memory, so
/// navigation never touches Firestore.
class SessionNotifier extends ChangeNotifier {
  SessionNotifier({
    required Stream<String?> uidChanges,
    required Future<bool> Function() isProfileCompleted,
  }) : _isProfileCompleted = isProfileCompleted {
    _subscription = uidChanges.listen(_onUidChanged);
  }

  final Future<bool> Function() _isProfileCompleted;
  late final StreamSubscription<String?> _subscription;

  SessionStatus _status = SessionStatus.unknown;
  String? _uid;

  /// Incremented on every user change so stale profile checks are dropped.
  int _generation = 0;

  SessionStatus get status => _status;
  String? get uid => _uid;

  void _onUidChanged(String? uid) {
    if (uid == _uid && _status != SessionStatus.unknown) return;
    _uid = uid;
    _generation++;

    if (uid == null) {
      _set(SessionStatus.signedOut);
    } else {
      _checkProfile();
    }
  }

  Future<void> _checkProfile() async {
    final generation = _generation;
    _set(SessionStatus.unknown);

    try {
      final completed = await _isProfileCompleted();
      if (generation != _generation) return;
      _set(completed ? SessionStatus.ready : SessionStatus.needsProfile);
    } catch (_) {
      if (generation != _generation) return;
      _set(SessionStatus.error);
    }
  }

  /// Re-runs the profile check after an [SessionStatus.error].
  Future<void> retry() async {
    if (_uid != null) await _checkProfile();
  }

  /// Called when onboarding saves the profile.
  void markProfileCompleted() {
    if (_uid != null) _set(SessionStatus.ready);
  }

  void _set(SessionStatus status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
