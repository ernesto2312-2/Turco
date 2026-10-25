import 'package:flutter/material.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';

/// Resultado de guardar un turno
enum TurnoFormResultado { exito, error }

/// ViewModel del formulario de turno (crear y editar).
/// Reglas de negocio fuera de los widgets.
class TurnoFormViewModel extends ChangeNotifier {
  // ----- Modo -----
  final bool esEdicion;
  final String? turnoIdExistente;

  // ----- Campos -----
  String? _clienteId;
  String _nombreClienteMostrado = '';
  final Set<String> _servicioIds = {};
  Publico _publicoFiltro = Publico.todos; // se autoajusta al género del cliente
  String? _estilistaId;
  DateTime? _fecha;
  TimeOfDay? _hora;
  String _notas = '';

  // ----- Errores de validación (campo -> mensaje) -----
  final Map<String, String> _errores = {};

  // ----- Estado de cambios sin guardar (para PopScope) -----
  bool _cambiado = false;

  TurnoFormViewModel({this.esEdicion = false, this.turnoIdExistente}) {
    if (esEdicion && turnoIdExistente != null) {
      _cargarTurno(turnoIdExistente!);
    }
  }

  // ----- Getters -----
  String? get clienteId => _clienteId;
  String get nombreClienteMostrado => _nombreClienteMostrado;
  Set<String> get servicioIds => _servicioIds;
  Publico get publicoFiltro => _publicoFiltro;
  String? get estilistaId => _estilistaId;
  DateTime? get fecha => _fecha;
  TimeOfDay? get hora => _hora;
  String get notas => _notas;
  Map<String, String> get errores => Map.unmodifiable(_errores);
  bool get cambiado => _cambiado;

  bool get clienteSeleccionado => _clienteId != null;
  bool get serviciosSeleccionados => _servicioIds.isNotEmpty;
  bool get estilistaSeleccionado => _estilistaId != null;
  bool get fechaSeleccionada => _fecha != null;
  bool get horaSeleccionada => _hora != null;

  /// Categorías de servicios con al menos un servicio disponible
  List<String> get categorias {
    final set = <String>{};
    for (final s in MockData.servicios) {
      set.add(s.categoria);
    }
    return set.toList()..sort();
  }

