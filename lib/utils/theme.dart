import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    secondary: kSecondaryAccent,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kPanelBg,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: GoogleFonts.cormorantGaramond(
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.cormorantGaramond(
      fontSize: 48.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
      height: 1.1,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.cormorantGaramond(
      fontSize: 36.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.cormorantGaramond(
      fontSize: 28.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    headlineLarge: GoogleFonts.cormorantGaramond(
      fontSize: 26.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: kPrimaryText,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w300,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
    labelLarge: GoogleFonts.ibmPlexMono(
      fontSize: 12.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.ibmPlexMono(
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.ibmPlexMono(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
      letterSpacing: 0.5,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kPanelBg,
    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kAccent, width: 2),
    ),
    hintStyle: GoogleFonts.inter(
      color: kSecondaryText.withValues(alpha: 0.6),
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 32.w),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
      textStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    color: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 0,
  ),
  useMaterial3: true,
);
