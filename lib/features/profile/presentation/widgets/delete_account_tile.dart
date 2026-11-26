import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Settings tile that permanently deletes the user's account and all their
/// data. It's the in-app deletion flow required by Google Play.
class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({super.key});

  static const _danger = AppColors.error;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev is AuthDeleting || curr is AuthAccountDeleted,
      listener: (context, state) {
        if (state is AuthAccountDeleted) {
          // The router redirects to /login when the session signs out.
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.accountDeleted)));
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      buildWhen: (prev, curr) => prev is AuthDeleting || curr is AuthDeleting,
      builder: (context, state) {
        final deleting = state is AuthDeleting;

        return GestureDetector(
          onTap: deleting ? null : () => _confirmAndDelete(context),
          child: Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: _danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delete_forever, color: _danger),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    deleting
                        ? context.l10n.accountDeleting
                        : context.l10n.accountDelete,
                    style: TextStyle(
                      color: _danger,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (deleting)
                  SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _danger,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: _danger.withValues(alpha: 0.6),
                    size: 16.sp,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final isGuest = (await sl<GetCurrentUser>()())?.isGuest ?? true;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          context.l10n.accountDeleteTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isGuest
              ? context.l10n.accountDeleteBody
              : '${context.l10n.accountDeleteBody}\n\n'
                    '${context.l10n.accountDeleteGoogleConfirm}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              context.l10n.commonCancel,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              context.l10n.commonDelete,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthDeleteRequested());
    }
  }
}
