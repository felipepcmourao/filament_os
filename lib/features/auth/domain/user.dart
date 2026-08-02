import 'package:equatable/equatable.dart';

/// Dono de um estoque de filamentos / impressões / vendas.
///
/// Precisou ganhar `id` pra que `Filament.ownerId` e `Prints.ownerId`
/// tivessem algo pra referenciar — sem um identificador único, não havia
/// como dizer "de quem" é aquele estoque/impressão no cenário multi-usuário.
class User extends Equatable {
  final String id;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String address;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, age, email, phone, address];
}
