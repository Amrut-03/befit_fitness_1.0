import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/error/result.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/usecases/delete_account.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:fitness_app/features/food_scanner/domain/usecases/scan_barcode.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_bloc.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _RecordingAnalytics extends NoopAnalytics {
  final events = <String>[];

  @override
  Future<void> logLogin({required String method}) async =>
      events.add('login:$method');

  @override
  Future<void> logFoodScanned({required bool found}) async =>
      events.add('scan:$found');
}

class _Google extends Mock implements SignInWithGoogle {}

class _Guest extends Mock implements SignInAsGuest {}

class _Scan extends Mock implements ScanBarcode {}

class _SignOut extends Mock implements SignOut {}

class _Delete extends Mock implements DeleteAccount {}

void main() {
  late _RecordingAnalytics analytics;
  setUp(() => analytics = _RecordingAnalytics());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'successful sign-ins are logged with their method; failures are not',
    () async {
      final google = _Google();
      final guest = _Guest();
      when(
        () => google(),
      ).thenAnswer((_) async => const UserEntity(uid: 'u', isGuest: false));
      when(() => guest()).thenThrow(Exception());

      final bloc =
          AuthBloc(
              signInWithGoogle: google,
              signInAsGuest: guest,
              signOut: _SignOut(),
              deleteAccount: _Delete(),
              analytics: analytics,
            )
            ..add(const AuthGoogleSignInRequested())
            ..add(const AuthGuestSignInRequested());
      await settle();
      await bloc.close();

      expect(analytics.events, ['login:google']);
    },
  );

  test('scans are logged as found or not found, errors are not', () async {
    final scan = _Scan();
    when(() => scan('1')).thenAnswer(
      (_) async => const Ok(
        FoodItemEntity(
          barcode: '1',
          name: 'Milk',
          calories: 1,
          protein: 1,
          carbs: 1,
          fat: 1,
        ),
      ),
    );
    when(() => scan('2')).thenAnswer((_) async => const Ok(null));
    when(() => scan('3')).thenAnswer((_) async => const Err(NetworkFailure()));

    final bloc = FoodScannerBloc(scan, analytics: analytics)
      ..add(const ProcessBarcodeEvent('1'))
      ..add(const ProcessBarcodeEvent('2'))
      ..add(const ProcessBarcodeEvent('3'));
    await settle();
    await bloc.close();

    expect(analytics.events, ['scan:true', 'scan:false']);
  });
}
