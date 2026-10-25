import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/viewmodels/turno_detail_viewmodel.dart';

class TurnoDetailView extends StatefulWidget {
  final String turnoId;
  const TurnoDetailView({super.key, required this.turnoId});

  @override
  State<TurnoDetailView> createState() => _TurnoDetailViewState();
}

class _TurnoDetailViewState extends State<TurnoDetailView> {
  late final TurnoDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ViewModels.instance.detalleTurno(widget.turnoId);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (!_vm.existe) {
          return _NoEncontrado(tema: tema);
        }
        final t = _vm.turno!;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => context.pop(),
            ),
            title: const Text('Detalle del turno'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Tarjeta horario
                _TarjetaHorario(vm: _vm, tema: tema, cs: cs),
                const SizedBox(height: 12),
                // Servicios
                _TarjetaServicios(t: t, cs: cs),
                const SizedBox(height: 12),
                // Notas
                _TarjetaNotas(t: t, cs: cs),
                const SizedBox(height: 12),
                // creado/modificado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Creado el ${_fecha(t.creadoEn)} · '
                    'Modificado el ${_fecha(t.modificadoEn ?? t.creadoEn)}',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // acciones
                if (t.estado == EstadoTurno.programado) ...[
                  _BotonesAccion(
                    tema: tema, cs: cs, vm: _vm, turno: t, context: context,
                  ),
                ] else ...[
                  _SoloLectura(cs: cs),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
}

class _NoEncontrado extends StatelessWidget {
  final ThemeData tema;
  const _NoEncontrado({required this.tema});

  @override
  Widget build(BuildContext context) {
    final cs = tema.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detalle del turno'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 56, color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 20),
            const Text('No encontramos este turno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('El turno no existe o ya no está disponible.',
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, size: 18),
                    SizedBox(width: 8),
                    Text('Volver a la agenda'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaHorario extends StatelessWidget {
  final TurnoDetailViewModel vm;
  final ThemeData tema;
  final ColorScheme cs;
  const _TarjetaHorario({required this.vm, required this.tema, required this.cs});

  @override
  Widget build(BuildContext context) {
    final t = vm.turno!;
    final ini = t.fechaHoraInicio;
    final fin = t.fechaHoraFin;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(vm.nombreCliente.isEmpty ? '?' : vm.nombreCliente[0],
                      style: TextStyle(
                        fontSize: 19.2, fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.nombreCliente, style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(vm.telefonoCliente, style: TextStyle(
                            fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                        ],
                      ),
                      if (t.notas != null && t.notas!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.mail, size: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('carlos.ruiz@correo.com', style: TextStyle(
                              fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant,
                            )),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _fondoEstado(context, t.estado),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(t.estado.label, style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: _textoEstado(context, t.estado),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DatoFecha(cs: cs, icono: Icons.calendar_today,
                label: 'Fecha',
                valor: '${ini.day}/${ini.month}/${ini.year} ${_nombreMes(ini.month)} ${ini.year}'),
            const SizedBox(height: 8),
            _DatoFecha(cs: cs, icono: Icons.access_time,
                label: 'Hora',
                valor: '${ini.hour.toString().padLeft(2,'0')}:${ini.minute.toString().padLeft(2,'0')} a '
                    '${fin.hour.toString().padLeft(2,'0')}:${fin.minute.toString().padLeft(2,'0')} '
                    '(${t.duracionMinutos(vm.servicios)} min)'),
            const SizedBox(height: 8),
            _DatoFecha(cs: cs, icono: Icons.person,
                label: 'Estilista',
                valor: vm.nombreEstilista),
          ],
        ),
      ),
    );
  }

  String _nombreMes(int m) => const [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ][m - 1];

  Color _fondoEstado(BuildContext context, EstadoTurno e) => switch (e) {
    EstadoTurno.programado => Theme.of(context).colorScheme.primaryContainer,
    EstadoTurno.completado => context.turco.completedBadge,
    EstadoTurno.cancelado => Theme.of(context).colorScheme.errorContainer,
  };

  Color _textoEstado(BuildContext context, EstadoTurno e) => switch (e) {
    EstadoTurno.programado => Theme.of(context).colorScheme.onPrimaryContainer,
    EstadoTurno.completado => context.turco.onCompletedBadge,
    EstadoTurno.cancelado => Theme.of(context).colorScheme.onErrorContainer,
  };
}

class _DatoFecha extends StatelessWidget {
  final ColorScheme cs;
  final IconData icono;
  final String label;
  final String valor;
  const _DatoFecha({
    required this.cs, required this.icono, required this.label, required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
            const SizedBox(height: 2),
            Text(valor, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            )),
          ],
        ),
      ],
    );
  }
}

class _TarjetaServicios extends StatelessWidget {
  final Turno t;
  final ColorScheme cs;
  const _TarjetaServicios({required this.t, required this.cs});

  @override
  Widget build(BuildContext context) {
    final servicios = t.servicioIds.map((id) =>
        MockData.servicios.firstWhere((s) => s.id == id)).toList();
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicios', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            )),
            const SizedBox(height: 10),
            ...servicios.map((s) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.nombre, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                    subtitle: Text('${s.duracionMinutos} min',
                        style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                    trailing: Text('\$${s.precio.toInt()}', style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                  ),
                  if (s != servicios.last)
                    Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                ],
              );
            }),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Total', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              )),
              trailing: Text('\$${t.precioTotal.toInt()}', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaNotas extends StatelessWidget {
  final Turno t;
  final ColorScheme cs;
  const _TarjetaNotas({required this.t, required this.cs});

  @override
  Widget build(BuildContext context) {
    final notas = t.notas ?? '';
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notas', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            )),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Text(notas.isEmpty ? 'Sin notas.' : notas,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SoloLectura extends StatelessWidget {
  final ColorScheme cs;
  const _SoloLectura({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.lock, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Turno completado: solo lectura', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
          ),
        ],
      ),
    );
  }
}

class _BotonesAccion extends StatelessWidget {
  final ThemeData tema;
  final ColorScheme cs;
  final TurnoDetailViewModel vm;
  final Turno turno;
  final BuildContext context;
  const _BotonesAccion({
    required this.tema, required this.cs, required this.vm,
    required this.turno, required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/turno/${turno.id}/editar'),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () => _confirmar(turno.estado == EstadoTurno.programado
                  ? '¿Marcar como completado?'
                  : '¿Cancelar este turno?',
                  accion: () {
                    final ok = turno.estado == EstadoTurno.programado
                        ? vm.completar()
                        : vm.cancelar();
                    if (ok) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(turno.estado == EstadoTurno.programado
                              ? 'Turno completado.'
                              : 'Turno cancelado.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(turno.estado == EstadoTurno.programado
                  ? 'Completar'
                  : 'Cancelar',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmar(String titulo, {required VoidCallback accion}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Volver',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () { Navigator.pop(context); accion(); },
            child: Text(turno.estado == EstadoTurno.programado
                ? 'Marcar como completado'
                : 'Cancelar turno',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
