// Smoke test do app inteiro: monta o `MyApp` de verdade e confere que a
// primeira tela apareceu.
//
// Parece pouco, mas cobre mais do que aparenta. O texto 'FilamentOS' mora na
// `HomePage`, e nada aqui a instancia diretamente — pra ele existir na tela, o
// `MaterialApp.router` precisa ter subido, o `AppRouter` precisa ter resolvido
// a URL inicial `/` e o tema precisa ter sido aplicado sem lançar. Um erro em
// qualquer um desses três pontos derruba este teste.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:filament_os/main.dart';

void main() {
  testWidgets('Simple smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('FilamentOS'), findsOneWidget);
  });
}
