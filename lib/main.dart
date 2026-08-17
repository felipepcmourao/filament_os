import 'package:filament_os/core/router/app_router.dart';
import 'package:filament_os/core/theme/app_theme.dart';
import 'package:filament_os/core/theme/theme_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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
