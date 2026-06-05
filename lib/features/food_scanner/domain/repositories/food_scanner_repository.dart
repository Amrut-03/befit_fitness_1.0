import '../entities/scanned_food_entity.dart';

abstract class FoodScannerRepository {
  Future<FoodItemEntity?> scanBarcode(String barcode);
}
