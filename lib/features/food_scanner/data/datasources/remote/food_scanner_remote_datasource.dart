import 'dart:convert';
import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/features/food_scanner/data/models/food_scanner_model.dart';
import 'package:http/http.dart' as http;

class FoodScannerRemoteDataSource {
  Future<FoodItemModel?> getFoodByBarcode(String barcode) async {
    final url = Uri.parse(
      '${AppConfig.openFoodFactsBaseUrl}/api/v0/product/$barcode.json',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] != 1) {
        return null;
      }
      return FoodItemModel.fromJson(data);
    }

    throw Exception('Failed to fetch product');
  }
}
