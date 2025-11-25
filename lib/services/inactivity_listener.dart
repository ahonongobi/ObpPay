import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class InactivityListener extends StatelessWidget {
  final Widget child;
  const InactivityListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        context.read<UserProvider>().resetInactivity();
      },
      child: child,
    );
  }
}
