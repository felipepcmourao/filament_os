import 'package:equatable/equatable.dart';

class Filament extends Equatable {
  final String id;
  final String name;
  final String material;
  final double quantityInGrams;

  const Filament({
    required this.id,
    required this.name,
    required this.material,
    required this.quantityInGrams,
  });

  @override
  List<Object?> get props => [id, name, material, quantityInGrams];
}
