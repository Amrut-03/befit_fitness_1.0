import 'package:fitness_app/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:fitness_app/features/food_scanner/domain/repositories/food_scanner_repository.dart';

class ScanBarcode {
  final FoodScannerRepository repository;

  ScanBarcode(this.repository);

  Future<FoodItemEntity?> call(String barcode) {
    return repository.scanBarcode(barcode);
  }
}
