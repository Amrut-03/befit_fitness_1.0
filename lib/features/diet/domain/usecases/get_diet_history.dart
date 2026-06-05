import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class GetDietHistory {
  final DietRepository repository;

  GetDietHistory(this.repository);

  Stream<List<DietHistoryEntity>> call() {
    return repository.getDietHistory();
  }
}
