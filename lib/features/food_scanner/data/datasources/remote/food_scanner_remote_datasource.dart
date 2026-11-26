import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/core/network/api_client.dart';
import 'package:fitness_app/features/food_scanner/data/models/food_scanner_model.dart';

class FoodScannerRemoteDataSource {
  FoodScannerRemoteDataSource({ApiClient? api}) : api = api ?? ApiClient();

  final ApiClient api;

  /// Only the fields the app uses, which keeps the response small.
  static const _fields =
      'code,product_name,product_name_en,generic_name,brands,'
      'image_front_url,nutriments';

  /// Returns null when Open Food Facts doesn't know the barcode.
  Future<FoodItemModel?> getFoodByBarcode(String barcode) async {
    final uri = Uri.parse(
      '${AppConfig.openFoodFactsBaseUrl}/api/v2/product/'
      '${Uri.encodeComponent(barcode)}',
    ).replace(queryParameters: {'fields': _fields});

    final Map<String, dynamic> data;
    try {
      data = await api.getJson(uri);
    } on ServerException catch (e) {
      // v2 answers 404 with {"status": 0} for unknown barcodes.
      if (e.isNotFound) return null;
      rethrow;
    }

    if (data['status'] != 1 || data['product'] is! Map) return null;
    return FoodItemModel.fromJson(data);
  }
}
