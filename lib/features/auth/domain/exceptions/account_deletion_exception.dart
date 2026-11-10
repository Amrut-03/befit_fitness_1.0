/// Why deleting the account failed. The presentation layer maps each reason
/// to a user-facing message.
enum AccountDeletionFailure {
  /// The user backed out of the Google re-authentication prompt.
  cancelled,

  /// Firebase still considers the session too old. The user should sign out,
  /// sign back in, and retry.
  requiresRecentLogin,

  /// The user picked a different Google account than the one signed in.
  wrongAccount,

  /// No network, or Firestore/Auth couldn't be reached.
  network,

  notSignedIn,
  unknown,
}

class AccountDeletionException implements Exception {
  final AccountDeletionFailure reason;
  final Object? cause;

  const AccountDeletionException(this.reason, [this.cause]);

  @override
  String toString() => 'AccountDeletionException($reason, $cause)';
}
