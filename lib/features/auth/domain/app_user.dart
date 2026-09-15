import 'package:equatable/equatable.dart';

/// O usuário autenticado, do jeito que o app o enxerga.
///
/// Existe para que o `User` do `firebase_auth` nunca saia de
/// `features/auth/data/`. É lá, e só lá, que o tipo do Firebase é traduzido
/// para este: o resto do app — `filaments`, `prints`, o roteador — conhece
/// apenas `AppUser` e não sabe quem autentica.
///
/// Só tem `uid` porque é o único campo que o app usa hoje: ele vira o
/// `ownerId` de `Filament` e `Print`. E-mail, nome e datas da conta ficaram de
/// fora de propósito (domínio enxuto) e entram quando uma tela os exibir, como
/// a futura página de perfil. Há ainda um motivo específico para não trazer o
/// nome agora: no cadastro por e-mail e senha o `displayName` do Firebase vem
/// nulo, e a entity teria uma invariante que o dado de origem não cumpre.
///
/// Chama-se `AppUser`, e não `User`, porque o repositório concreto importa ao
/// mesmo tempo esta classe e o `package:firebase_auth`, que exporta um `User`.
/// O nome próprio dispensa apelido de import no único arquivo onde as duas se
/// encontram.
///
/// A invariante usa `trim()`, igual ao `ownerId` do `Filament`: um `uid` só
/// com espaços é tão inútil quanto um vazio, e os dois lados precisam aceitar
/// exatamente os mesmos valores, já que um vira o outro. `null` não precisa de
/// checagem: o tipo `String` já o impede em tempo de compilação.
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
