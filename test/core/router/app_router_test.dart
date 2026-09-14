import 'package:filament_os/core/auth/auth_notifier.dart';
import 'package:filament_os/core/presentation/login_page.dart';
import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/router/app_router.dart';
import 'package:filament_os/features/dashboard/presentation/home_page.dart';
import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Testes do roteador: que navegar leva onde deveria, e que um teste não
// contamina o outro.
//
// Monta `MaterialApp.router` com `AppRouter.createRouter()` em vez de usar o
// `MyApp` pronto, e isso não é preciosismo: o `MyApp` usa `AppRouter.router`,
// que é `static` — uma instância por isolate. Como o `flutter test` roda o
// arquivo inteiro num isolate só, os testes herdariam a posição de navegação
// uns dos outros, e um teste que tocasse em "Filamentos" deixaria o seguinte
// começando em `/filaments` sem ter tocado em nada.
//
// Afirma com `find.byType`, não com `find.text`: o que se quer provar é que o
// roteador chegou naquela tela. Um `find.text('Filaments Page')` quebraria
// numa tradução do título, sem bug nenhum ter acontecido.
class LoggedOutNotifier extends AuthNotifier {
  @override
  bool build() => false;
}

void main() {
  testWidgets('Tocar em Filamentos leva a Filaments Pages', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: container.read(routerProvider)),
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Filamentos'));
    await tester.pumpAndSettle();
    expect(find.byType(FilamentsPage), findsOneWidget);
  });

  testWidgets('Roteador novo não herda a navegação do anterior', (
    WidgetTester tester,
  ) async {
    ProviderContainer container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: container.read(routerProvider)),
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Filamentos'));
    await tester.pumpAndSettle();

    // A segunda montagem não é repetição — é o teste inteiro. Navegar já
    // aconteceu acima; aqui um roteador NOVO entra no lugar do anterior, e a
    // pergunta é se ele começa do zero ou herda o `/filaments` de cima.
    //
    // Simular isso dentro de um teste só é deliberado. Dava pra provar o mesmo
    // com dois testes vizinhos — um que navega, outro que espera a home — mas
    // aí a garantia dependeria da ordem em que eles rodam, e ordem não está
    // escrita em lugar nenhum: bastaria alguém inserir um teste no meio, ou o
    // `flutter test` mudar de critério, pra proteção sumir sem ninguém notar.
    // Verificado: trocando `createRouter()` por `AppRouter.router`, este teste
    // (e só ele) falha.
    container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: container.read(routerProvider)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Clicar na Navigation Bar leva para a tela correta', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: container.read(routerProvider)),
      ),
    );
    await tester.tap(find.widgetWithIcon(NavigationDestination, Icons.circle));
    await tester.pumpAndSettle();
    expect(find.byType(FilamentsPage), findsOneWidget);
  });

  testWidgets(
    'Direcionamento para LoginPage caso o usuário não esteja logado.',
    (WidgetTester tester) async {
      final container = ProviderContainer.test(
        overrides: [authProvider.overrideWith(LoggedOutNotifier.new)],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: container.read(routerProvider),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    },
  );

  testWidgets('Deslogado consegue chegar na tela de login', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer.test(
      overrides: [authProvider.overrideWith(LoggedOutNotifier.new)],
    );
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.go(AppPaths.login);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Alternar o authProvider muda o comportamento da navegação', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: container.read(routerProvider)),
      ),
    );
    await tester.pumpAndSettle();
    container.read(authProvider.notifier).toggle();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
