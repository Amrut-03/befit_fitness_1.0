import 'package:fitness_app/core/l10n/l10n.dart';
import 'dart:async';

import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/food_scanner/domain/usecases/scan_barcode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'food_scanner_event.dart';
import 'food_scanner_state.dart';

class FoodScannerBloc extends Bloc<FoodScannerEvent, FoodScannerState> {
  final ScanBarcode scanBarcode;
  final AppAnalytics analytics;

  FoodScannerBloc(this.scanBarcode, {this.analytics = const NoopAnalytics()})
    : super(FoodScannerState.initial()) {
    on<ProcessBarcodeEvent>(_onProcessBarcode);
    on<ResetScannerEvent>(_onResetScanner);
  }

  Future<void> _onProcessBarcode(
    ProcessBarcodeEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await scanBarcode(event.barcode);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure is NetworkFailure
              ? AppLocale.l10n.scanOffline
              : failure.message,
        ),
      ),
      (product) {
        unawaited(analytics.logFoodScanned(found: product != null));
        emit(
          product == null
              ? state.copyWith(
                  isLoading: false,
                  error: AppLocale.l10n.scanNotFound,
                )
              : state.copyWith(isLoading: false, product: product),
        );
      },
    );
  }

  void _onResetScanner(
    ResetScannerEvent event,
    Emitter<FoodScannerState> emit,
  ) {
    emit(FoodScannerState.initial());
  }
}
