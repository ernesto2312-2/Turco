import 'package:flutter/material.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';

/// ViewModel ligero de Detalle de turno. Solo lectura salvo completar/cancelar.
class TurnoDetailViewModel extends ChangeNotifier {
  final String turnoId;

  TurnoDetailViewModel(this.turnoId);

  Turno? get turno => MockData.turnos.where((t) => t.id == turnoId).firstOrNull;

  bool get existe => turno != null;

  String get nombreCliente {
    final t = turno;
    if (t == null) return '';
    return MockData.clientes.firstWhere(
      (c) => c.id == t.clienteId,
      orElse: () => Cliente(
            id: '', nombre: 'Desconocido', telefono: '',
            genero: Genero.mujeres,
          ),
    ).nombre;
  }

  String get telefonoCliente {
    final t = turno;
    if (t == null) return '';
    return MockData.clientes.firstWhere(
      (c) => c.id == t.clienteId,
      orElse: () => Cliente(
            id: '', nombre: 'Desconocido', telefono: '',
            genero: Genero.mujeres,
          ),
    ).telefono;
  }

  String? get correoCliente {
    final t = turno;
    if (t == null) return null;
    final correo = MockData.clientes
        .firstWhere(
          (c) => c.id == t.clienteId,
          orElse: () => Cliente(
                id: '', nombre: 'Desconocido', telefono: '',
                genero: Genero.mujeres,
              ),
        )
        .correo;
    return (correo == null || correo.isEmpty) ? null : correo;
  }

  String get nombreEstilista {
    final t = turno;
    if (t == null) return '';
    return MockData.estilistas.firstWhere(
      (e) => e.id == t.estilistaId,
      orElse: () => Estilista(id: '', nombre: 'Desconocido', servicioIds: const []),
    ).nombre;
  }

  List<Servicio> get servicios {
    final t = turno;
    if (t == null) return const [];
    return t.servicioIds.map((id) =>
        MockData.servicios.firstWhere((s) => s.id == id)).toList();
  }

  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static const _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String get fechaTexto {
    final t = turno;
    if (t == null) return '';
    final i = t.fechaHoraInicio;
    return '${_dias[i.weekday - 1]} ${i.day} de ${_meses[i.month - 1]} de ${i.year}';
  }

  String get horaTexto {
    final t = turno;
    if (t == null) return '';
    final minutos = t.duracionMinutos(servicios);
    final h = minutos ~/ 60;
    final m = minutos % 60;
    final duracion = h == 0
        ? '$m min'
        : (m == 0 ? '$h h' : '$h h $m min');
    return '${_hhmm(t.fechaHoraInicio)} a ${_hhmm(t.fechaHoraFin)} ($duracion)';
  }

  bool completar() {
    final t = turno;
    if (t == null || t.estado != EstadoTurno.programado) return false;
    final idx = MockData.turnos.indexWhere((x) => x.id == turnoId);
    MockData.turnos[idx] = t.copyWith(
      estado: EstadoTurno.completado,
      modificadoEn: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  bool cancelar() {
    final t = turno;
    if (t == null || t.estado != EstadoTurno.programado) return false;
    final idx = MockData.turnos.indexWhere((x) => x.id == turnoId);
    MockData.turnos[idx] = t.copyWith(
      estado: EstadoTurno.cancelado,
      modificadoEn: DateTime.now(),
    );
    notifyListeners();
    return true;
  }
}
