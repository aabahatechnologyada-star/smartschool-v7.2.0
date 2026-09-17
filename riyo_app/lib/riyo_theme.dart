import 'package:flutter/material.dart';

/// X/Twitter "Lights Out" monochrome theme — pure black & white only.
class RiyoTheme {
  // Core palette
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray900 = Color(0xFF1A1A1A); // AppBar, cards
  static const Color gray800 = Color(0xFF2D2D2D); // Elevated surfaces
  static const Color gray700 = Color(0xFF3D3D3D); // Borders, dividers
  static const Color gray600 = Color(0xFF525252); // Muted text, icons
  static const Color gray500 = Color(0xFF737373); // Disabled, timestamps
  static const Color gray400 = Color(0xFFA3A3A3); // Secondary text
  static const Color gray300 = Color(0xFFD4D4D4); // Placeholder text
  static const Color gray200 = Color(
    0xFFE5E5E5,
  ); // Hairline borders (light mode)
  static const Color gray100 = Color(0xFFF5F5F5); // Light mode surface

  // Spacing scale (4px base)
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // Typography — X uses system font with precise weights/sizes
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.25,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.45,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.35,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // Dark theme (default — "Lights Out")
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    canvasColor: black,
    colorScheme: const ColorScheme.dark(
      primary: white,
      onPrimary: black,
      secondary: white,
      onSecondary: black,
      surface: gray900,
      onSurface: white,
      surfaceContainerHighest: gray800,
      outline: gray700,
      outlineVariant: gray700,
      inverseSurface: white,
      onInverseSurface: black,
      inversePrimary: black,
      shadow: Color(0x00000000),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: headlineMedium,
      toolbarHeight: 52,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: black,
      selectedItemColor: white,
      unselectedItemColor: gray600,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: black,
      indicatorColor: gray800,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return labelMedium.copyWith(color: white);
        }
        return labelMedium.copyWith(color: gray600);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: white, size: 24);
        }
        return const IconThemeData(color: gray600, size: 24);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        disabledBackgroundColor: gray700,
        disabledForegroundColor: gray500,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: labelLarge,
        elevation: 0,
        shadowColor: Colors.transparent,
        side: BorderSide.none,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: white,
        disabledForegroundColor: gray600,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: labelLarge,
        side: const BorderSide(color: gray700, width: 1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: white,
        disabledForegroundColor: gray600,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(48, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: gray700, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: gray700, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: white, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: white, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: gray700, width: 1),
      ),
      labelStyle: bodyMedium.copyWith(color: gray400),
      hintStyle: bodyMedium.copyWith(color: gray600),
      errorStyle: bodySmall.copyWith(color: white),
      floatingLabelStyle: bodyMedium.copyWith(color: white),
    ),
    cardTheme: CardTheme(
      color: gray900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: gray700, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: space4, vertical: space2),
    ),
    dividerTheme: const DividerThemeData(
      color: gray700,
      thickness: 0.5,
      space: 0,
      indent: 0,
      endIndent: 0,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: space4,
        vertical: space2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      ),
      tileColor: Colors.transparent,
      selectedTileColor: gray800,
      iconColor: gray400,
      textColor: white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: gray800,
      disabledColor: gray700,
      selectedColor: white,
      secondarySelectedColor: white,
      labelStyle: labelMedium.copyWith(color: white),
      secondaryLabelStyle: labelMedium.copyWith(color: black),
      padding: const EdgeInsets.symmetric(horizontal: space3, vertical: space1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        side: const BorderSide(color: gray700, width: 0.5),
      ),
      side: const BorderSide(color: gray700, width: 0.5),
      brightness: Brightness.dark,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: gray900,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: gray700, width: 0.5),
      ),
      titleTextStyle: titleLarge,
      contentTextStyle: bodyMedium,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: gray900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        side: BorderSide(color: gray700, width: 0.5),
      ),
      modalBackgroundColor: gray900,
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(gray900),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            side: const BorderSide(color: gray700, width: 0.5),
          ),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: gray900,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(color: gray700, width: 0.5),
      ),
      textStyle: bodyMedium,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: gray800,
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(color: gray700, width: 0.5),
      ),
      textStyle: labelSmall.copyWith(color: white),
      padding: const EdgeInsets.symmetric(horizontal: space3, vertical: space2),
      preferBelow: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: gray800,
      contentTextStyle: bodyMedium,
      actionTextColor: white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      elevation: 4,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: white,
      unselectedLabelColor: gray600,
      indicatorColor: white,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: labelLarge,
      unselectedLabelStyle: labelLarge,
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(gray800),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: white,
      inactiveTrackColor: gray700,
      thumbColor: white,
      overlayColor: white.withValues(alpha: 0.12),
      valueIndicatorColor: white,
      valueIndicatorTextStyle: labelSmall.copyWith(color: black),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return white;
        return gray400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return white.withValues(alpha: 0.5);
        return gray700;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return white;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(black),
      side: const BorderSide(color: gray600, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSm),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return white;
        return gray600;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: white,
      linearTrackColor: gray700,
      circularTrackColor: gray700,
    ),
    textTheme: const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: titleLarge,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: labelLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ).apply(bodyColor: white, displayColor: white),
    iconTheme: const IconThemeData(color: white, size: 24),
  );

  // Light theme (optional — for completeness)
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    canvasColor: white,
    colorScheme: const ColorScheme.light(
      primary: black,
      onPrimary: white,
      secondary: black,
      onSecondary: white,
      surface: white,
      onSurface: black,
      surfaceContainerHighest: gray100,
      outline: gray300,
      outlineVariant: gray200,
      inverseSurface: black,
      onInverseSurface: white,
      inversePrimary: white,
      shadow: Color(0x1A000000),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: headlineMedium,
      toolbarHeight: 52,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: black,
      unselectedItemColor: gray600,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: white,
      indicatorColor: gray100,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return labelMedium.copyWith(color: black);
        }
        return labelMedium.copyWith(color: gray600);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: black, size: 24);
        }
        return const IconThemeData(color: gray600, size: 24);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        disabledBackgroundColor: gray300,
        disabledForegroundColor: gray500,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: labelLarge,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: black,
        disabledForegroundColor: gray500,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: labelLarge,
        side: const BorderSide(color: gray300, width: 1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: black,
        disabledForegroundColor: gray500,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(48, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: gray300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: black, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: black, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: gray300, width: 1),
      ),
      labelStyle: bodyMedium.copyWith(color: gray600),
      hintStyle: bodyMedium.copyWith(color: gray500),
      errorStyle: bodySmall.copyWith(color: black),
      floatingLabelStyle: bodyMedium.copyWith(color: black),
    ),
    cardTheme: CardTheme(
      color: white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: gray200, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: space4, vertical: space2),
    ),
    dividerTheme: const DividerThemeData(
      color: gray200,
      thickness: 0.5,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: gray100,
      disabledColor: gray200,
      selectedColor: black,
      secondarySelectedColor: black,
      labelStyle: labelMedium.copyWith(color: black),
      secondaryLabelStyle: labelMedium.copyWith(color: white),
      padding: const EdgeInsets.symmetric(horizontal: space3, vertical: space1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        side: const BorderSide(color: gray300, width: 0.5),
      ),
      side: const BorderSide(color: gray300, width: 0.5),
      brightness: Brightness.light,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: gray200, width: 0.5),
      ),
      titleTextStyle: titleLarge.copyWith(color: black),
      contentTextStyle: bodyMedium.copyWith(color: black),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        side: BorderSide(color: gray200, width: 0.5),
      ),
      modalBackgroundColor: white,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: black,
      unselectedLabelColor: gray600,
      indicatorColor: black,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: labelLarge,
      unselectedLabelStyle: labelLarge,
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(gray100),
    ),
    textTheme: const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: titleLarge,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: labelLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ).apply(bodyColor: black, displayColor: black),
    iconTheme: const IconThemeData(color: black, size: 24),
  );
}

// Helper extension for consistent spacing
extension RiyoSpacing on BuildContext {
  double get s1 => RiyoTheme.space1;
  double get s2 => RiyoTheme.space2;
  double get s3 => RiyoTheme.space3;
  double get s4 => RiyoTheme.space4;
  double get s5 => RiyoTheme.space5;
  double get s6 => RiyoTheme.space6;
  double get s8 => RiyoTheme.space8;
}
