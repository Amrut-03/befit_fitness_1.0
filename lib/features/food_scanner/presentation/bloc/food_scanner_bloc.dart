import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_app/features/food_scanner/domain/usecases/scan_barcode.dart';
import 'food_scanner_event.dart';
import 'food_scanner_state.dart';

class FoodScannerBloc extends Bloc<FoodScannerEvent, FoodScannerState> {
  final ScanBarcode scanBarcode;

  FoodScannerBloc(this.scanBarcode) : super(FoodScannerState.initial()) {
    on<ProcessBarcodeEvent>(_onProcessBarcode);
    on<ResetScannerEvent>(_onResetScanner);
  }

  Future<void> _onProcessBarcode(
    ProcessBarcodeEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final product = await scanBarcode(event.barcode);

      if (product == null) {
        emit(state.copyWith(isLoading: false, error: 'Product not found'));
        return;
      }

      emit(state.copyWith(isLoading: false, product: product));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to scan product'));
    }
  }

  void _onResetScanner(
    ResetScannerEvent event,
    Emitter<FoodScannerState> emit,
  ) {
    emit(FoodScannerState.initial());
  }
}
