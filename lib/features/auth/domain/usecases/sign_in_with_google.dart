import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<UserEntity?> call() async {
    return await repository.signInWithGoogle();
  }
}
