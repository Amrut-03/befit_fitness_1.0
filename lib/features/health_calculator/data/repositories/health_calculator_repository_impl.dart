import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_reposittory.dart';

import '../../domain/entities/calculator_result_entity.dart';

import '../datasources/local/health_calculator_local_datasource.dart';

import '../models/calculator_result_model.dart';

class HealthCalculatorRepositoryImpl implements HealthCalculatorRepository {
  final HealthCalculatorLocalDatasource localDatasource;

  HealthCalculatorRepositoryImpl(this.localDatasource);

  @override
  Future<void> saveResult(CalculatorResultEntity result) async {
    final model = CalculatorResultModel(
      value: result.value,

      title: result.title,

      description: result.description,
    );

    await localDatasource.saveResult(model);
  }

  @override
  Future<CalculatorResultEntity?> getLastResult() async {
    return await localDatasource.getLastResult();
  }
}
