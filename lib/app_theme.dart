import 'package:flutter/material.dart';

/// Tokens de color extraídos del diseño.
class TurcoColores {
  TurcoColores._();

  // Claro
  static const primaryClaro = Color(0xFF006A60);
  static const onPrimaryClaro = Color(0xFFFFFFFF);
  static const primaryContainerClaro = Color(0xFF9EF2E4);
  static const onPrimaryContainerClaro = Color(0xFF00201C);
  static const secondaryClaro = Color(0xFF4A635F);
  static const onSecondaryClaro = Color(0xFFFFFFFF);
  static const secondaryContainerClaro = Color(0xFFCCE8E2);
  static const onSecondaryContainerClaro = Color(0xFF05201C);
  static const tertiaryClaro = Color(0xFF456179);
  static const onTertiaryClaro = Color(0xFFFFFFFF);
  static const tertiaryContainerClaro = Color(0xFFC8E6FF);
  static const onTertiaryContainerClaro = Color(0xFF001D32);
  static const errorClaro = Color(0xFFBA1A1A);
  static const onErrorClaro = Color(0xFFFFFFFF);
  static const errorContainerClaro = Color(0xFFFFDAD6);
  static const onErrorContainerClaro = Color(0xFF410002);
  static const surfaceClaro = Color(0xFFF4FBF9);
  static const onSurfaceClaro = Color(0xFF161D1C);
  static const surfaceContainerClaro = Color(0xFFE9EFED);
  static const onSurfaceVariantClaro = Color(0xFF3F4947);
  static const outlineClaro = Color(0xFF6F7977);
  static const outlineVariantClaro = Color(0xFFBEC9C6);
  static const inverseSurfaceClaro = Color(0xFF2B3231);
  static const onInverseSurfaceClaro = Color(0xFFECF2F0);
  static const inversePrimaryClaro = Color(0xFF53DBC9);

  // Oscuro
  static const primaryOscuro = Color(0xFF53DBC9);
  static const onPrimaryOscuro = Color(0xFF003731);
  static const primaryContainerOscuro = Color(0xFF005047);
  static const onPrimaryContainerOscuro = Color(0xFF74F8E5);
  static const secondaryOscuro = Color(0xFFB1CCC6);
  static const onSecondaryOscuro = Color(0xFF1C3531);
  static const secondaryContainerOscuro = Color(0xFF314B47);
  static const onSecondaryContainerOscuro = Color(0xFFCCE8E2);
  static const tertiaryOscuro = Color(0xFFADCAE6);
  static const onTertiaryOscuro = Color(0xFF163349);
  static const tertiaryContainerOscuro = Color(0xFF2D4A61);
  static const onTertiaryContainerOscuro = Color(0xFFC8E6FF);
  static const errorOscuro = Color(0xFFFFB4AB);
  static const onErrorOscuro = Color(0xFF690005);
  static const errorContainerOscuro = Color(0xFF93000A);
  static const onErrorContainerOscuro = Color(0xFFFFDAD6);
  static const surfaceOscuro = Color(0xFF0E1514);
  static const onSurfaceOscuro = Color(0xFFDDE4E2);
  static const surfaceContainerOscuro = Color(0xFF1A2120);
  static const onSurfaceVariantOscuro = Color(0xFFBEC9C6);
  static const outlineOscuro = Color(0xFF899390);
  static const outlineVariantOscuro = Color(0xFF3F4947);
  static const inverseSurfaceOscuro = Color(0xFFDDE4E2);
  static const onInverseSurfaceOscuro = Color(0xFF2B3231);
  static const inversePrimaryOscuro = Color(0xFF006A60);

  // Comunes
  static const scrim = Color(0x66000000);
}

/// Colores propios que no forman parte del ColorScheme de Material 3.
/// Se exponen como ThemeExtension para no escribir colores sueltos en widgets.
@immutable
class TurcoExtraColors extends ThemeExtension<TurcoExtraColors> {
  final Color searchFieldBackground;
  final Color completedBadge;
  final Color onCompletedBadge;
  final Color disabledSlot;
  final Color onDisabledSlot;
  final Color appBarSubtitle;
  final Color avatarMujer;
  final Color onAvatarMujer;
  final Color avatarHombre;
  final Color onAvatarHombre;
  final Color fabBackground;
  final Color onFabBackground;

  const TurcoExtraColors({
    required this.searchFieldBackground,
    required this.completedBadge,
    required this.onCompletedBadge,
    required this.disabledSlot,
    required this.onDisabledSlot,
    required this.appBarSubtitle,
    required this.avatarMujer,
    required this.onAvatarMujer,
    required this.avatarHombre,
    required this.onAvatarHombre,
    required this.fabBackground,
    required this.onFabBackground,
  });

