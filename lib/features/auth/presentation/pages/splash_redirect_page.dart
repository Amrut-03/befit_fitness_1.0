import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';

class SplashRedirectPage extends StatefulWidget {
  const SplashRedirectPage({super.key});

  @override
  State<SplashRedirectPage> createState() => _SplashRedirectPageState();
}

class _SplashRedirectPageState extends State<SplashRedirectPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.push('/home');
          }
          if (state is AuthUnauthenticated) {
            context.push('/login');
          }
          if (state is AuthError) {
            context.push('/login');
          }
          if (state is AuthError) {
            context.push('/login');
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 70),
              SizedBox(height: 20),
              Text(
                'BeFit',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              AppLoader(),
            ],
          ),
        ),
      ),
    );
  }
}
