import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTexts {
  static TextStyle novaFlat12BlackLight() =>
      GoogleFonts.novaFlat(
          fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.normal);

  static TextStyle novaFlat18WhiteLight() =>
      GoogleFonts.novaFlat(
          fontSize: 18.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold);

  static TextStyle NovaSquare22WhiteLight() =>
      GoogleFonts.novaSquare(
          fontSize: 22.sp,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold);

  static TextStyle novaFlat12WhiteDark() =>
      GoogleFonts.novaFlat(
          fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.normal);

  static TextStyle novaFlat18WhiteDark() =>
      GoogleFonts.novaFlat(
          fontSize: 18.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold);

  static TextStyle NovaSquare22WhiteDark() =>
      GoogleFonts.novaSquare(
          fontSize: 22.sp,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold);
}
