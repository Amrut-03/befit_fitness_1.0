import 'package:fitness_app/features/food_scanner/data/datasources/remote/food_scanner_remote_datasource.dart';
import 'package:fitness_app/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:fitness_app/features/food_scanner/domain/repositories/food_scanner_repository.dart';

class FoodScannerRepositoryImpl implements FoodScannerRepository {
  final FoodScannerRemoteDataSource remoteDataSource;

  FoodScannerRepositoryImpl(this.remoteDataSource);

  @override
  Future<FoodItemEntity?> scanBarcode(String barcode) {
    return remoteDataSource.getFoodByBarcode(barcode);
  }
}
