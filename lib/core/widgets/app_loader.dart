import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lotties/loader.json',
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      ),
    );
  }
}
