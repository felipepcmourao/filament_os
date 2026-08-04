import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:flutter/material.dart';

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FilamentsPage(),
                    ),
                  );
                },
                child: const Text('Filamentos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
