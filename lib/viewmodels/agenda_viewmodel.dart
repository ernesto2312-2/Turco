import 'package:flutter/material.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';

/// ViewModel de la pantalla Agenda. Reglas de negocio fuera de los widgets.
class AgendaViewModel extends ChangeNotifier {
  DateTime _fecha = DateTime.now();
  String? _estilistaFiltroId; // null = Todos
  EstadoTurno? _estadoFiltro; // null = Todos

  AgendaViewModel() {
    MockData.inicializar();
  }

  // ----- Fecha -----
  DateTime get fecha => _fecha;
  String get fechaLabel {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final d = _fecha;
    return '${meses[d.month - 1]} ${d.year}';
  }

  bool get esDomingo =>
      _fecha.weekday == DateTime.sunday;

  void cambiarFecha(DateTime fecha) {
    _fecha = DateTime(fecha.year, fecha.month, fecha.day);
    notifyListeners();
  }

  void diaAnterior() => cambiarFecha(_fecha.subtract(const Duration(days: 1)));
  void diaSiguiente() => cambiarFecha(_fecha.add(const Duration(days: 1)));

  // ----- Filtro estilista (chips) -----
  String? get estilistaFiltroId => _estilistaFiltroId;
  List<Estilista> get estilistas => MockData.estilistas;

  void cambiarFiltroEstilista(String? id) {
    _estilistaFiltroId = id;
    notifyListeners();
  }

  // ----- Filtro estado (SegmentedButton) -----
  EstadoTurno? get estadoFiltro => _estadoFiltro;

  void cambiarFiltroEstado(EstadoTurno? estado) {
    _estadoFiltro = estado;
    notifyListeners();
  }

  // ----- Turnos del día filtrados -----
  List<Turno> get turnosDelDia {
    final todos = MockData.turnosDelDia(_fecha);
    return todos.where((t) {
      if (_estilistaFiltroId != null && t.estilistaId != _estilistaFiltroId) {
        return false;
      }
      if (_estadoFiltro != null && t.estado != _estadoFiltro) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));
  }

  // ----- Resumen del día -----
  /// cantidad de turnos programados
  int get cantidadProgramados =>
      turnosDelDia.where((t) => t.estado == EstadoTurno.programado).length;

  /// cantidad de turnos completados
  int get cantidadCompletados =>
      turnosDelDia.where((t) => t.estado == EstadoTurno.completado).length;

  /// ingreso estimado = suma de totales de programados y completados (sin cancelados)
  double get ingresoEstimado =>
      turnosDelDia.where((t) =>
          t.estado == EstadoTurno.programado ||
          t.estado == EstadoTurno.completado).fold(
        0.0, (sum, t) => sum + t.precioTotal,
      );

  // ----- Acciones -----
  /// Marca un turno programado como completado. Devuelve true si cambió.
  bool completarTurno(String turnoId) {
    final idx = MockData.turnos.indexWhere((t) => t.id == turnoId);
    if (idx == -1) return false;
    final t = MockData.turnos[idx];
    if (t.estado != EstadoTurno.programado) return false;
    MockData.turnos[idx] = t.copyWith(
      estado: EstadoTurno.completado,
      modificadoEn: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  /// Cancela un turno programado (libera horario). Devuelve true si cambió.
  bool cancelarTurno(String turnoId) {
    final idx = MockData.turnos.indexWhere((t) => t.id == turnoId);
    if (idx == -1) return false;
    final t = MockData.turnos[idx];
    if (t.estado != EstadoTurno.programado) return false;
    MockData.turnos[idx] = t.copyWith(
      estado: EstadoTurno.cancelado,
      modificadoEn: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  /// Devuelve el nombre del cliente de un turno
  String nombreCliente(String clienteId) {
    final c = MockData.clientes.firstWhere((x) => x.id == clienteId,
        orElse: () => Cliente(
              id: '', nombre: 'Desconocido', telefono: '',
              genero: Genero.mujeres,
            ));
    return c.nombre;
  }

  /// Devuelve el nombre del estilista de un turno
  String nombreEstilista(String estilistaId) {
    final e = MockData.estilistas.firstWhere((x) => x.id == estilistaId,
        orElse: () => Estilista(
              id: '', nombre: 'Desconocido', servicioIds: const [],
            ));
    return e.nombre;
  }

  /// Lista de turnos con datos enriquecidos para mostrar (cliente, estilista, servicios)
  List<Map<String, dynamic>> get turnosConDatos {
    return turnosDelDia.map((t) {
      final servicios = t.servicioIds
          .map((id) => MockData.servicios.firstWhere(
              (s) => s.id == id, orElse: () => MockData.servicios.first))
          .toList();
      return {
        'turno': t,
        'cliente': nombreCliente(t.clienteId),
        'estilista': nombreEstilista(t.estilistaId),
        'servicios': servicios,
      };
    }).toList();
  }
}
