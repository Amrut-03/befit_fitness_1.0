import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 150});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lotties/loader.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
