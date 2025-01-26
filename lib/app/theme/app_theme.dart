import 'package:flutter/material.dart';

import 'text_theme.dart';
import 'color_scheme.dart';

var appTheme = ThemeData(
  colorScheme: appColorScheme,
  textTheme: appTextTheme,
  useMaterial3: true,
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: appColorScheme.surface,
    surfaceTintColor: appColorScheme.surface,
    indicatorColor: appColorScheme.primary.withAlpha(100),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: appColorScheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
