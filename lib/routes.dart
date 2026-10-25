import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/views/agenda_view.dart';
import 'package:turco/views/clientes_view.dart';
import 'package:turco/views/servicios_view.dart';
import 'package:turco/views/estilistas_view.dart';
import 'package:turco/views/turno_detail_view.dart';
import 'package:turco/views/turno_form_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Configuración de navegación con go_router.
/// - StatefulShellRoute.indexedStack: 4 pestañas (Agenda, Clientes, Servicios, Estilistas)
///   que conservan su estado al cambiar de destino.
/// - Rutas de turno (nuevo / detalle / editar) se abren por encima de la barra inferior
///   usando parentNavigatorKey.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/agenda',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellView(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) => const AgendaView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/clientes',
              builder: (context, state) => const ClientesView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) => const ServiciosView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/estilistas',
              builder: (context, state) => const EstilistasView(),
            ),
          ],
        ),
      ],
    ),
    // Rutas que se abren por encima de la barra inferior (sobre el shell)
    GoRoute(
      path: '/turno/nuevo',
      builder: (context, state) => TurnoFormView(extra: state.extra),
      parentNavigatorKey: _rootNavigatorKey,
    ),
    GoRoute(
      path: '/turno/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TurnoDetailView(turnoId: id);
      },
      parentNavigatorKey: _rootNavigatorKey,
    ),
    GoRoute(
      path: '/turno/:id/editar',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TurnoFormView.esEdicion(turnoId: id);
      },
      parentNavigatorKey: _rootNavigatorKey,
    ),
  ],
);

class ShellView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellView({super.key, required this.navigationShell});

  static const _destinos = [
    ('Agenda', Icons.calendar_today),
    ('Clientes', Icons.people),
    ('Servicios', Icons.content_cut),
    ('Estilistas', Icons.badge),
  ];

  void _ir(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: navigationShell, // las páginas de cada rama
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _ir,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(
          _destinos.length,
          (i) => NavigationDestination(
            icon: Icon(_destinos[i].$2,
                color: i == navigationShell.currentIndex
                    ? tema.colorScheme.primary
                    : tema.colorScheme.onSurfaceVariant),
            selectedIcon: Icon(_destinos[i].$2,
                color: tema.colorScheme.primary),
            label: _destinos[i].$1,
          ),
        ),
      ),
    );
  }
}
