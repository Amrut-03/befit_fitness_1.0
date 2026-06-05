import 'package:flutter/material.dart';

class GuestSigninButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const GuestSigninButton({
    super.key,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        child: const Text('Continue as Guest'),
      ),
    );
  }
}
