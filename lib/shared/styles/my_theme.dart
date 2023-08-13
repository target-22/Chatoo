import 'package:chat_app/shared/styles/text_style.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class MyThemeData {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    iconTheme: const IconThemeData(
      size: 30,
      color: AppColors.primaryColor,
    ),
     scaffoldBackgroundColor: Colors.white,
    primaryColor: AppColors.primaryColor,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 25,
      ),
      elevation: 0,
      toolbarHeight: 80,
      backgroundColor: AppColors.primaryColor,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      bodySmall: AppTexts.novaFlat12BlackLight(),
      bodyMedium: AppTexts.novaFlat18WhiteLight(),
      bodyLarge: AppTexts.NovaSquare22WhiteLight(),
    ),
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    iconTheme: const IconThemeData(
      size: 30,
      color: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkColor,
    primaryColorDark: AppColors.primaryColor,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 25,
      ),
      color: AppColors.primaryColor,
      elevation: 0,
      toolbarHeight: 80,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      bodySmall: AppTexts.novaFlat12WhiteDark(),
      bodyMedium: AppTexts.novaFlat18WhiteDark(),
      bodyLarge: AppTexts.NovaSquare22WhiteDark(),
    ),
  );
}

