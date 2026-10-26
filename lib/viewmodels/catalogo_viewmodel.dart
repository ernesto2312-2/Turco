import 'package:flutter/material.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';

/// ViewModel compartido para Servicios y Estilistas (catálogos de solo lectura).
class CatalogoViewModel extends ChangeNotifier {
  String _filtroCategoria = 'Todas';
  Publico _filtroPublico = Publico.todos;

  List<Servicio> get servicios => MockData.servicios;
  List<Estilista> get estilistas => MockData.estilistas;

  String get filtroCategoria => _filtroCategoria;
  Publico get filtroPublico => _filtroPublico;

  // ----- Servicios filtrados -----
  List<Servicio> get serviciosFiltrados {
    return MockData.servicios.where((s) {
      final coincideCat = _filtroCategoria == 'Todas' ||
          s.categoria == _filtroCategoria;
      final coincidePub =
          _filtroPublico == Publico.todos || s.disponiblePara(_filtroPublico);
      return coincideCat && coincidePub;
    }).toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  List<String> get categorias {
    final set = <String>{'Todas'};
    for (final s in MockData.servicios) {
      set.add(s.categoria);
    }
    return set.toList()..sort();
  }

  void cambiarFiltroCategoria(String categoria) {
    _filtroCategoria = categoria;
    notifyListeners();
  }

  void cambiarFiltroPublico(Publico publico) {
    _filtroPublico = publico;
    notifyListeners();
  }

  /// Servicios de una categoría (para agrupar en el detalle de estilista)
  List<Servicio> serviciosDeCategoria(String categoria) =>
      MockData.servicios.where((s) => s.categoria == categoria).toList();

  /// Servicios que realiza un estilista, agrupados por categoría
  Map<String, List<Servicio>> serviciosDeEstilistaAgrupados(String estilistaId) {
    final e = MockData.estilistas.firstWhere(
      (x) => x.id == estilistaId,
      orElse: () => Estilista(id: '', nombre: '', servicioIds: const []),
    );
    final resultado = <String, List<Servicio>>{};
    for (final id in e.servicioIds) {
      final s = MockData.servicios.firstWhere((x) => x.id == id);
      resultado.putIfAbsent(s.categoria, () => []).add(s);
    }
    // ordenar categorías alfabéticamente y servicios dentro de cada una
    final ordenado = <String, List<Servicio>>{};
    for (final cat in resultado.keys.toList()..sort()) {
      ordenado[cat] = resultado[cat]!..sort((a, b) => a.nombre.compareTo(b.nombre));
    }
    return ordenado;
  }

  /// ¿El estilista realiza todos los servicios dados?
  bool estilistaValidoParaServicios(String estilistaId, List<String> servicioIds) {
    final e = MockData.estilistas.firstWhere(
      (x) => x.id == estilistaId,
      orElse: () => Estilista(id: '', nombre: '', servicioIds: const []),
    );
    return e.realizaTodosLosServicios(servicioIds);
  }

  /// Estilistas válidos para un conjunto de servicios (realizan todos)
  List<Estilista> estilistasValidos(List<String> servicioIds) {
    return MockData.estilistas.where((e) =>
        e.realizaTodosLosServicios(servicioIds)).toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  /// Turnos programados hoy de un estilista
  int turnosHoyDeEstilista(String id) =>
      MockData.estilistas.firstWhere((x) => x.id == id).turnosHoy;
}
