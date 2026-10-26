import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:turco/data/mock_data.dart';
import 'package:turco/main.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/routes.dart';

const Key _k = ValueKey('captura');

void _log(String s) =>
    File('capturas/debug.log').writeAsStringSync('$s\n', mode: FileMode.append);

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

Future<void> _capturar(WidgetTester tester, String nombre) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_k));
  final bytes = await tester.runAsync(() async {
    final ui.Image imagen = await boundary.toImage(pixelRatio: 3);
    final ByteData? datos =
        await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    return datos!.buffer.asUint8List();
  });
  File('capturas/$nombre.png').writeAsBytesSync(bytes!);
  _log('guardado $nombre ${bytes.length}');
}

void main() {
  setUpAll(() async {
    Directory('capturas').createSync(recursive: true);
    File('capturas/debug.log').writeAsStringSync('inicio\n');
    MockData.inicializar();
    await _cargarFuentes();
  });

  testWidgets('debug servicios filtro', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      RepaintBoundary(
        key: _k,
        child: TurcoApp(routerConfig: crearRouter(initialLocation: '/servicios')),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<Publico>),
        matching: find.text('Mujeres'),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
    await _capturar(tester, '05_a');

    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    await _capturar(tester, '05_b');

    _log('fin');
  });
}
