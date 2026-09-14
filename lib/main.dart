import 'package:filament_os/core/router/app_router.dart';
import 'package:filament_os/core/theme/app_theme.dart';
import 'package:filament_os/core/theme/theme_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:filament_os/firebase_options.dart';

/// Ponto de entrada: liga o Firebase e só então sobe o app.
///
/// `main` é `async` porque `Firebase.initializeApp` precisa terminar antes do
/// `runApp` — qualquer tela que consulte autenticação no primeiro frame
/// encontraria o Firebase ainda desligado.
///
/// `WidgetsFlutterBinding.ensureInitialized()` é o passo a mais que isso
/// exige. O binding é a ponte entre o Dart e o engine do Flutter, e é ele que
/// cria os platform channels por onde o `initializeApp` fala com o SDK nativo
/// do Firebase. Normalmente o próprio `runApp` o cria por dentro, mas aqui o
/// `await` roda antes do `runApp`: sem esta linha o canal ainda não existe, e
/// o app quebra na inicialização pedindo exatamente essa chamada (verificado
/// comentando a linha).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

/// A raiz do app, e nada além disso.
///
/// Já foi mais do que isso: antes tinha `home: FilamentsPage()` e, com isso,
/// conhecia uma feature. Hoje entrega os três pontos de configuração e não
/// importa tela nenhuma — quem conhece todas é o `AppRouter`, que existe
/// justamente pra centralizar esse conhecimento (ver `AppRouter`).
///
/// `MaterialApp.router` no lugar do `MaterialApp` comum é o que troca o modelo
/// de navegação: sem ele, telas iriam e viriam por `Navigator.push` a partir
/// de quem chama, e o app não teria URL nenhuma pra abrir por deep link.
///
/// `themeMode` lê `themeModeProvider` (`ThemeMode.system` por padrão) em vez
/// de vir fixo — troca de tema pela UI muda esse provider, e é por isso que
/// `AppColors` mantém as duas paletas prontas.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FilamentOS',
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
    );
  }
}
