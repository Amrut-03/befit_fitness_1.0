import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/auth/presentation/widgets/google_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF050505), Color(0xFF09111F), Color(0xFF050505)],
          ),
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go('/goal-selection');
              }
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                              const Color(0xFF00E5FF).withOpacity(0.18),
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
                        'Welcome to BeFit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Track workouts, build healthy habits,\nand transform your fitness journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 15.sp,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      AuthButton(
                        title: "Continue with Google",
                        isLoading: isLoading,
                        icon: SvgPicture.asset(
                          'assets/icons/google.svg',
                          height: 24.h,
                        ),
                        onTap: () {
                          context.read<AuthBloc>().add(
                            AuthGoogleSignInRequested(),
                          );
                        },
                      ),
                      SizedBox(height: 18.h),
                      AuthButton(
                        title: "Continue as Guest",
                        isPrimary: true,
                        isLoading: isLoading,
                        icon: Icon(
                          Icons.person_outline,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                        onTap: () {
                          context.read<AuthBloc>().add(
                            AuthGuestSignInRequested(),
                          );
                        },
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        "By continuing you agree to our\nTerms & Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
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
