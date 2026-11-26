import '../entities/calculator_result_entity.dart';

abstract class HealthCalculatorRepository {
  Future<void> saveResult(CalculatorResultEntity result);

  Future<CalculatorResultEntity?> getLastResult();
}
