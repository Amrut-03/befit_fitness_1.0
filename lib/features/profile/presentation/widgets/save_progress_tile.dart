import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shown to guests only: links the anonymous account to Google so the data
/// survives sign-out, reinstall or a new phone.
class SaveProgressTile extends StatefulWidget {
  const SaveProgressTile({super.key, this.isGuest});

  /// Overrides the lookup of the current user (for tests).
  final Future<bool> Function()? isGuest;

  @override
  State<SaveProgressTile> createState() => _SaveProgressTileState();
}

class _SaveProgressTileState extends State<SaveProgressTile> {
  late final Future<bool> _isGuest =
      widget.isGuest?.call() ??
      sl<GetCurrentUser>()().then((user) => user?.isGuest ?? false);

  bool _linked = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isGuest,
      builder: (context, snapshot) {
        if (snapshot.data != true || _linked) return const SizedBox.shrink();

        return BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev is AuthLinking,
          listener: (context, state) {
            if (state is AuthAuthenticated && !state.user.isGuest) {
              setState(() => _linked = true);
              // Pick up the name and email that were just saved.
              context.read<ProfileBloc>().add(LoadProfileEvent());
              context.read<HomeBloc>().add(RefreshHomeDashboard());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.progressSavedTo(
                      state.user.email ??
                          context.l10n.progressYourGoogleAccount,
                    ),
                  ),
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          buildWhen: (prev, curr) => prev is AuthLinking || curr is AuthLinking,
          builder: (context, state) {
            final linking = state is AuthLinking;

            return GestureDetector(
              onTap: linking
                  ? null
                  : () => context.read<AuthBloc>().add(
                      const AuthLinkGoogleRequested(),
                    ),
              child: Container(
                margin: EdgeInsets.only(bottom: 14.h),
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload, color: AppColors.primary),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            linking
                                ? context.l10n.progressLinking
                                : context.l10n.progressSave,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            context.l10n.progressGuestHint,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (linking)
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
