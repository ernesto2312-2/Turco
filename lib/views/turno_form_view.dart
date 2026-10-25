import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/viewmodels/turno_form_viewmodel.dart';

class TurnoFormView extends StatefulWidget {
  final bool esEdicion;
  final String? turnoId;
  final Object? extra;
  const TurnoFormView({
    super.key,
    this.esEdicion = false,
    this.turnoId,
    this.extra,
  });

  const TurnoFormView.esEdicion({super.key, required this.turnoId})
      : esEdicion = true,
        extra = null;

  @override
  State<TurnoFormView> createState() => _TurnoFormViewState();
}

class _TurnoFormViewState extends State<TurnoFormView> {
  late final TurnoFormViewModel _vm;

  @override
  void initState() {
    super.initState();
    final extra = widget.extra;
    _vm = ViewModels.instance.formularioTurno(
      esEdicion: widget.esEdicion,
      turnoId: widget.turnoId,
    );
    if (extra != null && extra is String) {
      final c = MockData.clientes.where((x) => x.id == extra).firstOrNull;
      if (c != null) {
        _vm.seleccionarCliente(c.id, c.nombre, c.genero);
      } else {
        final s = MockData.servicios.where((x) => x.id == extra).firstOrNull;
        if (s != null) _vm.toggleServicio(s.id);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;

    return PopScope(
      canPop: !_vm.tieneCambiosSinGuardar,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_vm.tieneCambiosSinGuardar) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: const Text('¿Descartar los cambios?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            content: const Text(
              'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Seguir editando',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: Text('Descartar',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text('Nuevo turno'),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CampoCliente(vm: _vm),
                          const SizedBox(height: 14),
                          _BotonCrearCliente(),
                          const SizedBox(height: 16),
                          Text('Servicios para', style: tema.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          _SegmentoPublico(vm: _vm),
                          const SizedBox(height: 16),
                          Text('Servicios', style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                          const SizedBox(height: 10),
                          ..._categoriasServicios(_vm),
                          if (_vm.errorDe('servicios') != null) ...[
                            const SizedBox(height: 6),
                            Text(_vm.errorDe('servicios')!,
                                style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).colorScheme.error,
                                )),
                          ],
                          const SizedBox(height: 16),
                          _CampoEstilista(vm: _vm),
                          if (_vm.errorDe('estilista') != null) ...[
                            const SizedBox(height: 6),
                            Text(_vm.errorDe('estilista')!,
                                style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).colorScheme.error,
                                )),
                          ],
                          const SizedBox(height: 24),
                          _CampoFecha(vm: _vm),
                          const SizedBox(height: 16),
                          _CuadriculaFranjas(vm: _vm),
                          if (_vm.errorDe('hora') != null) ...[
                            const SizedBox(height: 6),
                            Text(_vm.errorDe('hora')!,
                                style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).colorScheme.error,
                                )),
                          ],
                          const SizedBox(height: 24),
                          _CampoNotas(vm: _vm),
                        ],
                      ),
                    ),
                  ),
                  _BarraInferior(vm: _vm, cs: cs),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _categoriasServicios(TurnoFormViewModel vm) {
    final out = <Widget>[];
    for (final cat in vm.categorias) {
      final lista = MockData.servicios
          .where((s) => s.categoria == cat)
          .where((s) {
            if (vm.publicoFiltro == Publico.todos) return true;
            return s.publico == vm.publicoFiltro;
          }).toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));
      if (lista.isEmpty) continue;
      out.add(_CategoriaServicios(vm: vm, categoria: cat, servicios: lista));
    }
    return out;
  }
}

// ---------- Subwidgets ----------

