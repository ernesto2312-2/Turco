import 'package:flutter/material.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/routes.dart';

void main() {
  MockData.inicializar();
  runApp(const TurcoApp());
}

class TurcoApp extends StatelessWidget {
  const TurcoApp({super.key});

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
          routerConfig: appRouter,
        );
      },
    );
  }
}