  static const claro = TurcoExtraColors(
    searchFieldBackground: Color(0xFFE3EAE8),
    completedBadge: Color(0xFFCDE5FF),
    onCompletedBadge: Color(0xFF001D32),
    disabledSlot: Color(0xFFE3EAE8),
    onDisabledSlot: Color(0xFF6F7977),
    appBarSubtitle: Color(0xFFD9F5F0),
    avatarMujer: Color(0xFF9EF2E4),
    onAvatarMujer: Color(0xFF00201C),
    avatarHombre: Color(0xFFCDE5FF),
    onAvatarHombre: Color(0xFF001D32),
    fabBackground: Color(0xFF006A60),
    onFabBackground: Color(0xFFFFFFFF),
  );

  static const oscuro = TurcoExtraColors(
    searchFieldBackground: Color(0xFF1A2120),
    completedBadge: Color(0xFF00497A),
    onCompletedBadge: Color(0xFFCDE5FF),
    disabledSlot: Color(0xFF1A2120),
    onDisabledSlot: Color(0xFF899390),
    appBarSubtitle: Color(0xFFD9F5F0),
    avatarMujer: Color(0xFF005047),
    onAvatarMujer: Color(0xFF74F8E5),
    avatarHombre: Color(0xFF314B47),
    onAvatarHombre: Color(0xFFCCE8E2),
    fabBackground: Color(0xFF005047),
    onFabBackground: Color(0xFF74F8E5),
  );

  @override
  TurcoExtraColors copyWith({
    Color? searchFieldBackground,
    Color? completedBadge,
    Color? onCompletedBadge,
    Color? disabledSlot,
    Color? onDisabledSlot,
    Color? appBarSubtitle,
    Color? avatarMujer,
    Color? onAvatarMujer,
    Color? avatarHombre,
    Color? onAvatarHombre,
    Color? fabBackground,
    Color? onFabBackground,
  }) {
    return TurcoExtraColors(
      searchFieldBackground: searchFieldBackground ?? this.searchFieldBackground,
      completedBadge: completedBadge ?? this.completedBadge,
      onCompletedBadge: onCompletedBadge ?? this.onCompletedBadge,
      disabledSlot: disabledSlot ?? this.disabledSlot,
      onDisabledSlot: onDisabledSlot ?? this.onDisabledSlot,
      appBarSubtitle: appBarSubtitle ?? this.appBarSubtitle,
      avatarMujer: avatarMujer ?? this.avatarMujer,
      onAvatarMujer: onAvatarMujer ?? this.onAvatarMujer,
      avatarHombre: avatarHombre ?? this.avatarHombre,
      onAvatarHombre: onAvatarHombre ?? this.onAvatarHombre,
      fabBackground: fabBackground ?? this.fabBackground,
      onFabBackground: onFabBackground ?? this.onFabBackground,
    );
  }

  @override
  TurcoExtraColors lerp(ThemeExtension<TurcoExtraColors>? other, double t) {
    if (other is! TurcoExtraColors) return this;
    return TurcoExtraColors(
      searchFieldBackground:
          Color.lerp(searchFieldBackground, other.searchFieldBackground, t)!,
      completedBadge: Color.lerp(completedBadge, other.completedBadge, t)!,
      onCompletedBadge: Color.lerp(onCompletedBadge, other.onCompletedBadge, t)!,
      disabledSlot: Color.lerp(disabledSlot, other.disabledSlot, t)!,
      onDisabledSlot: Color.lerp(onDisabledSlot, other.onDisabledSlot, t)!,
      appBarSubtitle: Color.lerp(appBarSubtitle, other.appBarSubtitle, t)!,
      avatarMujer: Color.lerp(avatarMujer, other.avatarMujer, t)!,
      onAvatarMujer: Color.lerp(onAvatarMujer, other.onAvatarMujer, t)!,
      avatarHombre: Color.lerp(avatarHombre, other.avatarHombre, t)!,
      onAvatarHombre: Color.lerp(onAvatarHombre, other.onAvatarHombre, t)!,
      fabBackground: Color.lerp(fabBackground, other.fabBackground, t)!,
      onFabBackground: Color.lerp(onFabBackground, other.onFabBackground, t)!,
    );
  }
}

/// Modo de tema de la app.
enum ModoTema { claro, oscuro, sistema }

class AppTheme {
  static const _claro = ColorScheme(
    brightness: Brightness.light,
    primary: TurcoColores.primaryClaro,
    onPrimary: TurcoColores.onPrimaryClaro,
    primaryContainer: TurcoColores.primaryContainerClaro,
    onPrimaryContainer: TurcoColores.onPrimaryContainerClaro,
    secondary: TurcoColores.secondaryClaro,
    onSecondary: TurcoColores.onSecondaryClaro,
    secondaryContainer: TurcoColores.secondaryContainerClaro,
    onSecondaryContainer: TurcoColores.onSecondaryContainerClaro,
    tertiary: TurcoColores.tertiaryClaro,
    onTertiary: TurcoColores.onTertiaryClaro,
    tertiaryContainer: TurcoColores.tertiaryContainerClaro,
    onTertiaryContainer: TurcoColores.onTertiaryContainerClaro,
    error: TurcoColores.errorClaro,
    onError: TurcoColores.onErrorClaro,
    errorContainer: TurcoColores.errorContainerClaro,
    onErrorContainer: TurcoColores.onErrorContainerClaro,
    surface: TurcoColores.surfaceClaro,
    onSurface: TurcoColores.onSurfaceClaro,
    surfaceContainerHighest: TurcoColores.surfaceContainerClaro,
    onSurfaceVariant: TurcoColores.onSurfaceVariantClaro,
    outline: TurcoColores.outlineClaro,
    outlineVariant: TurcoColores.outlineVariantClaro,
    inverseSurface: TurcoColores.inverseSurfaceClaro,
    onInverseSurface: TurcoColores.onInverseSurfaceClaro,
    inversePrimary: TurcoColores.inversePrimaryClaro,
    shadow: Color(0xFF000000),
    scrim: TurcoColores.scrim,
    surfaceTint: TurcoColores.primaryClaro,
  );

