import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/viewmodels/clientes_viewmodel.dart';

class ClientesView extends StatefulWidget {
  const ClientesView({super.key});

  @override
  State<ClientesView> createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {
  final _vm = ViewModels.instance.clientesVM;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final lista = _vm.clientesFiltrados;

        return Scaffold(
          appBar: AppBar(title: const Text('Clientes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => _abrirHojaCliente(context),
                ),
              ]),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _CampoBusqueda(vm: _vm),
                      const SizedBox(height: 10),
                      _SegmentoGenero(vm: _vm),
                      const SizedBox(height: 6),
                      Text(
                        '${_vm.totalClientes} clientes · '
                        '${_vm.totalMujeres} mujeres · ${_vm.totalHombres} hombres',
                        style: tema.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: lista.isEmpty
                      ? const _EstadoVacio()
                      : ListView.separated(
                          itemCount: lista.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1, indent: 16, endIndent: 16,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          itemBuilder: (context, i) {
                            final c = lista[i];
                            return _FilaCliente(
                              vm: _vm,
                              cliente: c,
                              onEditar: () => _abrirHojaCliente(context, c),
                              onEliminar: () {},
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirHojaCliente(context),
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('Nuevo cliente',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _abrirHojaCliente(BuildContext context, [Cliente? cliente]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HojaCliente(vm: _vm, cliente: cliente),
    );
  }
}

class _CampoBusqueda extends StatelessWidget {
  final ClientesViewModel vm;
  const _CampoBusqueda({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o teléfono',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: vm.busqueda.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => vm.cambiarBusqueda(''),
              )
            : null,
      ),
      onChanged: vm.cambiarBusqueda,
    );
  }
}

class _SegmentoGenero extends StatelessWidget {
  final ClientesViewModel vm;
  const _SegmentoGenero({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Genero>(
      segments: const [
        ButtonSegment<Genero>(value: Genero.mujeres, label: Text('Mujeres')),
        ButtonSegment<Genero>(value: Genero.hombres, label: Text('Hombres')),
      ],
      selected: vm.filtroGenero == null
          ? {}
          : {vm.filtroGenero!},
      onSelectionChanged: (s) =>
          vm.cambiarFiltroGenero(s.isEmpty ? null : s.first),
      multiSelectionEnabled: false,
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 56,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          const Text('No hay clientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text('Crea el primer cliente con el botón de abajo.',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FilaCliente extends StatelessWidget {
  final ClientesViewModel vm;
  final Cliente cliente;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const _FilaCliente({
    required this.vm, required this.cliente,
    required this.onEditar, required this.onEliminar,
  });

  Color _colorAvatar(BuildContext context, Genero g) => g == Genero.mujeres
      ? Theme.of(context).colorScheme.primaryContainer
      : context.turco.completedBadge;
  Color _textoAvatar(BuildContext context, Genero g) => g == Genero.mujeres
      ? Theme.of(context).colorScheme.onPrimaryContainer
      : context.turco.onCompletedBadge;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: _colorAvatar(context, cliente.genero),
        child: Text(cliente.nombre.isEmpty ? '?' : cliente.nombre[0],
            style: TextStyle(
              fontSize: 17.6, fontWeight: FontWeight.w600,
              color: _textoAvatar(context, cliente.genero),
            )),
      ),
      title: Text(cliente.nombre, style: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      )),
      subtitle: Text('${cliente.telefono} · ${cliente.genero.label}',
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
      trailing: Text('${cliente.turnosCount} turnos', style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      )),
      onTap: () => _abrirDetalleCliente(context),
    );
  }

  void _abrirDetalleCliente(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HojaDetalleCliente(
            vm: vm,
            cliente: cliente,
            onEditar: onEditar,
            onEliminar: onEliminar,
          ),
    );
  }
}

/// Bottom sheet: datos del cliente + historial de turnos + acciones
class _HojaDetalleCliente extends StatelessWidget {
  final ClientesViewModel vm;
  final Cliente cliente;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const _HojaDetalleCliente({
    required this.vm,
    required this.cliente,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final historial = vm.historialDeCliente(cliente.id);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: vm.clientes.firstWhere(
                      (c) => c.id == cliente.id,
                      orElse: () => cliente,
                    ).genero == Genero.mujeres
                        ? context.turco.completedBadge
                        : Theme.of(context).colorScheme.primaryContainer,
                    child: Text(cliente.nombre.isEmpty ? '?' : cliente.nombre[0],
                        style: TextStyle(
                          fontSize: 22.4, fontWeight: FontWeight.w600,
                          color: cliente.genero == Genero.mujeres
                              ? context.turco.onCompletedBadge
                              : Theme.of(context).colorScheme.onPrimaryContainer,
                        )),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente.nombre, style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(cliente.telefono, style: TextStyle(
                              fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant,
                            )),
                          ],
                        ),
                        if (cliente.correo != null && cliente.correo!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.mail, size: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(cliente.correo!, style: TextStyle(
                                fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant,
                              )),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Historial de turnos · ${historial.length}',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: historial.isEmpty
                  ? Center(
                      child: Text('Sin turnos.',
                          style: TextStyle(
                            fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )))
                  : ListView.builder(
                      controller: controller,
                      itemCount: historial.length,
                      itemBuilder: (context, i) {
                        final t = historial[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 2),
                          title: Text(t.servicioIds.join(' + '),
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                          subtitle: Text(
                            '${t.fechaHoraInicio.day.toString().padLeft(2,'0')}/${t.fechaHoraInicio.month.toString().padLeft(2,'0')} · '
                            '${t.fechaHoraInicio.hour.toString().padLeft(2,'0')}:${t.fechaHoraInicio.minute.toString().padLeft(2,'0')}',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _fondoEstado(context, t.estado),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t.estado.label,
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: _textoEstado(context, t.estado),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          context.push(
                            '/turno/nuevo',
                            extra: cliente.id,
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nuevo turno',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => _abrirEdicion(context),
                      child: const Text('Editar',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => _confirmarEliminar(context, cliente),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: const Icon(Icons.delete_outline, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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

  void _abrirEdicion(BuildContext context) {
    context.pop();
    onEditar();
  }

  void _confirmarEliminar(BuildContext context, Cliente cliente) {
    context.pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Eliminar cliente?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: const Text(
          'Si el cliente tiene turnos programados no se puede eliminar.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              final ok = vm.eliminarCliente(cliente.id);
              Navigator.pop(context);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede eliminar: el cliente tiene turnos programados.',
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text('Eliminar',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: alta / edición de cliente con validaciones
class _HojaCliente extends StatefulWidget {
  final ClientesViewModel vm;
  final Cliente? cliente; // null = alta, no null = edición
  const _HojaCliente({required this.vm, this.cliente});

  @override
  State<_HojaCliente> createState() => _HojaClienteState();
}

class _HojaClienteState extends State<_HojaCliente> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  final _ctrlTelefono = TextEditingController();
  final _ctrlCorreo = TextEditingController();
  Genero? _genero;

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _ctrlNombre.text = widget.cliente!.nombre;
      _ctrlTelefono.text = widget.cliente!.telefono;
      _genero = widget.cliente!.genero;
      _ctrlCorreo.text = widget.cliente!.correo ?? '';
    }
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlTelefono.dispose();
    _ctrlCorreo.dispose();
    super.dispose();
  }

  bool _guardar() {
    if (!_formKey.currentState!.validate()) return false;
    final ok = widget.cliente == null
        ? widget.vm.registrarCliente(
            nombre: _ctrlNombre.text.trim(),
            telefono: _ctrlTelefono.text.trim(),
            genero: _genero!,
            correo: _ctrlCorreo.text.trim().isEmpty
                ? null
                : _ctrlCorreo.text.trim(),
          )
        : widget.vm.editarCliente(
            id: widget.cliente!.id,
            nombre: _ctrlNombre.text.trim(),
            telefono: _ctrlTelefono.text.trim(),
            genero: _genero!,
            correo: _ctrlCorreo.text.trim().isEmpty
                ? null
                : _ctrlCorreo.text.trim(),
          );
    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.cliente == null
              ? 'Cliente registrado.'
              : 'Cliente actualizado.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final esEdicion = widget.cliente != null;
    return Form(
      key: _formKey,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  esEdicion ? 'Editar cliente' : 'Nuevo cliente',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 8),
                    _CampoFormulario(
                      label: 'Nombre',
                      icono: Icons.person,
                      ctrl: _ctrlNombre,
                      validador: widget.vm.validarNombre,
                    ),
                    const SizedBox(height: 16),
                    _CampoFormulario(
                      label: 'Teléfono',
                      icono: Icons.phone,
                      ctrl: _ctrlTelefono,
                      validador: (v) => widget.vm.validarTelefonoUnico(
                        v, widget.cliente?.id),
                      teclado: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _CampoGenero(
                      label: 'Género',
                      valor: _genero,
                      validador: widget.vm.validarGenero,
                      onCambiado: (g) => setState(() => _genero = g),
                    ),
                    const SizedBox(height: 16),
                    _CampoFormulario(
                      label: 'Correo (opcional)',
                      icono: Icons.mail,
                      ctrl: _ctrlCorreo,
                      validador: widget.vm.validarCorreo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              )),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          child: const Text('Guardar cliente',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoFormulario extends StatelessWidget {
  final String label;
  final IconData? icono;
  final TextEditingController ctrl;
    final String? Function(String?)? validador;
  final TextInputType? teclado;
  const _CampoFormulario({
    required this.label, this.icono, required this.ctrl,
    required this.validador, this.teclado,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: ctrl,
      keyboardType: teclado,
      validator: validador,
      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icono != null ? Icon(icono, size: 18) : null,
        errorText: null, // se valida al enviar
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _CampoGenero extends StatelessWidget {
  final String label;
  final Genero? valor;
  final String? Function(Genero?)? validador;
  final ValueChanged<Genero> onCambiado;
  const _CampoGenero({
    required this.label, required this.valor, required this.validador,
    required this.onCambiado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 6),
        SegmentedButton<Genero>(
          segments: const [
            ButtonSegment<Genero>(
              value: Genero.mujeres, label: Text('Mujer'),
            ),
            ButtonSegment<Genero>(
              value: Genero.hombres, label: Text('Hombre'),
            ),
          ],
          selected: valor == null ? {} : {valor!},
          onSelectionChanged: (s) {
            if (s.isNotEmpty) onCambiado(s.first);
          },
          multiSelectionEnabled: false,
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          ),
        ),
      ],
    );
  }
}
