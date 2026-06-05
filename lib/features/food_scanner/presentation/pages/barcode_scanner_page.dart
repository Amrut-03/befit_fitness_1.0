import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_bloc.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_event.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_state.dart';
import 'package:fitness_app/features/food_scanner/presentation/widgets/show_product_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _requestCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      _isCheckingPermission = true;
    });

    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _isCheckingPermission = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
      });
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;

    if (code == null || code.isEmpty) return;
    _isProcessing = true;

    context.read<FoodScannerBloc>().add(ProcessBarcodeEvent(code));
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: AppLoader()),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: const Color(0xFF00E5FF),
                    size: 60.sp,
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  "Camera Permission Required",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Please allow camera access to scan food barcodes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 34.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _requestCameraPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      "Grant Permission",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    "Go Back",
                    style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<FoodScannerBloc, FoodScannerState>(
        listener: (context, state) {
          if (state.product != null) {
            _controller.stop();

            showProductBottomSheet(context, state.product!).then((_) {
              _isProcessing = false;

              context.read<FoodScannerBloc>().add(ResetScannerEvent());

              _controller.start();
            });

            // context.pop();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));

            _isProcessing = false;

            context.read<FoodScannerBloc>().add(ResetScannerEvent());
          }
        },

        builder: (context, state) {
          return Stack(
            children: [
              MobileScanner(controller: _controller, onDetect: _onDetect),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.45),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 280.w,
                        height: 180.h,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 280.w,
                  height: 180.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: const Color(0xFF00E5FF),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _circleButton(
                        icon: Icons.flash_on_rounded,
                        onTap: () async {
                          await _controller.toggleTorch();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 130.h,
                left: 24.w,
                right: 24.w,
                child: Column(
                  children: [
                    Text(
                      "Scan Food Barcode",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Align barcode inside the frame",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(child: AppLoader()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}
