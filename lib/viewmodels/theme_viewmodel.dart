import 'package:flutter/material.dart';
import 'package:turco/app_theme.dart';

class ThemeViewModel extends ChangeNotifier {
  ModoTema _modo = ModoTema.sistema;

  ModoTema get modo => _modo;

  bool get esModoOscuro => _modo == ModoTema.oscuro ||
      (_modo == ModoTema.sistema &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  /// Guarda la preferencia y notifica. La persistencia real es solo en memoria
  /// (el enunciado prohíbe almacenamiento local).
  void setModo(ModoTema modo) {
    _modo = modo;
    notifyListeners();
  }

  ThemeData tema(BuildContext context) {
    return AppTheme.build(_modo, MediaQuery.of(context).platformBrightness);
  }
}
