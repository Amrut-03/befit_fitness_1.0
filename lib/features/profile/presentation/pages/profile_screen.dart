import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/profile/presentation/pages/profile_share_card.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vision_gallery_saver/vision_gallery_saver.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const AppLoader();
            }
            if (state is ProfileError) {
              return Center(
                child: Text(
                  state.message,

                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (state is ProfileLoaded) {
              final profile = state.profile;

              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// HEADER
                    Container(
                      width: double.infinity,

                      padding: EdgeInsets.all(24.w),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34.r),

                        gradient: LinearGradient(
                          begin: Alignment.topLeft,

                          end: Alignment.bottomRight,

                          colors: [
                            const Color(0xFF111827),

                            const Color(0xFF0F172A),

                            const Color(0xFF09111F),
                          ],
                        ),

                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.12),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.08),

                            blurRadius: 30,

                            spreadRadius: 2,

                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          /// PROFILE IMAGE
                          Container(
                            padding: EdgeInsets.all(4.w),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00E5FF),
                                  Color.fromARGB(255, 0, 160, 128),
                                ],
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00E5FF,
                                  ).withOpacity(0.4),

                                  blurRadius: 25,

                                  spreadRadius: 2,
                                ),
                              ],
                            ),

                            child: CircleAvatar(
                              radius: 48.r,

                              backgroundColor: const Color(0xFF0B1220),

                              backgroundImage: profile.photoUrl != null
                                  ? NetworkImage(profile.photoUrl!)
                                  : null,

                              child: profile.photoUrl == null
                                  ? Icon(
                                      Icons.person_rounded,

                                      size: 46.sp,

                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),

                          SizedBox(height: 20.h),

                          /// NAME
                          Text(
                            profile.name,

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 28.sp,

                              fontWeight: FontWeight.bold,

                              letterSpacing: 0.5,
                            ),
                          ),

                          SizedBox(height: 6.h),

                          /// EMAIL
                          Text(
                            profile.email,

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),

                              fontSize: 14.sp,

                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 24.h),

                          /// GOAL BADGE
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,

                              vertical: 10.h,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.r),

                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00E5FF).withOpacity(0.18),

                                  const Color(0xFF00B8D4).withOpacity(0.08),
                                ],
                              ),

                              border: Border.all(
                                color: const Color(
                                  0xFF00E5FF,
                                ).withOpacity(0.25),
                              ),
                            ),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.local_fire_department,

                                  color: const Color(0xFF00E5FF),

                                  size: 18.sp,
                                ),

                                SizedBox(width: 8.w),

                                Text(
                                  profile.goal,

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontWeight: FontWeight.bold,

                                    fontSize: 13.sp,

                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.h),

                    /// STATS TITLE
                    Text(
                      "Fitness Stats",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 18.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    /// STATS GRID
                    GridView.count(
                      crossAxisCount: 2,

                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      crossAxisSpacing: 14.w,

                      mainAxisSpacing: 14.h,

                      childAspectRatio: 1.2,

                      children: [
                        _buildStatCard(
                          title: "Weight",
                          value: "${profile.weight.round()} kg",
                          icon: Icons.monitor_weight,
                          color: const Color(0xFF00E5FF),
                        ),

                        _buildStatCard(
                          title: "Height",
                          value: "${profile.height.round()} cm",
                          icon: Icons.height,
                          color: const Color(0xFFFFB703),
                        ),

                        _buildStatCard(
                          title: "Age",
                          value: "${profile.age.round()}",
                          icon: Icons.cake,
                          color: const Color(0xFFFF006E),
                        ),

                        BlocBuilder<StreakBloc, StreakState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return _buildStatCard(
                                title: "Streak",
                                value: "...",
                                icon: Icons.local_fire_department,
                                color: const Color(0xFF00E5FF),
                              );
                            }

                            return _buildStatCard(
                              title: "Streak",
                              value: "${state.currentStreak} Days",
                              icon: Icons.local_fire_department,
                              color: const Color(0xFF00E5FF),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    /// SHARE CARD
                    Text(
                      "Share Progress",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 18.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16.h),

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

                            streak: context
                                .watch<StreakBloc>()
                                .state
                                .currentStreak,

                            calories: data.calories.toInt(),

                            steps: data.steps,

                            bmi: profile.height == 0
                                ? 0
                                : profile.weight /
                                      ((profile.height / 100) *
                                          (profile.height / 100)),
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
                          side: BorderSide(
                            color: const Color(0xFF00E5FF).withOpacity(0.4),
                          ),

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
                                const SnackBar(
                                  content: Text("Image saved to gallery ✅"),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("SAVE ERROR: $e");

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },

                        icon: Icon(
                          Icons.download,

                          color: const Color(0xFF00E5FF),

                          size: 22.sp,
                        ),

                        label: Text(
                          "Save to Gallery",

                          style: TextStyle(
                            color: const Color(0xFF00E5FF),

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
                          backgroundColor: const Color(0xFF00E5FF),

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
                              debugPrint("Screenshot failed");

                              return;
                            }

                            final directory = await getTemporaryDirectory();

                            final imagePath = File(
                              '${directory.path}/befit_share.png',
                            );

                            await imagePath.writeAsBytes(image);

                            debugPrint("IMAGE SAVED: ${imagePath.path}");

                            await Share.shareXFiles(
                              [XFile(imagePath.path)],

                              text: "Check out my fitness progress on BeFit 🔥",
                            );
                          } catch (e) {
                            debugPrint("SHARE ERROR: $e");

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },

                        icon: Icon(
                          Icons.share,

                          color: Colors.black,

                          size: 22.sp,
                        ),

                        label: Text(
                          "Share Progress",

                          style: TextStyle(
                            color: Colors.black,

                            fontSize: 16.sp,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    /// SETTINGS
                    Text(
                      "Settings",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 18.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    _settingsTile(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      onTap: () async {
                        final result = await context.push(
                          '/edit-profile',

                          extra: profile,
                        );
                      },
                    ),
                    _settingsTile(
                      icon: Icons.notifications,
                      title: "Notifications",
                      onTap: () {
                        context.push('/notification-setting-page');
                      },
                    ),

                    _settingsTile(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,

                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFF121212),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),

                              title: Text(
                                "Logout",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: 18.sp,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              content: Text(
                                "Are you sure you want to logout?",

                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),

                                  fontSize: 14.sp,
                                ),
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    context.pop(true);
                                  },

                                  child: Text(
                                    "Cancel",

                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E5FF),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),

                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },

                                  child: Text(
                                    "Logout",

                                    style: TextStyle(
                                      color: Colors.black,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldLogout == true) {
                          await FirebaseAuth.instance.signOut();

                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,

    required String value,

    required IconData icon,

    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),

        borderRadius: BorderRadius.circular(24.r),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: EdgeInsets.all(10.w),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: color.withOpacity(0.15),
            ),

            child: Icon(icon, color: color, size: 20.sp),
          ),

          const Spacer(),

          Text(
            value,

            style: TextStyle(
              color: Colors.white,

              fontSize: 18.sp,

              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            title,

            style: TextStyle(
              color: Colors.white.withOpacity(0.5),

              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,

          style: TextStyle(
            color: const Color(0xFF00E5FF),

            fontSize: 18.sp,

            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          title,

          style: TextStyle(
            color: Colors.white.withOpacity(0.5),

            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,

    required String title,

    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),

        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),

          borderRadius: BorderRadius.circular(20.r),
        ),

        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF)),

            SizedBox(width: 14.w),

            Expanded(
              child: Text(
                title,

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 14.sp,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,

              color: Colors.white.withOpacity(0.4),

              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
