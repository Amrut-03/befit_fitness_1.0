import 'package:equatable/equatable.dart';

abstract class FoodScannerEvent extends Equatable {
  const FoodScannerEvent();

  @override
  List<Object?> get props => [];
}

class ProcessBarcodeEvent extends FoodScannerEvent {
  final String barcode;

  const ProcessBarcodeEvent(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class ResetScannerEvent extends FoodScannerEvent {}
