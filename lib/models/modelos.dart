/// Entidad Cliente
class Cliente {
  final String id;
  final String nombre;
  final String telefono; // 8 dígitos, único
  final Genero genero;
  final String? correo;

  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
  });

  Cliente copyWith({
    String? id,
    String? nombre,
    String? telefono,
    Genero? genero,
    String? correo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      genero: genero ?? this.genero,
      correo: correo ?? this.correo,
    );
  }

  int get turnosCount => _turnosCache[id] ?? 0;
}

enum Genero { mujeres, hombres }

extension GeneroExtension on Genero {
  String get label => switch (this) {
    Genero.mujeres => 'Mujer',
    Genero.hombres => 'Hombre',
  };
}

/// Mapa temporal de conteo de turnos por cliente (se mantiene en ViewModel)
final Map<String, int> _turnosCache = {};

void reiniciarConteoClientes() => _turnosCache.clear();

void registrarTurnoCliente(String clienteId) {
  _turnosCache[clienteId] = (_turnosCache[clienteId] ?? 0) + 1;
}

void desregistrarTurnoCliente(String clienteId) {
  if (_turnosCache.containsKey(clienteId)) {
    final actual = _turnosCache[clienteId]! - 1;
    _turnosCache[clienteId] = actual < 0 ? 0 : actual;
  }
}

/// Entidad Servicio (solo lectura)
class Servicio {
  final String id;
  final String nombre;
  final String categoria;
  final int duracionMinutos;
  final double precio;
  final Publico publico;

  Servicio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionMinutos,
    required this.precio,
    required this.publico,
  });
}

enum Publico { todos, mujeres, hombres }

extension PublicoExtension on Publico {
  String get label => switch (this) {
    Publico.todos => 'Todas',
    Publico.mujeres => 'Mujeres',
    Publico.hombres => 'Hombres',
  };
}

/// Entidad Estilista
class Estilista {
  final String id;
  final String nombre;
  final List<String> servicioIds; // ids de servicios que realiza
  int turnosHoy;

  Estilista({
    required this.id,
    required this.nombre,
    required this.servicioIds,
    this.turnosHoy = 0,
  });

  bool realizaServicio(String servicioId) => servicioIds.contains(servicioId);

  bool realizaTodosLosServicios(List<String> ids) =>
      ids.every((id) => servicioIds.contains(id));
}

/// Entidad Turno
class Turno {
  final String id;
  final String clienteId;
  final String estilistaId;
  final List<String> servicioIds;
  final DateTime fechaHoraInicio;
  final String? notas; // máx 500 chars
  final EstadoTurno estado;
  final DateTime creadoEn;
  final DateTime? modificadoEn;

  Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.servicioIds,
    required this.fechaHoraInicio,
    this.notas,
    this.estado = EstadoTurno.programado,
    required this.creadoEn,
    this.modificadoEn,
  });

  /// Duración total = suma de duraciones de sus servicios (se calcula, no se guarda)
  int duracionMinutos(Iterable<Servicio> servicios) =>
      servicios.fold(0, (sum, s) => sum + s.duracionMinutos);

  /// Hora de fin (se calcula)
  DateTime get fechaHoraFin =>
      fechaHoraInicio.add(Duration(minutes: duracionMinutos(
          servicioIds.map((id) => _serviciosCache[id]!))));

  /// Precio total (se calcula)
  double get precioTotal =>
      servicioIds.fold(0.0, (sum, id) {
        final s = _serviciosCache[id]!;
        return sum + s.precio;
      });

  Turno copyWith({
    String? id,
    String? clienteId,
    String? estilistaId,
    List<String>? servicioIds,
    DateTime? fechaHoraInicio,
    String? notas,
    EstadoTurno? estado,
    DateTime? creadoEn,
    DateTime? modificadoEn,
  }) {
    return Turno(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      estilistaId: estilistaId ?? this.estilistaId,
      servicioIds: servicioIds ?? this.servicioIds,
      fechaHoraInicio: fechaHoraInicio ?? this.fechaHoraInicio,
      notas: notas ?? this.notas,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
      modificadoEn: modificadoEn ?? this.modificadoEn,
    );
  }

  bool get solapaConOtro => false; // se valida en ViewModel
}

// Cache temporal para cálculos derivados (se inyecta desde ViewModel)
final Map<String, Servicio> _serviciosCache = {};

void inyectarServicios(List<Servicio> servicios) {
  _serviciosCache.clear();
  for (final s in servicios) {
    _serviciosCache[s.id] = s;
  }
}

enum EstadoTurno { programado, completado, cancelado }

extension EstadoTurnoExtension on EstadoTurno {
  String get label => switch (this) {
    EstadoTurno.programado => 'Programado',
    EstadoTurno.completado => 'Completado',
    EstadoTurno.cancelado => 'Cancelado',
  };

  // Solo los programados se pueden editar, completar o cancelar
  bool get editable => this == EstadoTurno.programado;
}
