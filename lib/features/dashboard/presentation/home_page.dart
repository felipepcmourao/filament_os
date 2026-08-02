import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Home Page')),
        body: Center(
          child: Column(
            children: [
              const Text('FilamentOS'),
              const SizedBox(height: 20),
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
