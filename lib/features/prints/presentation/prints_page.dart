import 'package:flutter/material.dart';

/// Placeholder da lista de impressões, alcançada por `/prints`.
///
/// Está vazia de propósito. Existe porque a rota `/prints` precisa levar a
/// algum lugar, e uma rota que aponta pro nada não dá pra exercitar — sem esta
/// tela não haveria como verificar que o roteador tem três destinos irmãos, que
/// é o que a barra de navegação persistente vai usar.
///
/// O conteúdo depende do `RegisterPrint` ter uma tela que o chame, e de haver
/// como compartilhar o repositório entre telas (Sessão 6). Até lá, `Container`
/// vazio é o estado honesto: melhor uma tela em branco do que dados falsos que
/// se parecem com os de verdade.
class PrintsPage extends StatelessWidget {
  const PrintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impressões')),
      body: SafeArea(child: Container()),
    );
  }
}
