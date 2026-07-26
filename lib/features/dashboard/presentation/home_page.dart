import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Text('FilamentOS'),
              const SizedBox(height: 20),
              TextButton(
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