class _CampoCliente extends StatelessWidget {
  final TurnoFormViewModel vm;
  const _CampoCliente({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cliente', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 6),
        FormField<String>(
          validator: (_) => vm.clienteId == null ? 'Selecciona un cliente' : null,
          builder: (estado) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _abrirSelectorCliente(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: vm.clienteId == null
                          ? 'Selecciona un cliente'
                          : vm.nombreClienteMostrado,
                      prefixIcon: const Icon(Icons.person, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: estado.hasError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: estado.hasError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorText: estado.hasError ? estado.errorText : null,
                      errorMaxLines: 2,
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                    child: const Icon(Icons.arrow_drop_down, size: 20),
                  ),
                ),
                if (estado.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(estado.errorText!,
                        style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.error,
                        )),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _abrirSelectorCliente(BuildContext context) async {
    final seleccionado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: MockData.clientes.length,
          itemBuilder: (context, i) {
            final c = MockData.clientes[i];
            final yaSeleccionado = vm.clienteId == c.id;
            return ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: c.genero == Genero.mujeres
                    ? Theme.of(context).colorScheme.primaryContainer
                    : context.turco.completedBadge,
                child: Text(c.nombre.isEmpty ? '?' : c.nombre[0],
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: c.genero == Genero.mujeres
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : context.turco.onCompletedBadge,
                    )),
              ),
              title: Text(c.nombre, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              )),
              subtitle: Text('${c.telefono} · ${c.genero.label}',
                  style: TextStyle(
                    fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
              trailing: yaSeleccionado
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () => Navigator.pop(context, c.id),
            );
          },
        );
      },
    );
    if (seleccionado != null) {
      final c = MockData.clientes.firstWhere((x) => x.id == seleccionado);
      vm.seleccionarCliente(c.id, c.nombre, c.genero);
    }
  }
}

class _BotonCrearCliente extends StatelessWidget {
  const _BotonCrearCliente();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/clientes'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text('Crear cliente nuevo',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ],
        ),
      ),
    );
  }
}

class _SegmentoPublico extends StatelessWidget {
  final TurnoFormViewModel vm;
  const _SegmentoPublico({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Publico>(
      segments: const [
        ButtonSegment<Publico>(value: Publico.todos, label: Text('Todos')),
        ButtonSegment<Publico>(value: Publico.mujeres, label: Text('Mujeres')),
        ButtonSegment<Publico>(value: Publico.hombres, label: Text('Hombres')),
      ],
      selected: {vm.publicoFiltro},
      onSelectionChanged: (s) => vm.cambiarPublicoFiltro(s.first),
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      ),
    );
  }
}

