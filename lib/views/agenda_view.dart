import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/viewmodels/agenda_viewmodel.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  final _agenda = ViewModels.instance.agendaVM;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;

    return ListenableBuilder(
      listenable: _agenda,
      builder: (context, _) {
        final turnos = _agenda.turnosConDatos;
        final esDomingo = _agenda.esDomingo;

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Logo(),
                SizedBox(width: 10),
                Text('Turco'),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(ViewModels.instance.themeVM.esModoOscuro
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () {
                  final vm = ViewModels.instance.themeVM;
                  vm.setModo(vm.modo == ModoTema.claro
                      ? ModoTema.oscuro
                      : ModoTema.claro);
                },
                tooltip: 'Cambiar modo de tema',
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BarraFecha(agenda: _agenda),

                if (esDomingo)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Domingo: salón cerrado',
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ResumenTarjeta(
                          label: 'Programados',
                          valor: _agenda.cantidadProgramados.toString(),
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ResumenTarjeta(
                          label: 'Completados',
                          valor: _agenda.cantidadCompletados.toString(),
                          color: cs.tertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ResumenTarjeta(
                          label: 'Ingreso est.',
                          valor: '\$${_agenda.ingresoEstimado.toInt()}',
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _agenda.estilistas.length + 1,
                    separatorBuilder: (context, i) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return _ChipEstilista(
                          label: 'Todos',
                          seleccionado: _agenda.estilistaFiltroId == null,
                          onTap: () => _agenda.cambiarFiltroEstilista(null),
                        );
                      }
                      final e = _agenda.estilistas[i - 1];
                      return _ChipEstilista(
                        label: e.nombre,
                        seleccionado: _agenda.estilistaFiltroId == e.id,
                        onTap: () => _agenda.cambiarFiltroEstilista(e.id),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SegmentedButton<EstadoTurno>(
                    segments: const [
                      ButtonSegment<EstadoTurno>(
                        value: EstadoTurno.programado,
                        label: Text('Program.'),
                      ),
                      ButtonSegment<EstadoTurno>(
                        value: EstadoTurno.completado,
                        label: Text('Complet.'),
                      ),
                      ButtonSegment<EstadoTurno>(
                        value: EstadoTurno.cancelado,
                        label: Text('Cancel.'),
                      ),
                    ],
                    selected: _agenda.estadoFiltro == null
                        ? {EstadoTurno.programado}
                        : {_agenda.estadoFiltro!},
                    onSelectionChanged: (seleccion) {
                      _agenda.cambiarFiltroEstado(
                          seleccion.isEmpty ? null : seleccion.first);
                    },
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                  ),
                ),

                Expanded(
                  child: turnos.isEmpty
                      ? _EstadoVacio()
                      : ListView.builder(
                          itemCount: turnos.length,
                          itemBuilder: (context, i) {
                            final d = turnos[i];
                            final t = d['turno'] as Turno;
                            return _TarjetaTurno(
                              turno: t,
                              cliente: d['cliente'] as String,
                              estilista: d['estilista'] as String,
                              servicios: d['servicios'] as List<Servicio>,
                              onTap: () => context.push('/turno/${t.id}'),
                              onLongPress:
                                  t.estado == EstadoTurno.programado
                                      ? () => _abrirMenuAcciones(t)
                                      : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/turno/nuevo'),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo turno'),
          ),
        );
      },
    );
  }

  void _abrirMenuAcciones(Turno turno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${ViewModels.instance.agendaVM.nombreCliente(turno.clienteId)} · '
          '${turno.fechaHoraInicio.hour.toString().padLeft(2, '0')}:'
          '${turno.fechaHoraInicio.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${turno.servicioIds.join(' + ')} · '
          '${ViewModels.instance.agendaVM.nombreEstilista(turno.estilistaId)}',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _agenda.completarTurno(turno.id);
            },
            child: Text(
              'Marcar como completado',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmarCancelacion(turno);
            },
            child: Text(
              'Cancelar turno',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarCancelacion(Turno turno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Cancelar este turno?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: Text(
          'El horario de ${ViewModels.instance.agendaVM.nombreCliente(turno.clienteId)} '
          '(${turno.fechaHoraInicio.hour.toString().padLeft(2, '0')}:'
          '${turno.fechaHoraInicio.minute.toString().padLeft(2, '0')} a '
          '${turno.fechaHoraFin.hour.toString().padLeft(2, '0')}:'
          '${turno.fechaHoraFin.minute.toString().padLeft(2, '0')}) '
          'quedará libre. Esta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Volver',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _agenda.cancelarTurno(turno.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Turno cancelado.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Cancelar turno',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraFecha extends StatelessWidget {
  final AgendaViewModel agenda;
  const _BarraFecha({required this.agenda});

  Future<void> _elegirFecha(BuildContext context) async {
    final ahora = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: agenda.fecha,
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 90)),
    );
    if (seleccionada != null) agenda.cambiarFecha(seleccionada);
  }

  @override
  Widget build(BuildContext context) {
    final fecha = agenda.fecha;
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: agenda.diaAnterior,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => _elegirFecha(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${meses[fecha.month - 1]} ${fecha.year}',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${fecha.day.toString().padLeft(2, '0')} de ${meses[fecha.month - 1]}',
                    style: TextStyle(
                      fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 28),
            onPressed: agenda.diaSiguiente,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 22),
            onPressed: () => _elegirFecha(context),
            tooltip: 'Elegir fecha',
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.content_cut,
              color: Theme.of(context).colorScheme.onPrimary, size: 18),
    );
  }
}

class _ResumenTarjeta extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  const _ResumenTarjeta({
    required this.label, required this.valor, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extra = context.turco;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.normal,
              color: extra.onDisabledSlot,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipEstilista extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const _ChipEstilista({
    required this.label, required this.seleccionado, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w500,
        color: seleccionado
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      selectedColor: Theme.of(context).colorScheme.secondaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // El círculo se adapta a la altura disponible para no desbordar en
        // pantallas pequeñas; si aun así no cabe, la vista completa se desplaza.
        final lado = constraints.maxHeight.isFinite
            ? (constraints.maxHeight * 0.5).clamp(96.0, 240.0)
            : 240.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 0,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: lado, height: lado,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event_busy, size: 56, color: cs.primary),
                    ),
                    const SizedBox(height: 20),
                    const Text('No hay turnos para este día',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      'Crea el primer turno con el botón de abajo o cambia los filtros.',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaTurno extends StatelessWidget {
  final Turno turno;
  final String cliente;
  final String estilista;
  final List<Servicio> servicios;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _TarjetaTurno({
    required this.turno, required this.cliente, required this.estilista,
    required this.servicios, required this.onTap, this.onLongPress,
  });

  Color _colorEstado(BuildContext context, EstadoTurno e) => switch (e) {
    EstadoTurno.programado => Theme.of(context).colorScheme.primary,
    EstadoTurno.completado => Theme.of(context).colorScheme.tertiary,
    EstadoTurno.cancelado => Theme.of(context).colorScheme.error,
  };

  String _labelEstado(EstadoTurno e) => switch (e) {
    EstadoTurno.programado => 'Programado',
    EstadoTurno.completado => 'Completado',
    EstadoTurno.cancelado => 'Cancelado',
  };

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

  @override
  Widget build(BuildContext context) {
    final inicio = turno.fechaHoraInicio;
    final fin = turno.fechaHoraFin;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 67,
                decoration: BoxDecoration(
                  color: _colorEstado(context, turno.estado),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${inicio.hour.toString().padLeft(2, '0')}:'
                          '${inicio.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${fin.hour.toString().padLeft(2, '0')}:'
                          '${fin.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(cliente, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                    const SizedBox(height: 2),
                    Text(
                      servicios.map((s) => s.nombre).join(' + '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person, size: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(estilista,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _fondoEstado(context, turno.estado),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _labelEstado(turno.estado),
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: _textoEstado(context, turno.estado),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
