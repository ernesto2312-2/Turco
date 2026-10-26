import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/viewmodels/catalogo_viewmodel.dart';
import 'package:turco/viewmodels/turno_form_viewmodel.dart';
import 'package:turco/views/servicios_view.dart';

void main() {
  setUpAll(MockData.inicializar);

  List<Servicio> visibles(TurnoFormViewModel vm) =>
      vm.categorias.expand((c) => vm.serviciosDeCategoria(c)).toList();

  test('catálogo: el filtro Mujeres incluye los servicios para todos', () {
    final vm = CatalogoViewModel()..cambiarFiltroPublico(Publico.mujeres);

    expect(vm.serviciosFiltrados, isNotEmpty);
    expect(
      vm.serviciosFiltrados.every((s) => s.disponiblePara(Publico.mujeres)),
      isTrue,
    );
    expect(vm.serviciosFiltrados.any((s) => s.publico == Publico.todos), isTrue);
    expect(vm.serviciosFiltrados.any((s) => s.nombre == 'Corte mujer'), isTrue);
    expect(
      vm.serviciosFiltrados.any((s) => s.nombre == 'Corte caballero'),
      isFalse,
    );
  });

  test('catálogo: el filtro Hombres incluye los servicios para todos', () {
    final vm = CatalogoViewModel()..cambiarFiltroPublico(Publico.hombres);

    expect(
      vm.serviciosFiltrados.every((s) => s.disponiblePara(Publico.hombres)),
      isTrue,
    );
    expect(vm.serviciosFiltrados.any((s) => s.nombre == 'Barba'), isTrue);
    expect(vm.serviciosFiltrados.any((s) => s.nombre == 'Corte mujer'), isFalse);
  });

  test('catálogo: categoría y público se combinan', () {
    final vm = CatalogoViewModel()
      ..cambiarFiltroPublico(Publico.mujeres)
      ..cambiarFiltroCategoria('Color');

    final nombres = vm.serviciosFiltrados.map((s) => s.nombre).toList();
    expect(nombres, containsAll(['Color completo', 'Color raíces']));
  });

  test('formulario: el filtro limita los servicios mostrados', () {
    final vm = TurnoFormViewModel()..cambiarPublicoFiltro(Publico.hombres);

    final servicios = visibles(vm);
    expect(servicios, isNotEmpty);
    expect(
      servicios.every((s) => s.disponiblePara(Publico.hombres)),
      isTrue,
    );
    expect(servicios.any((s) => s.nombre == 'Corte caballero'), isTrue);
    expect(servicios.any((s) => s.nombre == 'Corte mujer'), isFalse);
  });

  test('formulario: al cambiar el filtro se quitan los servicios incompatibles',
      () {
    final vm = TurnoFormViewModel()
      ..cambiarPublicoFiltro(Publico.mujeres)
      ..toggleServicio('s1') // Corte mujer
      ..toggleServicio('s3'); // Corte clásico (para todos)

    expect(vm.servicioSeleccionado('s1'), isTrue);

    vm.cambiarPublicoFiltro(Publico.hombres);

    expect(vm.servicioSeleccionado('s1'), isFalse);
    expect(vm.servicioSeleccionado('s3'), isTrue);
  });

  test('formulario: al elegir un cliente el filtro se ajusta a su género', () {
    final vm = TurnoFormViewModel();

    vm.seleccionarCliente('c2', 'Carlos Ruiz', Genero.hombres);
    expect(vm.publicoFiltro, Publico.hombres);

    vm.seleccionarCliente('c1', 'Laura Gómez', Genero.mujeres);
    expect(vm.publicoFiltro, Publico.mujeres);
  });

  testWidgets('la pantalla de Servicios aplica el filtro de público',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final vm = ViewModels.instance.catalogoVM
      ..cambiarFiltroCategoria('Todas')
      ..cambiarFiltroPublico(Publico.todos);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.temaClaro(), home: const ServiciosView()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Afeitado'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<Publico>),
        matching: find.text('Mujeres'),
      ),
    );
    await tester.pumpAndSettle();

    expect(vm.filtroPublico, Publico.mujeres);
    expect(find.text('Afeitado'), findsNothing);
    expect(find.text('Corte mujer'), findsOneWidget);
    expect(find.text('Color completo'), findsOneWidget);
  });
}
