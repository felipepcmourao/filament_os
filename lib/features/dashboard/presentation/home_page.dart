import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text(
                'FilamentOS',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go(AppPaths.filaments),
                child: const Text('Filamentos'),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go('dsada'),
                child: const Text('Teste Not Found'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
