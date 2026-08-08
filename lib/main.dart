import 'package:filament_os/core/router/app_router.dart';
import 'package:filament_os/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
/// `themeMode: ThemeMode.system` deixa a escolha com o sistema operacional em
/// vez de fixar um tema — e é por isso que `AppColors` mantém as duas paletas.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FilamentOS',
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
