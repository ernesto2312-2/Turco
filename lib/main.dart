import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/routes.dart';

void main() {
  MockData.inicializar();
  runApp(const TurcoApp());
}

class TurcoApp extends StatelessWidget {
  const TurcoApp({super.key, this.routerConfig});

  /// Permite inyectar un router propio (pruebas y capturas). Por defecto usa
  /// el router de la aplicación.
  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ViewModels.instance.themeVM,
      builder: (context, child) {
        final tema = ViewModels.instance.themeVM.tema(context);
        return MaterialApp.router(
          title: 'Turco',
          debugShowCheckedModeBanner: false,
          theme: tema,
          darkTheme: AppTheme.temaOscuro(),
          routerConfig: routerConfig ?? appRouter,
        );
      },
    );
  }
}
