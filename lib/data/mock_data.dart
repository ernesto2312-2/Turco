import 'package:turco/models/modelos.dart';

/// Datos de prueba cargados en memoria al iniciar la app.
/// Las fechas se calculan a partir de DateTime.now() para que no queden vencidas.
class MockData {
  static final DateTime ahora = DateTime.now();

  // ----- Servicios (12, 5 categorías) -----
  static final List<Servicio> servicios = [
    Servicio(
      id: 's1', nombre: 'Corte mujer', categoria: 'Corte',
      duracionMinutos: 60, precio: 30, publico: Publico.mujeres,
    ),
    Servicio(
      id: 's2', nombre: 'Corte caballero', categoria: 'Corte',
      duracionMinutos: 45, precio: 25, publico: Publico.hombres,
    ),
    Servicio(
      id: 's3', nombre: 'Corte clásico', categoria: 'Corte',
      duracionMinutos: 45, precio: 28, publico: Publico.todos,
    ),
    Servicio(
      id: 's4', nombre: 'Color completo', categoria: 'Color',
      duracionMinutos: 120, precio: 70, publico: Publico.mujeres,
    ),
    Servicio(
      id: 's5', nombre: 'Color raíces', categoria: 'Color',
      duracionMinutos: 60, precio: 45, publico: Publico.todos,
    ),
    Servicio(
      id: 's6', nombre: 'Barba', categoria: 'Barba',
      duracionMinutos: 45, precio: 20, publico: Publico.hombres,
    ),
    Servicio(
      id: 's7', nombre: 'Afeitado', categoria: 'Barba',
      duracionMinutos: 30, precio: 15, publico: Publico.hombres,
    ),
    Servicio(
      id: 's8', nombre: 'Hidratación', categoria: 'Tratamiento',
      duracionMinutos: 45, precio: 28, publico: Publico.todos,
    ),
    Servicio(
      id: 's9', nombre: 'Keratina', categoria: 'Tratamiento',
      duracionMinutos: 90, precio: 60, publico: Publico.mujeres,
    ),
    Servicio(
      id: 's10', nombre: 'Peinado evento', categoria: 'Peinado',
      duracionMinutos: 60, precio: 40, publico: Publico.todos,
    ),
    Servicio(
      id: 's11', nombre: 'Peinado novia', categoria: 'Peinado',
      duracionMinutos: 120, precio: 80, publico: Publico.mujeres,
    ),
    Servicio(
      id: 's12', nombre: 'Cejas', categoria: 'Tratamiento',
      duracionMinutos: 20, precio: 10, publico: Publico.todos,
    ),
  ];

  // Categorías: Corte, Color, Barba, Tratamiento, Peinado (5)
  // Solo mujeres: s1, s4, s9, s11 (4 ≥3)  Solo hombres: s2, s6, s7 (3 ≥3)  Unisex: s3, s5, s8, s10, s12 (5 ≥3)

  static final List<Servicio> serviciosMujeres =
      servicios.where((s) => s.publico == Publico.mujeres).toList();
  static final List<Servicio> serviciosHombres =
      servicios.where((s) => s.publico == Publico.hombres).toList();
  static final List<Servicio> serviciosUnisex =
      servicios.where((s) => s.publico == Publico.todos).toList();

  // ----- Estilistas (5) -----
  static final List<Estilista> estilistas = [
    Estilista(
      id: 'e1', nombre: 'Marta Salazar',
      servicioIds: ['s1', 's3', 's4', 's5', 's8', 's9', 's10', 's12'],
      turnosHoy: 3,
    ), // ambos
    Estilista(
      id: 'e2', nombre: 'Pedro Vega',
      servicioIds: ['s2', 's3', 's6', 's7'],
      turnosHoy: 2,
    ), // solo hombres
    Estilista(
      id: 'e3', nombre: 'Lucía Torres',
      servicioIds: ['s1', 's4', 's5', 's8', 's9', 's11', 's12'],
      turnosHoy: 0,
    ), // solo mujeres
    Estilista(
      id: 'e4', nombre: 'Rafael Núñez',
      servicioIds: ['s2', 's3', 's6', 's7'],
      turnosHoy: 2,
    ), // solo hombres
    Estilista(
      id: 'e5', nombre: 'Elena Gómez',
      servicioIds: ['s1', 's3', 's4', 's5', 's10', 's11', 's12'],
      turnosHoy: 1,
    ), // ambos
  ];

  static final Estilista estilistaSoloHombres1 = estilistas[1]; // Pedro
  static final Estilista estilistaSoloHombres2 = estilistas[3]; // Rafael
  static final Estilista estilistaSoloMujeres = estilistas[2]; // Lucía
  static final Estilista estilistaAmbos1 = estilistas[0]; // Marta
  static final Estilista estilistaAmbos2 = estilistas[4]; // Elena

