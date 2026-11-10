import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Settings tile that permanently deletes the user's account and all their
/// data. It's the in-app deletion flow required by Google Play.
class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({super.key});

  static const _danger = Color(0xFFFF5252);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev is AuthDeleting || curr is AuthAccountDeleted,
      listener: (context, state) {
        if (state is AuthAccountDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your account has been deleted.')),
          );
          context.go('/login');
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
                    deleting ? 'Deleting account…' : 'Delete Account',
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
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          'Delete account?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This permanently deletes your account and all your data: profile, '
          'diet plans, food items, workout history, health metrics and '
          'streak. This cannot be undone.'
          '${isGuest ? '' : '\n\nYou will be asked to confirm with Google.'}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
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
            child: const Text(
              'Delete',
              style: TextStyle(
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
