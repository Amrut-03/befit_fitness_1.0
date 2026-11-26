import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Converts the signed-in guest into a Google account, keeping the same uid
/// and therefore all of the guest's data.
class LinkGuestWithGoogle {
  final AuthRepository repository;

  LinkGuestWithGoogle(this.repository);

  Future<UserEntity> call() => repository.linkGuestWithGoogle();
}
