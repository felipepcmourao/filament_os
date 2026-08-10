import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scaffold (LoginPage) para ser preenchido na Sessão 7',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextButton(
            onPressed: () => context.goNamed(AppRouteNames.home),
            child: const Text('Ir para Início'),
          ),
        ],
      ),
    );
  }
}
