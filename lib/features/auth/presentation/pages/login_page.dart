import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/auth/presentation/widgets/google_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surfaceNavy,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              // Navigation after sign-in is handled by the router's
              // SessionNotifier redirect.
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                // Scrolls on short screens or large text instead of
                // overflowing; the Spacers still centre it on tall screens.
                return LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Spacer(),
                            Container(
                              height: 280.h,
                              width: 280.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.18),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Lottie.asset(
                                'assets/lotties/login.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Text(
                              context.l10n.loginWelcome,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              context.l10n.loginTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 15.sp,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 50.h),
                            AuthButton(
                              title: context.l10n.loginGoogle,
                              isLoading: isLoading,
                              icon: SvgPicture.asset(
                                'assets/icons/google.svg',
                                height: 24.h,
                              ),
                              onTap: () {
                                context.read<AuthBloc>().add(
                                  const AuthGoogleSignInRequested(),
                                );
                              },
                            ),
                            SizedBox(height: 18.h),
                            AuthButton(
                              title: context.l10n.loginGuest,
                              isPrimary: true,
                              isLoading: isLoading,
                              icon: Icon(
                                Icons.person_outline,
                                color: Colors.black,
                                size: 24.sp,
                              ),
                              onTap: () {
                                context.read<AuthBloc>().add(
                                  const AuthGuestSignInRequested(),
                                );
                              },
                            ),
                            SizedBox(height: 28.h),
                            Text(
                              context.l10n.loginTerms,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
