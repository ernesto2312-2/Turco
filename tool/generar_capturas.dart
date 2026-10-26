// Genera las capturas del proyecto renderizando la app real a tamaño de
// teléfono (390x844, la misma medida del diseño) con Poppins y los iconos.
//
// Uso:
//   flutter test tool/generar_capturas.dart
//
// Las imágenes se guardan en capturas/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/main.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/routes.dart';

const Size _tamano = Size(390, 844);
const double _escala = 3.0;
const Key _clave = ValueKey('captura');
const Duration _limite = Duration(seconds: 20);

Future<void> _cargarFuentes() async {
  Future<ByteData> leer(String ruta) async =>
      ByteData.sublistView(File(ruta).readAsBytesSync());

  final poppins = FontLoader('Poppins');
  for (final peso in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    poppins.addFont(leer('assets/fonts/Poppins-$peso.ttf'));
  }
  await poppins.load();

  final raiz = Platform.environment['FLUTTER_ROOT'];
  final rutaIconos = raiz != null
      ? '$raiz/bin/cache/artifacts/material_fonts/materialicons-regular.otf'
      : r'C:\src\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf';
  final iconos = FontLoader('MaterialIcons');
  iconos.addFont(leer(rutaIconos));
  await iconos.load();
}

Future<void> _estabilizar(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    _limite,
  );
}

Future<void> _guardar(WidgetTester tester, String nombre) async {
  await _estabilizar(tester);
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_clave),
  );
  // La captura usa trabajo asíncrono real del motor: debe ir dentro de
  // runAsync o la prueba no termina.
  final bytes = await tester.runAsync(() async {
    final ui.Image imagen = await boundary.toImage(pixelRatio: _escala);
    final ByteData? datos =
        await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    return datos!.buffer.asUint8List();
  });

  final carpeta = Directory('capturas');
  if (!carpeta.existsSync()) carpeta.createSync();
  File('capturas/$nombre.png').writeAsBytesSync(bytes!);
}

void main() {
  setUpAll(() async {
    MockData.inicializar();
    await _cargarFuentes();
  });

  Future<void> preparar(
    WidgetTester tester,
    String ruta, {
    Brightness brillo = Brightness.light,
  }) async {
    tester.view.physicalSize = _tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ViewModels.instance.themeVM.setModo(
      brillo == Brightness.dark ? ModoTema.oscuro : ModoTema.claro,
    );

    await tester.pumpWidget(
      RepaintBoundary(
        key: _clave,
        // Router nuevo por captura: evita arrastrar el estado de la anterior.
        child: TurcoApp(routerConfig: crearRouter(initialLocation: ruta)),
      ),
    );
    await _estabilizar(tester);
  }

  testWidgets('01 agenda', (WidgetTester tester) async {
    await preparar(tester, '/agenda');
    await _guardar(tester, '01_agenda');
  });

  testWidgets('02 agenda oscuro', (WidgetTester tester) async {
    await preparar(tester, '/agenda', brillo: Brightness.dark);
    await _guardar(tester, '02_agenda_oscuro');
  });

  testWidgets('03 clientes', (WidgetTester tester) async {
    await preparar(tester, '/clientes');
    await _guardar(tester, '03_clientes');
  });

  testWidgets('04 servicios', (WidgetTester tester) async {
    await preparar(tester, '/servicios');
    await _guardar(tester, '04_servicios');
  });

  testWidgets('05 servicios filtro mujeres', (WidgetTester tester) async {
    await preparar(tester, '/servicios');
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<Publico>),
        matching: find.text('Mujeres'),
      ),
    );
    await _guardar(tester, '05_servicios_mujeres');
  });

  testWidgets('06 estilistas', (WidgetTester tester) async {
    await preparar(tester, '/estilistas');
    await _guardar(tester, '06_estilistas');
  });

  testWidgets('07 detalle del turno', (WidgetTester tester) async {
    final turno = MockData.turnos
        .firstWhere((Turno t) => t.estado == EstadoTurno.programado);
    await preparar(tester, '/turno/${turno.id}');
    await _guardar(tester, '07_detalle_turno');
  });

  testWidgets('08 nuevo turno', (WidgetTester tester) async {
    await preparar(tester, '/turno/nuevo');
    await _guardar(tester, '08_nuevo_turno');
  });

  testWidgets('09 validacion del formulario', (WidgetTester tester) async {
    await preparar(tester, '/turno/nuevo');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar turno'));
    await _guardar(tester, '09_validacion');
    expect(find.text('Selecciona un cliente'), findsOneWidget);
    expect(find.text('Elige al menos un servicio'), findsOneWidget);
  });

  testWidgets('10 alta de cliente', (WidgetTester tester) async {
    await preparar(tester, '/clientes');
    await tester.tap(find.text('Nuevo cliente'));
    await _guardar(tester, '10_alta_cliente');
  });
}
