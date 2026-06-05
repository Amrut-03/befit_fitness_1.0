import '../entities/profile_entity.dart';

import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<void> call(ProfileEntity profile) async {
    await repository.updateProfile(profile);
  }
}
