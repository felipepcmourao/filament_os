import 'package:filament_os/shared/domain/app_exception.dart';
import 'package:filament_os/shared/presentation/app_exception_label.dart';
import 'package:flutter/material.dart';

/// Texto de tela para falha que o app não reconhece — e para a que ele
/// reconhece mas o usuário não pode resolver (ver `AppExceptionLabel`).
///
/// Não promete que repetir resolve, e não afirma uma causa. Mora aqui, e não
/// no arquivo da extension, porque o dono dele é o caso "não é uma exceção
/// minha", que só este widget conhece; a extension o usa emprestado.
const String generalErrorMessage =
    'Algo deu errado. Se continuar, avise o suporte';

/// Tela de erro única do app: recebe o que falhou e mostra o texto certo.
///
/// É o **único** lugar onde se pergunta se um erro é uma `AppException`. O
/// `AsyncValue.error` entrega `Object` — um `Future` pode falhar com
/// qualquer coisa, inclusive com erro de infraestrutura que não é do
/// domínio —, então o teste de tipo precisa acontecer em algum lugar. Aqui,
/// uma vez, e não repetido nas quatro telas que renderizam erro.
///
/// `StatelessWidget` e não `ConsumerWidget`: recebe o erro pronto por
/// parâmetro e não lê provider nenhum.
///
/// O nome evita `ErrorWidget` de propósito — essa classe já existe no
/// Flutter (é a tela vermelha de `build` quebrado) e vem junto com o import
/// de `material.dart`. As duas conviveriam, e chamar a errada compila sem
/// aviso: foi o que aconteceu uma vez aqui, e só o teste de widget pegou.
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
