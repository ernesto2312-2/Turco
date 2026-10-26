import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/viewmodels/catalogo_viewmodel.dart';

class ServiciosView extends StatefulWidget {
  const ServiciosView({super.key});

  @override
  State<ServiciosView> createState() => _ServiciosViewState();
}

class _ServiciosViewState extends State<ServiciosView> {
  final _vm = ViewModels.instance.catalogoVM;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final lista = _vm.serviciosFiltrados;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Servicios',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                Text('Toca un servicio para reservar',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // chips categoría
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChipCat(
                        label: 'Todas',
                        seleccionado: _vm.filtroCategoria == 'Todas',
                        onTap: () => _vm.cambiarFiltroCategoria('Todas'),
                      ),
                      for (final c in _vm.categorias.where((c) => c != 'Todas'))
                        _ChipCat(
                          label: c,
                          seleccionado: _vm.filtroCategoria == c,
                          onTap: () => _vm.cambiarFiltroCategoria(c),
                        ),
                    ],
                  ),
                ),
                // segmented público
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SegmentedButton<Publico>(
                    segments: const [
                      ButtonSegment<Publico>(
                        value: Publico.todos, label: Text('Todas'),
                      ),
                      ButtonSegment<Publico>(
                        value: Publico.mujeres, label: Text('Mujeres'),
                      ),
                      ButtonSegment<Publico>(
                        value: Publico.hombres, label: Text('Hombres'),
                      ),
                    ],
                    selected: {_vm.filtroPublico},
                    onSelectionChanged: (s) =>
                        _vm.cambiarFiltroPublico(s.first),
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                    ),
                  ),
                ),
                // grid
                Expanded(
                  child: lista.isEmpty
                      ? const _EstadoVacio()
                      : _GridServicios(vm: _vm, lista: lista),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

int _columnas(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 600) return 2;
  if (w < 840) return 3;
  return 4;
}

class _GridServicios extends StatelessWidget {
  final CatalogoViewModel vm;
  final List<Servicio> lista;
  const _GridServicios({required this.vm, required this.lista});

  @override
  Widget build(BuildContext context) {
    final cols = _columnas(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 190,
      ),
      itemCount: lista.length,
      itemBuilder: (context, i) {
        final s = lista[i];
        return _TarjetaServicio(vm: vm, servicio: s);
      },
    );
  }
}

class _ChipCat extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const _ChipCat({required this.label, required this.seleccionado, required this.onTap});

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

class _TarjetaServicio extends StatelessWidget {
  final CatalogoViewModel vm;
  final Servicio servicio;
  const _TarjetaServicio({required this.vm, required this.servicio});

  IconData _iconoCategoria(String c) => switch (c) {
    'Corte' => Icons.content_cut,
    'Color' => Icons.palette,
    'Barba' => Icons.auto_awesome,
    'Tratamiento' => Icons.auto_fix_high,
    'Peinado' => Icons.star,
    _ => Icons.water_drop,
  };

  Color _colorPublico(BuildContext context, Publico p) => switch (p) {
    Publico.mujeres => Theme.of(context).colorScheme.onSecondaryContainer,
    Publico.hombres => context.turco.onCompletedBadge,
    Publico.todos => Theme.of(context).colorScheme.onPrimaryContainer,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/turno/nuevo', extra: servicio.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 76,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconoCategoria(servicio.categoria),
                    size: 36, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 10),
              Text(servicio.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text('${servicio.duracionMinutos} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                  ),
                  Text('\$${servicio.precio.toInt()}', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  )),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(servicio.publico.label, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: _colorPublico(context, servicio.publico),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lado = constraints.maxHeight.isFinite
            ? (constraints.maxHeight * 0.5).clamp(96.0, 200.0)
            : 200.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
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
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.content_cut, size: 56,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text('No hay servicios',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Text('Cambia los filtros para ver más opciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
