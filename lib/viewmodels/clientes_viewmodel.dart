import 'package:flutter/material.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';

/// Expresión regular para validar correo (si se escribe)
final RegExp _correoRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

/// Elimina acentos y pasa a minúsculas para búsqueda
String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâäã]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll(RegExp(r'[ñ]'), 'n');
}

/// ViewModel de la pantalla Clientes.
class ClientesViewModel extends ChangeNotifier {
  Genero? _filtroGenero; // null = Todos
  String _busqueda = '';

  List<Cliente> get clientes => MockData.clientes;
  List<Cliente> get clientesFiltrados {
    final q = _normalizar(_busqueda);
    return MockData.clientes.where((c) {
      final coincideGenero = _filtroGenero == null || c.genero == _filtroGenero;
      final coincideBusqueda = q.isEmpty ||
          _normalizar(c.nombre).contains(q) ||
          c.telefono.contains(_busqueda); // teléfono sin normalizar (solo dígitos)
      return coincideGenero && coincideBusqueda;
    }).toList();
  }

  int get totalClientes => MockData.clientes.length;
  int get totalMujeres =>
      MockData.clientes.where((c) => c.genero == Genero.mujeres).length;
  int get totalHombres =>
      MockData.clientes.where((c) => c.genero == Genero.hombres).length;

  Genero? get filtroGenero => _filtroGenero;
  String get busqueda => _busqueda;

  void cambiarFiltroGenero(Genero? g) {
    _filtroGenero = g;
    notifyListeners();
  }

  void cambiarBusqueda(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  // ----- Validaciones de cliente -----
  String? validarNombre(String? v) {
    if (v == null || v.isEmpty) return 'Nombre obligatorio';
    if (v.length < 3 || v.length > 60) {
      return 'Escribe entre 3 y 60 caracteres';
    }
    return null;
  }

  String? validarTelefono(String? v) {
    if (v == null || v.isEmpty) return 'Teléfono obligatorio';
    if (v.length != 8 || !RegExp(r'^\d{8}$').hasMatch(v)) {
      return 'Debe tener exactamente 8 dígitos';
    }
    return null;
  }

  String? validarTelefonoUnico(String? v, String? clienteIdExcluido) {
    final err = validarTelefono(v);
    if (err != null) return err;
    final repetido = MockData.clientes.any((c) =>
        c.id != clienteIdExcluido && c.telefono == v);
    if (repetido) return 'El teléfono ya está registrado';
    return null;
  }

  String? validarGenero(Genero? g) {
    if (g == null) return 'Selecciona un género';
    return null;
  }

  String? validarCorreo(String? v) {
    if (v == null || v.isEmpty) return null; // opcional
    if (!_correoRegex.hasMatch(v)) return 'Escribe un correo válido';
    return null;
  }

  // ----- CRUD -----
  bool registrarCliente({
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final errNom = validarNombre(nombre);
    final errTel = validarTelefonoUnico(telefono, null);
    final errGen = validarGenero(genero);
    final errCor = validarCorreo(correo);
    if (errNom != null || errTel != null || errGen != null || errCor != null) {
      return false;
    }
    final c = Cliente(
      id: 'c${MockData.clientes.length + 1}',
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: correo?.isEmpty == null ? null : correo,
    );
    MockData.clientes.add(c);
    notifyListeners();
    return true;
  }

  bool editarCliente({
    required String id,
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final idx = MockData.clientes.indexWhere((c) => c.id == id);
    if (idx == -1) return false;
    final errNom = validarNombre(nombre);
    final errTel = validarTelefonoUnico(telefono, id);
    final errGen = validarGenero(genero);
    final errCor = validarCorreo(correo);
    if (errNom != null || errTel != null || errGen != null || errCor != null) {
      return false;
    }
    MockData.clientes[idx] = MockData.clientes[idx].copyWith(
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: correo?.isEmpty == true ? null : correo,
    );
    notifyListeners();
    return true;
  }

  /// Elimina un cliente. Devuelve false si tiene turnos programados (no se puede).
  /// Si no tiene, elimina con confirmación y devuelve true.
  bool eliminarCliente(String id) {
    final tieneProgramados = MockData.turnos.any((t) =>
        t.clienteId == id && t.estado == EstadoTurno.programado);
    if (tieneProgramados) return false;
    MockData.clientes.removeWhere((x) => x.id == id);
    // borrar su historial de turnos completados y cancelados
    MockData.turnos.removeWhere((t) =>
        t.clienteId == id &&
        (t.estado == EstadoTurno.completado ||
            t.estado == EstadoTurno.cancelado));
    notifyListeners();
    return true;
  }

  /// Historial de turnos de un cliente
  List<Turno> historialDeCliente(String id) =>
      MockData.turnos.where((t) => t.clienteId == id).toList()
        ..sort((a, b) => b.fechaHoraInicio.compareTo(a.fechaHoraInicio));
}
