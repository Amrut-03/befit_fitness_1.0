import 'package:fitness_app/core/error/result.dart';

import '../entities/scanned_food_entity.dart';

abstract class FoodScannerRepository {
  /// `Ok(null)` means the barcode isn't in Open Food Facts.
  Future<Result<FoodItemEntity?>> scanBarcode(String barcode);
}
