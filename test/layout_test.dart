import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:turco/app_theme.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/views/agenda_view.dart';
import 'package:turco/views/clientes_view.dart';
import 'package:turco/views/estilistas_view.dart';
import 'package:turco/views/servicios_view.dart';
import 'package:turco/views/turno_detail_view.dart';
import 'package:turco/views/turno_form_view.dart';

/// Comprueba que ninguna pantalla desborde (overflow) en tamaños de teléfono.
void main() {
  setUpAll(() {
    MockData.inicializar();
  });

  Future<void> comprobar(
    WidgetTester tester,
    Widget pantalla, {
    double ancho = 360,
    double alto = 640,
    Brightness brillo = Brightness.light,
  }) async {
    tester.view.physicalSize = Size(ancho, alto);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brillo == Brightness.dark
            ? AppTheme.temaOscuro()
            : AppTheme.temaClaro(),
        home: pantalla,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'La pantalla ${pantalla.runtimeType} desborda '
          '(${ancho.toInt()}x${alto.toInt()}, $brillo)',
    );
  }

  final turno = MockData.turnos.firstWhere(
    (Turno t) => t.estado == EstadoTurno.programado,
  );

  final pantallas = <String, Widget>{
    'Agenda': const AgendaView(),
    'Clientes': const ClientesView(),
    'Servicios': const ServiciosView(),
    'Estilistas': const EstilistasView(),
    'Detalle del turno': TurnoDetailView(turnoId: turno.id),
    'Nuevo turno': const TurnoFormView(),
    'Editar turno': TurnoFormView.esEdicion(turnoId: turno.id),
  };

  for (final entrada in pantallas.entries) {
    testWidgets('${entrada.key}: sin overflow en 360x640',
        (WidgetTester tester) async {
      await comprobar(tester, entrada.value);
    });

    testWidgets('${entrada.key}: sin overflow en 320x568',
        (WidgetTester tester) async {
      await comprobar(tester, entrada.value, ancho: 320, alto: 568);
    });

    testWidgets('${entrada.key}: sin overflow en modo oscuro',
        (WidgetTester tester) async {
      await comprobar(tester, entrada.value, brillo: Brightness.dark);
    });
  }
}
