import 'package:equatable/equatable.dart';

/// O usuário autenticado, do jeito que o app o enxerga, com `uid` nunca vazio.
///
/// Existe para que o `User` do `firebase_auth` nunca saia de `data/`: o resto
/// do app conhece só `AppUser`, e não sabe quem autentica.
///
/// Chama-se `AppUser`, e não `User`, porque o repositório concreto importa
/// também o `firebase_auth`, que exporta um `User`.
///
/// Rejeita `uid` só com espaços, como o `ownerId` do `Filament`: um vira o
/// outro, então os dois precisam aceitar os mesmos valores.
class AppUser extends Equatable {
  final String uid;

  const AppUser._({required this.uid});

  factory AppUser({required String uid}) {
    if (uid.trim().isEmpty) {
      throw ArgumentError.value(uid, 'uid', 'uid não pode estar vazio.');
    }
    return AppUser._(uid: uid);
  }

  @override
  List<Object?> get props => [uid];

  @override
  bool? get stringify => true;
}
