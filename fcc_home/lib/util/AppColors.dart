import 'dart:ui';

import 'package:flutter/src/material/color_scheme.dart';

class AppColors {
  static late Color primaryColor;
  static late Color secondaryColor;
  static late Color tertiaryColor;
  static late Color backgroundColor;

  static void init(ColorScheme colorScheme) {
    primaryColor = colorScheme.primary;
    secondaryColor = colorScheme.secondary;
    tertiaryColor = colorScheme.tertiary;
    backgroundColor = colorScheme.surface;
  }
}