  static const _oscuro = ColorScheme(
    brightness: Brightness.dark,
    primary: TurcoColores.primaryOscuro,
    onPrimary: TurcoColores.onPrimaryOscuro,
    primaryContainer: TurcoColores.primaryContainerOscuro,
    onPrimaryContainer: TurcoColores.onPrimaryContainerOscuro,
    secondary: TurcoColores.secondaryOscuro,
    onSecondary: TurcoColores.onSecondaryOscuro,
    secondaryContainer: TurcoColores.secondaryContainerOscuro,
    onSecondaryContainer: TurcoColores.onSecondaryContainerOscuro,
    tertiary: TurcoColores.tertiaryOscuro,
    onTertiary: TurcoColores.onTertiaryOscuro,
    tertiaryContainer: TurcoColores.tertiaryContainerOscuro,
    onTertiaryContainer: TurcoColores.onTertiaryContainerOscuro,
    error: TurcoColores.errorOscuro,
    onError: TurcoColores.onErrorOscuro,
    errorContainer: TurcoColores.errorContainerOscuro,
    onErrorContainer: TurcoColores.onErrorContainerOscuro,
    surface: TurcoColores.surfaceOscuro,
    onSurface: TurcoColores.onSurfaceOscuro,
    surfaceContainerHighest: TurcoColores.surfaceContainerOscuro,
    onSurfaceVariant: TurcoColores.onSurfaceVariantOscuro,
    outline: TurcoColores.outlineOscuro,
    outlineVariant: TurcoColores.outlineVariantOscuro,
    inverseSurface: TurcoColores.inverseSurfaceOscuro,
    onInverseSurface: TurcoColores.onInverseSurfaceOscuro,
    inversePrimary: TurcoColores.inversePrimaryOscuro,
    shadow: Color(0xFF000000),
    scrim: TurcoColores.scrim,
    surfaceTint: TurcoColores.primaryOscuro,
  );

  static ThemeData temaClaro() =>
      _construir(_claro, TurcoExtraColors.claro, const Color(0xFFFFFFFF));

  static ThemeData temaOscuro() =>
      _construir(_oscuro, TurcoExtraColors.oscuro, const Color(0xFF1A2120));

  static ThemeData _construir(
    ColorScheme cs,
    TurcoExtraColors extra,
    Color fieldFill,
  ) {
    final textoPrincipal = cs.onSurface;
    final textoSecundario = cs.onSurfaceVariant;
    final surfaceContainer = cs.surfaceContainerHighest;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      fontFamily: 'Poppins',
      extensions: <ThemeExtension<dynamic>>[extra],

      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textoPrincipal,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textoPrincipal,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textoPrincipal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textoSecundario,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textoSecundario,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceContainer,
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size.fromHeight(46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size.fromHeight(46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textoSecundario,
        ),
        errorStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          color: cs.error,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: textoSecundario,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: cs.secondaryContainer,
        disabledColor: surfaceContainer.withValues(alpha: 0.5),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: cs.onSecondaryContainer,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: surfaceContainer,
          selectedBackgroundColor: cs.secondaryContainer,
          foregroundColor: textoPrincipal,
          selectedForegroundColor: cs.onSecondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: cs.outline),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        ).copyWith(
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: textoPrincipal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textoPrincipal,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: textoPrincipal),
        actionsIconTheme: IconThemeData(color: textoPrincipal),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainer,
        indicatorColor: cs.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textoPrincipal,
            );
          }
          return TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textoSecundario,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.primary, size: 24);
          }
          return IconThemeData(color: textoSecundario, size: 24);
        }),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: extra.fabBackground,
        foregroundColor: extra.onFabBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: cs.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Construye el ThemeData según el modo seleccionado.
  static ThemeData build(ModoTema modo, Brightness sistemaBrillo) {
    switch (modo) {
      case ModoTema.claro:
        return temaClaro();
      case ModoTema.oscuro:
        return temaOscuro();
      case ModoTema.sistema:
        return sistemaBrillo == Brightness.dark ? temaOscuro() : temaClaro();
    }
  }
}

/// Acceso rápido a los colores extra del tema.
extension TurcoThemeX on BuildContext {
  TurcoExtraColors get turco =>
      Theme.of(this).extension<TurcoExtraColors>() ?? TurcoExtraColors.claro;
}