  // ----- Clientes (10, 5 mujeres 5 hombres) -----
  static final List<Cliente> clientes = [
    Cliente(id: 'c1', nombre: 'Laura Gómez', telefono: '52111222', genero: Genero.mujeres),
    Cliente(id: 'c2', nombre: 'Carlos Ruiz', telefono: '52345678', genero: Genero.hombres),
    Cliente(id: 'c3', nombre: 'Ana Martín', telefono: '53220140', genero: Genero.mujeres),
    Cliente(id: 'c4', nombre: 'Diego Pérez', telefono: '55908771', genero: Genero.hombres),
    Cliente(id: 'c5', nombre: 'Sofía Díaz', telefono: '54667310', genero: Genero.mujeres),
    Cliente(id: 'c6', nombre: 'Javier Soto', telefono: '52774009', genero: Genero.hombres), // sin turnos
    Cliente(id: 'c7', nombre: 'Marta Peña', telefono: '53441902', genero: Genero.mujeres),
    Cliente(id: 'c8', nombre: 'Carlos Méndez', telefono: '56123456', genero: Genero.hombres),
    Cliente(id: 'c9', nombre: 'Luis Ramírez', telefono: '58987654', genero: Genero.hombres),
    Cliente(id: 'c10', nombre: 'Elena Torres', telefono: '51234567', genero: Genero.mujeres),
  ];

  static int _secuenciaTurno = 0;
  static String _nuevoIdTurno() => 't${++_secuenciaTurno}';

  static DateTime _dia(int offsetDias, {int hora = 9, int minuto = 0}) {
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    return hoy.add(Duration(days: offsetDias, hours: hora, minutes: minuto));
  }

  static const String _notasLargas =
      'Prefiere la máquina en el número 2 a los lados. Llega siempre diez minutos '
      'antes y pide agua. No le gusta la música alta, prefiere silencio o '
      'conversación ligera. Tiene alergia al esmalte de uñas con formaldehído, '
      'evitar productos que lo contengan. Siempre pide que se le explique cada '
      'paso antes de hacerlo.';

