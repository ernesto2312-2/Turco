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