  List<Servicio> serviciosDeCategoria(String categoria) =>
      MockData.servicios.where((s) => s.categoria == categoria).toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));

  // ----- Resumen siempre visible -----
  int get duracionMinutos {
    int total = 0;
    for (final id in _servicioIds) {
      total += MockData.servicios
          .firstWhere((s) => s.id == id)
          .duracionMinutos;
    }
    return total;
  }

  DateTime? get fechaHoraInicio {
    if (_fecha == null || _hora == null) return null;
    return DateTime(
      _fecha!.year, _fecha!.month, _fecha!.day,
      _hora!.hour, _hora!.minute,
    );
  }

  DateTime? get horaFin {
    final ini = fechaHoraInicio;
    if (ini == null) return null;
    return ini.add(Duration(minutes: duracionMinutos));
  }

  double get precioTotal {
    double total = 0;
    for (final id in _servicioIds) {
      total += MockData.servicios.firstWhere((s) => s.id == id).precio;
    }
    return total;
  }

  // ----- Cargar turno existente (edición) -----
  void _cargarTurno(String id) {
    final t = MockData.turnos.firstWhere((x) => x.id == id);
    _clienteId = t.clienteId;
    _nombreClienteMostrado =
        MockData.clientes.firstWhere((c) => c.id == t.clienteId).nombre;
    _servicioIds.addAll(t.servicioIds);
    _estilistaId = t.estilistaId;
    _fecha = DateTime(
      t.fechaHoraInicio.year, t.fechaHoraInicio.month, t.fechaHoraInicio.day,
    );
    _hora = TimeOfDay(
      hour: t.fechaHoraInicio.hour, minute: t.fechaHoraInicio.minute,
    );
    _notas = t.notas ?? '';
    // público según género del cliente
    final c = MockData.clientes.firstWhere((x) => x.id == t.clienteId);
    _publicoFiltro = _publicoDeGenero(c.genero);
    _marcarCambiado(false);
    notifyListeners();
  }

  // ----- Cliente -----
  void seleccionarCliente(String id, String nombre, Genero genero) {
    _clienteId = id;
    _nombreClienteMostrado = nombre;
    _publicoFiltro = _publicoDeGenero(genero);
    // si el estilista actual deja de ser válido (por filtro público no aplica aquí,
    // el estilista se valida por servicios), mantener
    _marcarCambiado(true);
    notifyListeners();
  }

  Publico _publicoDeGenero(Genero g) => switch (g) {
    Genero.mujeres => Publico.mujeres,
    Genero.hombres => Publico.hombres,
  };

  void cambiarPublicoFiltro(Publico p) {
    _publicoFiltro = p;
    _marcarCambiado(true);
    notifyListeners();
  }

  // ----- Servicios -----
  void toggleServicio(String id) {
    if (_servicioIds.contains(id)) {
      _servicioIds.remove(id);
    } else {
      _servicioIds.add(id);
    }
    // si el estilista elegido deja de ser válido, limpiar y avisar
    final ids = _servicioIds.toList();
    final estilistaSigueValido = MockData.estilistas.any(
      (e) => e.id == _estilistaId && e.realizaTodosLosServicios(ids),
    );
    if (_estilistaId != null && !estilistaSigueValido) {
      _estilistaId = null;
    }
    _marcarCambiado(true);
    _recalcularErrores();
    notifyListeners();
  }

  bool servicioSeleccionado(String id) => _servicioIds.contains(id);

  // ----- Estilista -----
  /// Estilistas válidos para los servicios elegidos (realizan todos)
  List<String> get estilistasValidosIds {
    return MockData.estilistas
        .where((e) => e.realizaTodosLosServicios(_servicioIds.toList()))
        .map((e) => e.id)
        .toList()
      ..sort((a, b) {
        final na = MockData.estilistas.firstWhere((x) => x.id == a).nombre;
        final nb = MockData.estilistas.firstWhere((x) => x.id == b).nombre;
        return na.compareTo(nb);
      });
  }

  String? get nombreEstilistaSeleccionado {
    if (_estilistaId == null) return null;
    return MockData.estilistas.firstWhere((x) => x.id == _estilistaId).nombre;
  }

  void seleccionarEstilista(String id) {
    // solo se permite si realiza todos los servicios elegidos
    final e = MockData.estilistas.firstWhere((x) => x.id == id);
    if (!e.realizaTodosLosServicios(_servicioIds.toList())) return;
    _estilistaId = id;
    _marcarCambiado(true);
    _recalcularErrores();
    notifyListeners();
  }

  void limpiarEstilista() {
    _estilistaId = null;
    notifyListeners();
  }

  // ----- Fecha -----
  /// Fecha válida: no pasada y no domingo
  bool fechaValida(DateTime d) {
    final hoy = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day,
    );
    final dDia = DateTime(d.year, d.month, d.day);
    if (dDia.isBefore(hoy)) return false;
    if (d.weekday == DateTime.sunday) return false;
    return true;
  }

  void setFecha(DateTime d) {
    if (!fechaValida(d)) return;
    _fecha = d;
    // si la hora seleccionada queda en pasado (fecha es hoy y hora ya pasó), limpiar
    if (_hora != null && d.day == DateTime.now().day &&
        d.month == DateTime.now().month &&
        d.year == DateTime.now().year) {
      final ahora = DateTime.now();
      final hSeleccionada = DateTime(
        ahora.year, ahora.month, ahora.day, _hora!.hour, _hora!.minute,
      );
      if (!hSeleccionada.isAfter(ahora)) {
        _hora = null;
      }
    }
    _marcarCambiado(true);
    _recalcularErrores();
    notifyListeners();
  }

  // ----- Hora -----
  /// Todas las franjas de 30 min de 09:00 a 18:30
  List<TimeOfDay> get franjas {
    final lista = <TimeOfDay>[];
    for (var h = 9; h <= 18; h++) {
      lista.add(TimeOfDay(hour: h, minute: 0));
      lista.add(TimeOfDay(hour: h, minute: 30));
    }
    return lista;
  }

  /// ¿Una franja está disponible?
  bool franjaDisponible(TimeOfDay f) {
    if (_fecha == null || _estilistaId == null || _clienteId == null) return false;
    final inicio = DateTime(
      _fecha!.year, _fecha!.month, _fecha!.day, f.hour, f.minute,
    );
    final dur = duracionMinutos;
    if (dur == 0) return false;
    final fin = inicio.add(Duration(minutes: dur));

    // no terminar después de las 19:00
    final limite = DateTime(
      _fecha!.year, _fecha!.month, _fecha!.day, 19, 0,
    );
    if (fin.isAfter(limite)) return false;

    // si es hoy, no franjas pasadas
    final hoy = DateTime.now();
    final esHoy = _fecha!.year == hoy.year &&
        _fecha!.month == hoy.month &&
        _fecha!.day == hoy.day;
    if (esHoy && !inicio.isAfter(hoy)) return false;

    // solape con el estilista o el cliente (excluyendo el turno en edición)
    return !MockData.haySolape(
      _estilistaId!, _clienteId!, inicio, dur,
      turnoIdExcluido: esEdicion ? turnoIdExistente : null,
    );
  }

  /// Lista de franjas con su estado
  List<Map<String, dynamic>> get franjasConEstado {
    return franjas.map((f) {
      return {'franja': f, 'disponible': franjaDisponible(f), 'elegida': _hora == f};
    }).toList();
  }

  bool hayAlgunaFranjaLibre() {
    if (_fecha == null || _estilistaId == null || _clienteId == null) return false;
    return franjas.any(franjaDisponible);
  }

  void setHora(TimeOfDay f) {
    _hora = f;
    _marcarCambiado(true);
    _recalcularErrores();
    notifyListeners();
  }

  void limpiarHora() {
    _hora = null;
    _recalcularErrores();
    notifyListeners();
  }

  // ----- Notas -----
  void setNotas(String v) {
    _notas = v;
    _marcarCambiado(true);
    notifyListeners();
  }

  int get notasLength => _notas.length;

  // ----- Validación completa del formulario -----
  void _recalcularErrores() {
    _errores.clear();
    if (_clienteId == null) {
      _errores['cliente'] = 'Selecciona un cliente';
    }
    if (_servicioIds.isEmpty) {
      _errores['servicios'] = 'Elige al menos un servicio';
    }
    if (_estilistaId == null) {
      _errores['estilista'] = 'Selecciona un estilista';
    }
    if (_fecha == null) {
      _errores['fecha'] = 'Elige una fecha válida (no domingos)';
    }
    if (_hora == null) {
      _errores['hora'] = 'Elige una hora para el turno';
    }
  }

  bool get hayErrores => _errores.isNotEmpty;

  /// Campo con error (para mostrar debajo)
  String? errorDe(String campo) => _errores[campo];

  /// Valida todo y devuelve si es válido
  bool validarTodo() {
    _recalcularErrores();
    // validar solape explícito si hay fecha/hora/estilista/cliente
    if (_clienteId != null &&
        _estilistaId != null &&
        _fecha != null &&
        _hora != null &&
        duracionMinutos > 0) {
      final inicio = DateTime(
        _fecha!.year, _fecha!.month, _fecha!.day, _hora!.hour, _hora!.minute,
      );
      if (MockData.haySolape(
        _estilistaId!, _clienteId!, inicio, duracionMinutos,
        turnoIdExcluido: esEdicion ? turnoIdExistente : null,
      )) {
        _errores['hora'] =
            'Ese horario ya está ocupado por el estilista o el cliente';
        _errores['estilista'] =
            'Ese estilista no está disponible a esa hora';
      }
      // validar que termine antes de las 19:00
      final fin = inicio.add(Duration(minutes: duracionMinutos));
      final limite = DateTime(
        _fecha!.year, _fecha!.month, _fecha!.day, 19, 0,
      );
      if (fin.isAfter(limite)) {
        _errores['hora'] = 'El turno no terminaría antes de las 19:00';
      }
    }
    notifyListeners();
    return _errores.isEmpty;
  }

  void _marcarCambiado(bool v) {
    _cambiado = v;
  }

  /// Guarda (crea o edita) el turno si es válido. Devuelve resultado.
  TurnoFormResultado guardar() {
    if (!validarTodo()) return TurnoFormResultado.error;
    final inicio = fechaHoraInicio!;

    if (esEdicion && turnoIdExistente != null) {
      final idx = MockData.turnos.indexWhere((t) => t.id == turnoIdExistente);
      if (idx == -1) return TurnoFormResultado.error;
      final t = MockData.turnos[idx];
      MockData.turnos[idx] = t.copyWith(
        clienteId: _clienteId!,
        estilistaId: _estilistaId!,
        servicioIds: _servicioIds.toList(),
        fechaHoraInicio: inicio,
        notas: _notas.isEmpty ? null : _notas,
        modificadoEn: DateTime.now(),
      );
    } else {
      final t = Turno(
        id: 't${MockData.turnos.length + 1}',
        clienteId: _clienteId!,
        estilistaId: _estilistaId!,
        servicioIds: _servicioIds.toList(),
        fechaHoraInicio: inicio,
        notas: _notas.isEmpty ? null : _notas,
        creadoEn: DateTime.now(),
      );
      MockData.turnos.add(t);
      registrarTurnoCliente(t.clienteId);
    }
    _marcarCambiado(false);
    notifyListeners();
    return TurnoFormResultado.exito;
  }

  /// Se llama desde PopScope: si hay cambios sin guardar, devuelve false para
  /// mostrar confirmación y no salir.
  bool get tieneCambiosSinGuardar => _cambiado;
}
