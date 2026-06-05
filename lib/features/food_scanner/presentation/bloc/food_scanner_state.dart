import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/food_scanner/domain/entities/scanned_food_entity.dart';

class FoodScannerState extends Equatable {
  final bool isLoading;

  final FoodItemEntity? product;

  final String? error;

  const FoodScannerState({this.isLoading = false, this.product, this.error});

  factory FoodScannerState.initial() {
    return const FoodScannerState();
  }

  FoodScannerState copyWith({
    bool? isLoading,
    FoodItemEntity? product,
    String? error,
  }) {
    return FoodScannerState(
      isLoading: isLoading ?? this.isLoading,
      product: product ?? this.product,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, product, error];
}
