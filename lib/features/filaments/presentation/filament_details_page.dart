import 'package:flutter/material.dart';

class FilamentDetailsPage extends StatelessWidget {
  final String id;

  const FilamentDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(id)),
      body: SafeArea(child: Center(child: Text(id))),
    );
  }
}
