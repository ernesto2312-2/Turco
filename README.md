# Turco

Aplicación Flutter para la gestión de turnos de una peluquería. Trabajo práctico
correspondiente al **Primer Examen Parcial** de Programación Móvil.

- **Nombre:** Turco
- **Application ID:** `com.ernestoquintana.turco`
- **Plataforma:** Android
- **Estado:** todas las pantallas y reglas de negocio implementadas, en memoria
  (sin servidor, sin base de datos y sin autenticación).

## Funcionalidades

### Agenda
- Franja de días navegable con `ListView.builder` (14 días centrados en hoy).
- Lista de turnos del día con `ListView.builder`, ordenados por hora.
- Filtros por estilista y por estado.
- Acciones rápidas por turno: ver detalle, editar, completar y cancelar.
- Domingo cerrado: muestra el mensaje de día sin atención.
- Botón flotante **Nuevo turno**.
- Atajo desde Estilistas: `/agenda?estilista=3` deja el filtro aplicado.

### Clientes
- Búsqueda por nombre o teléfono.
- Lista con `ListView.separated`.
- Alta y edición en un *bottom sheet* con formulario validado.
- Ficha con historial de turnos y total gastado.
- Baja permitida solo si el cliente no tiene turnos programados.

### Servicios
- Catálogo en `GridView.builder` con 2 / 3 / 4 columnas según el ancho
  (menos de 600 dp, entre 600 y 840 dp, más de 840 dp).
- Filtro por categoría y por público (mujeres, hombres, todos).
- Muestra duración, precio y cantidad de estilistas que lo realizan.
- Tocar un servicio abre el formulario con ese servicio ya seleccionado.

### Estilistas
- `CustomScrollView` con `SliverAppBar` y `SliverList`.
- Tarjeta por estilista con sus servicios agrupados por categoría.
- Botón para saltar a la agenda filtrada por ese estilista.

### Detalle del turno
- Datos del cliente, estilista, servicios, duración total y precio total.
- Estado con color y etiqueta.
- Notas completas.
- Editar, completar y cancelar según el estado.

### Nuevo turno / Editar turno
- Selección de cliente, estilista, servicios, fecha y hora.
- Franjas de 30 minutos de 9:00 a 19:00 con `GridView.builder`.
- Franja deshabilitada si el estilista está ocupado, si el cliente ya tiene
  turno, si el turno terminaría después de las 19:00 o si ya pasó la hora.
- Resumen con duración y precio calculados.
- Notas opcionales (máximo 500 caracteres).
- Aviso al salir con cambios sin guardar (`PopScope`).

## Reglas de negocio

Implementadas en modelos y ViewModels, nunca en los widgets:

- Atención de lunes a sábado, de 9:00 a 19:00. Domingos cerrado.
- Franjas de 30 minutos.
- Ningún turno puede terminar después de las 19:00.
- Un estilista solo puede realizar turnos con servicios que él ofrece (todos los
  servicios elegidos).
- Sin solapamiento para el estilista ni para el cliente.
- Los turnos cancelados liberan la franja.
- El teléfono del cliente es único y debe tener exactamente 8 dígitos.
- Los turnos nunca se eliminan.
- Solo los turnos `programado` se pueden editar, completar o cancelar.

## Arquitectura

MVVM con `ChangeNotifier`, sin gestores de estado externos.

```
lib/
├── main.dart                  entrada de la app
├── app_state.dart             instancia única de los ViewModels
├── app_theme.dart             tema claro/oscuro global + colores extra
├── routes.dart                go_router (StatefulShellRoute)
├── models/modelos.dart        Cliente, Servicio, Estilista, Turno
├── data/mock_data.dart        datos de prueba generados desde DateTime.now()
├── viewmodels/                lógica de presentación y reglas de negocio
└── views/                     las 6 pantallas
```

### Navegación

| Ruta | Pantalla |
|---|---|
| `/agenda` | Agenda |
| `/agenda?estilista=3` | Agenda filtrada por estilista |
| `/clientes` | Clientes |
| `/servicios` | Servicios |
| `/estilistas` | Estilistas |
| `/turno/nuevo` | Nuevo turno |
| `/turno/:id` | Detalle del turno |
| `/turno/:id/editar` | Editar turno |

Se usa `StatefulShellRoute.indexedStack` para conservar el estado de las
pestañas y `context.push` / `context.go` de `go_router`. No se usa
`Navigator.push` ni `pushNamed`.

## Datos de prueba

Todos los datos viven en memoria y se generan al iniciar la app a partir de
`DateTime.now()`, así que nunca quedan vencidos:

- 12 servicios en 5 categorías.
- 5 estilistas (solo mujeres, solo hombres y ambos).
- 10 clientes (5 mujeres y 5 hombres).
- 16 turnos repartidos entre ayer, hoy y mañana, con estados programado,
  completado y cancelado.

## Diseño

- Tipografía **Poppins** incluida como asset (pesos 400, 500, 600 y 700).
- Tema claro y oscuro globales; ningún widget define colores propios.
- Paleta, radios, espaciados y jerarquía tipográfica definidos en
  `app_theme.dart`.

## Requisitos

- Flutter estable (Dart 3.13 o superior).
- Android SDK.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Dependencias externas

- [`go_router`](https://pub.dev/packages/go_router) para la navegación.

No se utilizan `provider`, `riverpod`, `bloc`, `get` ni paquetes de
almacenamiento local.
