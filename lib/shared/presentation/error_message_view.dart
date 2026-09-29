import 'package:filament_os/shared/domain/app_exception.dart';
import 'package:filament_os/shared/presentation/app_exception_label.dart';
import 'package:flutter/material.dart';

/// Texto para falha que o app não reconhece, ou que o usuário não resolve:
/// não promete que repetir resolve, nem afirma uma causa.
///
/// Mora aqui, e não no arquivo da extension, porque o dono dele é o caso "não
/// é uma exceção minha", que só este widget conhece; a extension o usa
/// emprestado.
const String generalErrorMessage =
    'Algo deu errado. Se continuar, avise o suporte';

/// Tela de erro única do app: recebe o que falhou e mostra o texto certo.
///
/// Único lugar que testa se o erro é uma `AppException`, porque
/// `AsyncValue.error` entrega `Object` e o teste não deve se repetir nas telas.
///
/// Não se chama `ErrorWidget` porque essa classe já existe no Flutter e vem
/// com `material.dart`: chamar a errada compila sem aviso.
class ErrorMessageView extends StatelessWidget {
  final Object error;
  const ErrorMessageView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final String errLabel = switch (error) {
      final AppException e => e.label,
      _ => generalErrorMessage,
    };
    return Center(
      child: Text(
        errLabel,
        style: Theme.of(context).textTheme.bodyMedium!.apply(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