  // ----- Turnos (16, 7 días) -----
  static final List<Turno> turnos = [
    // HOY (8 programados) -- offset 0
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c1', estilistaId: 'e1',
      servicioIds: ['s1'],
      fechaHoraInicio: _dia(0, hora: 9, minuto: 0),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 10),
    ), // Laura Gómez - Corte mujer - Marta
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c2', estilistaId: 'e2',
      servicioIds: ['s2', 's6', 's8'], // 3 servicios
      fechaHoraInicio: _dia(0, hora: 10, minuto: 0),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 11),
    ), // Carlos Ruiz - Corte+Barba+Hidratación - Pedro
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c3', estilistaId: 'e1',
      servicioIds: ['s4', 's10'], notas: _notasLargas,
      fechaHoraInicio: _dia(0, hora: 10, minuto: 30),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 12),
    ), // Ana Martín - Color+Peinado - Marta (notas >300)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c4', estilistaId: 'e2',
      servicioIds: ['s6'],
      fechaHoraInicio: _dia(0, hora: 12, minuto: 0),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 13),
    ), // Diego Pérez - Barba - Pedro
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c5', estilistaId: 'e4',
      servicioIds: ['s7'],
      fechaHoraInicio: _dia(0, hora: 18, minuto: 30),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 14),
      modificadoEn: _dia(0, hora: 8),
    ), // Sofía Díaz - Afeitado - Rafael (termina 19:00 exactamente)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c8', estilistaId: 'e1',
      servicioIds: ['s1'],
      fechaHoraInicio: _dia(0, hora: 14, minuto: 0),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 15),
    ), // Carla Méndez - Corte mujer - Marta (sin notas)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c10', estilistaId: 'e5',
      servicioIds: ['s8'],
      fechaHoraInicio: _dia(0, hora: 15, minuto: 30),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 16),
    ), // Elena Torres - Hidratación - Elena Gómez
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c7', estilistaId: 'e4',
      servicioIds: ['s6'],
      fechaHoraInicio: _dia(0, hora: 11, minuto: 30),
      estado: EstadoTurno.programado,
      creadoEn: _dia(-1, hora: 17),
    ), // Marta Peña - Barba - Rafael

    // AYER / PASADO -- completados
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c7', estilistaId: 'e2',
      servicioIds: ['s2'],
      fechaHoraInicio: _dia(-1, hora: 14, minuto: 0),
      estado: EstadoTurno.completado,
      creadoEn: _dia(-2, hora: 9),
      modificadoEn: _dia(-1, hora: 15),
    ), // Marta Peña - Corte caballero - Pedro (Completado)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c9', estilistaId: 'e4',
      servicioIds: ['s6'],
      fechaHoraInicio: _dia(-1, hora: 16, minuto: 0),
      estado: EstadoTurno.completado,
      creadoEn: _dia(-2, hora: 10),
      modificadoEn: _dia(-1, hora: 17),
    ), // Luis Ramírez - Barba - Rafael (Completado)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c3', estilistaId: 'e3',
      servicioIds: ['s9'],
      fechaHoraInicio: _dia(-2, hora: 11, minuto: 0),
      estado: EstadoTurno.completado,
      creadoEn: _dia(-3, hora: 8),
      modificadoEn: _dia(-2, hora: 12),
    ), // Ana Martín - Keratina - Lucía (Completado)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c8', estilistaId: 'e2',
      servicioIds: ['s3'],
      fechaHoraInicio: _dia(-2, hora: 16, minuto: 30),
      estado: EstadoTurno.completado,
      creadoEn: _dia(-3, hora: 14),
      modificadoEn: _dia(-2, hora: 17),
    ), // Carlos Méndez - Corte clásico - Pedro (Completado)

    // CANCELADOS (no ocupan horario)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c2', estilistaId: 'e1',
      servicioIds: ['s3'],
      fechaHoraInicio: _dia(1, hora: 9, minuto: 0),
      estado: EstadoTurno.cancelado,
      creadoEn: _dia(0, hora: 8),
    ), // Carlos Ruiz - Corte clásico - Marta (Cancelado mañana)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c4', estilistaId: 'e4',
      servicioIds: ['s6'],
      fechaHoraInicio: _dia(-1, hora: 10, minuto: 0),
      estado: EstadoTurno.cancelado,
      creadoEn: _dia(-2, hora: 9),
    ), // Diego Pérez - Barba - Rafael (Cancelado ayer)

    // MAÑANA -- programados
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c3', estilistaId: 'e5',
      servicioIds: ['s12'],
      fechaHoraInicio: _dia(1, hora: 11, minuto: 0),
      estado: EstadoTurno.programado,
      creadoEn: _dia(0, hora: 9),
    ), // Ana Martín - Cejas - Elena Gómez (mañana)
    Turno(
      id: _nuevoIdTurno(), clienteId: 'c9', estilistaId: 'e5',
      servicioIds: ['s5'],
      fechaHoraInicio: _dia(1, hora: 17, minuto: 0),
      estado: EstadoTurno.programado,
      creadoEn: _dia(0, hora: 10),
    ), // Luis Ramírez - Color raíces - Elena Gómez (mañana)
  ];

  static void inicializar() {
    reiniciarConteoClientes();
    inyectarServicios(servicios);
    // conteo de turnos por cliente (solo programados y completados, no cancelados)
    for (final t in turnos) {
      if (t.estado != EstadoTurno.cancelado) {
        registrarTurnoCliente(t.clienteId);
      }
    }
  }

  /// Turnos de un día dado (fecha sin hora)
  static List<Turno> turnosDelDia(DateTime dia) {
    final inicio = DateTime(dia.year, dia.month, dia.day);
    final fin = inicio.add(const Duration(days: 1));
    return turnos.where((t) =>
        t.fechaHoraInicio.isAfter(inicio.subtract(const Duration(seconds: 1))) &&
        t.fechaHoraInicio.isBefore(fin)).toList()
      ..sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));
  }

  /// Turnos de un estilista en un día
  static List<Turno> turnosDeEstilistaEnDia(String estilistaId, DateTime dia) =>
      turnosDelDia(dia).where((t) => t.estilistaId == estilistaId).toList();

  /// Turnos de un cliente en un día
  static List<Turno> turnosDeClienteEnDia(String clienteId, DateTime dia) =>
      turnosDelDia(dia).where((t) => t.clienteId == clienteId).toList();

  /// Solapes entre turnos programados (mismo estilista o mismo cliente, excluyendo cancelados)
  static bool haySolape(String estilistaId, String clienteId, DateTime inicio,
      int duracionMinutos, {String? turnoIdExcluido}) {
    final fin = inicio.add(Duration(minutes: duracionMinutos));
    for (final t in turnos) {
      if (t.estado == EstadoTurno.cancelado) continue;
      if (t.id == turnoIdExcluido) continue;
      final tInicio = t.fechaHoraInicio;
      final tFin = t.fechaHoraFin;
      final mismoDia = tInicio.day == inicio.day &&
          tInicio.month == inicio.month &&
          tInicio.year == inicio.year;
      if (!mismoDia) continue;
      final mismoEstilista = t.estilistaId == estilistaId;
      final mismoCliente = t.clienteId == clienteId;
      if (!mismoEstilista && !mismoCliente) continue;
      // solape si se intersectan (fin exclusivo: si termina a las 10 y otro empieza a las 10, no solapa)
      if (inicio.isBefore(tFin) && fin.isAfter(tInicio)) return true;
    }
    return false;
  }
}
