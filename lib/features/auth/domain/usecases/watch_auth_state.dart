import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository repository;

  WatchAuthState(this.repository);

  Stream<UserEntity?> call() {
    return repository.watchAuthState();
  }
}
