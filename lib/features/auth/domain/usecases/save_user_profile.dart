import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class SaveUserProfile {
  final AuthRepository repository;

  SaveUserProfile(this.repository);

  Future<void> call(UserEntity user) async {
    await repository.saveUserProfile(user);
  }
}
