import 'package:fitness_app/features/diet/domain/entities/macro_entity.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class GetTodayMacros {
  final DietRepository repository;

  GetTodayMacros(this.repository);

  Stream<MacroEntity> call() {
    return repository.getTodayMacros();
  }
}
