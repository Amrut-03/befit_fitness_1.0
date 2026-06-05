import 'package:hive/hive.dart';

import '../../models/calculator_result_model.dart';

abstract class HealthCalculatorLocalDatasource {
  Future<void> saveResult(CalculatorResultModel model);

  Future<CalculatorResultModel?> getLastResult();
}

class HealthCalculatorLocalDatasourceImpl
    implements HealthCalculatorLocalDatasource {
  final Box box;

  HealthCalculatorLocalDatasourceImpl(this.box);

  static const key = 'calculator_result';

  @override
  Future<void> saveResult(CalculatorResultModel model) async {
    await box.put(key, model.toJson());
  }

  @override
  Future<CalculatorResultModel?> getLastResult() async {
    final data = box.get(key);

    if (data == null) {
      return null;
    }

    return CalculatorResultModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }
}
