import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/app_state.dart';
import 'package:turco/app_theme.dart';
import 'package:turco/models/modelos.dart';
import 'package:turco/viewmodels/catalogo_viewmodel.dart';

class EstilistasView extends StatefulWidget {
  const EstilistasView({super.key});

  @override
  State<EstilistasView> createState() => _EstilistasViewState();
}

class _EstilistasViewState extends State<EstilistasView> {
  final _vm = ViewModels.instance.catalogoVM;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final estilistas = _vm.estilistas;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 170,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1,
                titlePadding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.contact_page,
              size: 28, color: Theme.of(context).colorScheme.onPrimary),
                    const SizedBox(height: 12),
                    Text('Estilistas',
                        style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
                    const SizedBox(height: 6),
                    Text(
                      '${estilistas.length} profesionales · ${estilistas.fold(0, (s, e) => s + e.turnosHoy)} turnos programados hoy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13, color: context.turco.appBarSubtitle,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  color: cs.primary,
                ),
              ),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final e = estilistas[i];
                    return _TarjetaEstilista(vm: _vm, estilista: e);
                  },
                  childCount: estilistas.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaEstilista extends StatelessWidget {
  final CatalogoViewModel vm;
  final Estilista estilista;
  const _TarjetaEstilista({required this.vm, required this.estilista});

  @override
  Widget build(BuildContext context) {
    final agrupados = vm.serviciosDeEstilistaAgrupados(estilista.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/agenda?estilista=${estilista.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(estilista.nombre.isEmpty ? '?' : estilista.nombre[0],
                    style: TextStyle(
                      fontSize: 22.4, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(estilista.nombre, style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: agrupados.entries.expand((entry) {
                        return entry.value.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(s.nombre, style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            )),
                          );
                        }).toList();
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${estilista.turnosHoy} turnos hoy',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (estilista.turnosHoy == 0) ...[
                          const SizedBox(width: 6),
                          Text('Sin turnos hoy', style: TextStyle(
                            fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 22,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