class _CategoriaServicios extends StatelessWidget {
  final TurnoFormViewModel vm;
  final String categoria;
  final List<Servicio> servicios;
  const _CategoriaServicios({
    required this.vm, required this.categoria, required this.servicios,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(categoria, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: servicios.map((s) {
            final sel = vm.servicioSeleccionado(s.id);
            return FilterChip(
              label: Text(s.nombre),
              selected: sel,
              onSelected: (_) => vm.toggleServicio(s.id),
              labelStyle: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: sel ? Theme.of(context).colorScheme.onSecondaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedColor: Theme.of(context).colorScheme.secondaryContainer,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CampoEstilista extends StatelessWidget {
  final TurnoFormViewModel vm;
  const _CampoEstilista({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estilista', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 6),
        FormField<String>(
          validator: (_) => vm.estilistaId == null
              ? 'Selecciona un estilista' : null,
          builder: (estado) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _abrirSelectorEstilista(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: vm.estilistaId == null
                          ? 'Primero elige los servicios'
                          : vm.nombreEstilistaSeleccionado,
                      prefixIcon: const Icon(Icons.person, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: estado.hasError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: estado.hasError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorText: estado.hasError ? estado.errorText : null,
                      errorMaxLines: 2,
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                    child: const Icon(Icons.arrow_drop_down, size: 20),
                  ),
                ),
                if (estado.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(estado.errorText!,
                        style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.error,
                        )),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _abrirSelectorEstilista(BuildContext context) async {
    final ids = vm.estilistasValidosIds;
    if (ids.isEmpty) return;
    final resultado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: ids.length,
          itemBuilder: (context, i) {
            final id = ids[i];
            final e = MockData.estilistas.firstWhere((x) => x.id == id);
            final yaSeleccionado = vm.estilistaId == id;
            return ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(e.nombre.isEmpty ? '?' : e.nombre[0],
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )),
              ),
              title: Text(e.nombre, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              )),
              subtitle: Text('${e.turnosHoy} turnos hoy',
                  style: TextStyle(
                    fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
              trailing: yaSeleccionado
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () => Navigator.pop(context, id),
            );
          },
        );
      },
    );
    if (resultado != null) vm.seleccionarEstilista(resultado);
  }
}

class _CampoFecha extends StatelessWidget {
  final TurnoFormViewModel vm;
  const _CampoFecha({required this.vm});

  Future<void> _elegirFecha(BuildContext context) async {
    final ahora = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: vm.fecha ?? ahora,
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 90)),
    );
    if (seleccionada != null) vm.setFecha(seleccionada);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fecha', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 6),
        FormField<DateTime>(
          validator: (_) => vm.fecha == null
              ? 'Elige una fecha válida (no domingos)' : null,
          builder: (estado) {
            return InkWell(
              onTap: () => _elegirFecha(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: vm.fecha == null
                      ? 'Selecciona una fecha'
                      : '${vm.fecha!.day}/${vm.fecha!.month}/${vm.fecha!.year}',
                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: estado.hasError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: estado.hasError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorText: estado.hasError ? estado.errorText : null,
                  errorMaxLines: 2,
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                ),
                child: const Icon(Icons.arrow_drop_down, size: 20),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CuadriculaFranjas extends StatelessWidget {
  final TurnoFormViewModel vm;
  const _CuadriculaFranjas({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hora de inicio', style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        Row(
          children: [
            _ItemLeyenda(color: context.turco.disabledSlot, label: 'No disponible'),
            const SizedBox(width: 12),
            _ItemLeyenda(color: Theme.of(context).colorScheme.primary, label: 'Elegida'),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.1,
          ),
          itemCount: vm.franjasConEstado.length,
          itemBuilder: (context, i) {
            final d = vm.franjasConEstado[i];
            final f = d['franja'] as TimeOfDay;
            final dis = d['disponible'] as bool;
            final elegida = d['elegida'] as bool;
            return _Franja(
              franja: f,
              disponible: dis,
              elegida: elegida,
              onTap: dis ? () => vm.setHora(f) : null,
            );
          },
        ),
        if (!vm.hayAlgunaFranjaLibre())
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('No hay franjas disponibles para estos servicios y estilista.',
                style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.error,
                )),
          ),
      ],
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String label;
  const _ItemLeyenda({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
          fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
      ],
    );
  }
}

class _Franja extends StatelessWidget {
  final TimeOfDay franja;
  final bool disponible;
  final bool elegida;
  final VoidCallback? onTap;
  const _Franja({
    required this.franja, required this.disponible, required this.elegida,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = franja.hour.toString().padLeft(2, '0');
    final m = franja.minute.toString().padLeft(2, '0');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: elegida
              ? Theme.of(context).colorScheme.primary
              : (disponible
                  ? Theme.of(context).colorScheme.surface
                  : context.turco.disabledSlot),
          borderRadius: BorderRadius.circular(10),
          border: disponible
              ? Border.all(color: Theme.of(context).colorScheme.outline)
              : null,
        ),
        child: Center(
          child: Text('$h:$m', style: TextStyle(
            fontSize: 13,
            fontWeight: elegida ? FontWeight.w600 : FontWeight.w500,
            color: elegida
                ? Theme.of(context).colorScheme.onPrimary
                : (disponible ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outline),
          )),
        ),
      ),
    );
  }
}

class _CampoNotas extends StatelessWidget {
  final TurnoFormViewModel vm;
  const _CampoNotas({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notas (opcional)', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 6),
        FormField<String>(
          validator: (_) {
            if (vm.notas.length > 500) return 'Máximo 500 caracteres';
            return null;
          },
          builder: (estado) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 84, maxHeight: 140),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: estado.hasError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: vm.notas),
                    onChanged: vm.setNotas,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      fontSize: 14, color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe notas opcionales...',
                      hintStyle: TextStyle(
                        fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('${vm.notasLength} / 500', style: TextStyle(
                    fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
                ),
                if (estado.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(estado.errorText!,
                        style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.error,
                        )),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BarraInferior extends StatelessWidget {
  final TurnoFormViewModel vm;
  final ColorScheme cs;
  const _BarraInferior({required this.vm, required this.cs});

  @override
  Widget build(BuildContext context) {
    final ini = vm.fechaHoraInicio;
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _ItemResumen(
                  icono: Icons.access_time,
                  texto: '${vm.duracionMinutos} min',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const Spacer(),
                _ItemResumen(
                  icono: Icons.flag,
                  texto: ini == null
                      ? 'Fin --:--'
                      : 'Fin ${ini.hour.toString().padLeft(2,'0')}:${ini.minute.toString().padLeft(2,'0')}',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const Spacer(),
                _ItemResumen(
                  icono: Icons.attach_money,
                  texto: '\$${vm.precioTotal.toInt()}',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  peso: FontWeight.w700,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
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
                  child: FilledButton(
                    onPressed: () {
                      final r = vm.guardar();
                      if (r == TurnoFormResultado.exito) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 8),
                        Text('Guardar turno'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemResumen extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final FontWeight? peso;
  const _ItemResumen({
    required this.icono, required this.texto, required this.color, this.peso,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(
          fontSize: 13, fontWeight: peso ?? FontWeight.w600,
          color: color,
        )),
      ],
    );
  }
}
