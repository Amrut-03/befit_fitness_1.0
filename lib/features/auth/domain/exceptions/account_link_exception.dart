/// Why upgrading a guest to a Google account failed.
enum AccountLinkFailure {
  /// The user closed the Google account picker.
  cancelled,

  /// That Google account already has its own BeFit account, so it can't be
  /// attached to this guest.
  alreadyInUse,

  /// The current user isn't a guest (or isn't signed in).
  notGuest,

  network,
  unknown,
}

class AccountLinkException implements Exception {
  final AccountLinkFailure reason;
  final Object? cause;

  const AccountLinkException(this.reason, [this.cause]);

  @override
  String toString() => 'AccountLinkException($reason, $cause)';
}
