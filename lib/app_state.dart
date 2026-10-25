import 'package:turco/viewmodels/agenda_viewmodel.dart';
import 'package:turco/viewmodels/catalogo_viewmodel.dart';
import 'package:turco/viewmodels/clientes_viewmodel.dart';
import 'package:turco/viewmodels/theme_viewmodel.dart';
import 'package:turco/viewmodels/turno_detail_viewmodel.dart';
import 'package:turco/viewmodels/turno_form_viewmodel.dart';

/// Contenedor propio de ViewModels (sin paquetes externos de estado).
/// Cada ViewModel es una única instancia (ChangeNotifier) durante la sesión.
class ViewModels {
  ViewModels._();
  static final ViewModels instance = ViewModels._();

  final themeVM = ThemeViewModel();
  final agendaVM = AgendaViewModel();
  final clientesVM = ClientesViewModel();
  final catalogoVM = CatalogoViewModel();
  TurnoFormViewModel? turnoFormVM;
  TurnoDetailViewModel? turnoDetailVM;

  TurnoFormViewModel formularioTurno({
    bool esEdicion = false,
    String? turnoId,
  }) {
    turnoFormVM = TurnoFormViewModel(
      esEdicion: esEdicion,
      turnoIdExistente: turnoId,
    );
    return turnoFormVM!;
  }

  TurnoDetailViewModel detalleTurno(String turnoId) {
    turnoDetailVM = TurnoDetailViewModel(turnoId);
    return turnoDetailVM!;
  }
}
