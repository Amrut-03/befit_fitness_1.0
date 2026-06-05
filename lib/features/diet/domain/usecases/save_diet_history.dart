import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class SaveDietHistory {
  final DietRepository repository;

  SaveDietHistory(this.repository);

  Future<void> call(DietHistoryEntity history) {
    return repository.saveDietHistory(history);
  }
}
