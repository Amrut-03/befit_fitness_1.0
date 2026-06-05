import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccount {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  Future<void> call() async {
    await repository.deleteAccount();
  }
}
