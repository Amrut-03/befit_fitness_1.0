import 'package:fitness_app/core/l10n/l10n.dart';
import 'dart:io';

import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/pages/profile_share_card.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vision_gallery_saver/vision_gallery_saver.dart';

/// The shareable progress card plus its "Save to Gallery" and "Share"
/// buttons. Owns the [ScreenshotController] that captures the card.
class ProfileShareSection extends StatefulWidget {
  const ProfileShareSection({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  State<ProfileShareSection> createState() => _ProfileShareSectionState();
}

class _ProfileShareSectionState extends State<ProfileShareSection> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<HealthBloc, HealthState>(
          builder: (context, healthState) {
            if (healthState is! HealthLoaded) {
              return const SizedBox();
            }

            final data = healthState.data;

            return Screenshot(
              controller: screenshotController,
              child: ProfileShareCard(
                name: profile.name,
                goal: profile.goal,
                weight: profile.weight,
                streak: context.watch<StreakBloc>().state.currentStreak,
                calories: data.calories.toInt(),
                steps: data.steps,
                bmi: profile.height == 0
                    ? 0
                    : profile.weight /
                          ((profile.height / 100) * (profile.height / 100)),
              ),
            );
          },
        ),
        SizedBox(height: 18.h),
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            onPressed: () async {
              try {
                final image = await screenshotController.capture(
                  delay: const Duration(milliseconds: 10),
                );

                if (image == null) {
                  return;
                }

                final result = await VisionGallerySaver.saveImage(
                  image,
                  quality: 100,
                  name:
                      "befit_progress_${DateTime.now().millisecondsSinceEpoch}",
                );

                debugPrint("SAVE RESULT: $result");

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.shareSavedToGallery)),
                  );
                }
              } catch (e) {
                debugPrint("SAVE ERROR: $e");

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            icon: Icon(Icons.download, color: AppColors.primary, size: 22.sp),
            label: Text(
              context.l10n.shareSaveToGallery,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            onPressed: () async {
              final shareText = context.l10n.shareText;
              try {
                final image = await screenshotController.capture(
                  delay: const Duration(milliseconds: 10),
                );

                if (image == null) {
                  debugPrint("Screenshot failed");

                  return;
                }

                final directory = await getTemporaryDirectory();

                final imagePath = File('${directory.path}/befit_share.png');

                await imagePath.writeAsBytes(image);

                debugPrint("IMAGE SAVED: ${imagePath.path}");

                await SharePlus.instance.share(
                  ShareParams(files: [XFile(imagePath.path)], text: shareText),
                );
              } catch (e) {
                debugPrint("SHARE ERROR: $e");

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            icon: Icon(Icons.share, color: Colors.black, size: 22.sp),
            label: Text(
              context.l10n.profileShareProgress,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
