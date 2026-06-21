import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';

const Color kBackground = Color(0xFFF6F2EC);
const Color kPrimaryText = Color(0xFF181410);
const Color kPanelBg = Color(0xFFFFFFFF);
const Color kSecondaryText = Color(0xFF7A7268);
const Color kAccent = Color(0xFFB5651D);
const Color kSecondaryAccent = Color(0xFF4A7A5E);
const Color kOutline = Color(0xFFE8E2D8);
const Color kError = Color(0xFFC0392B);

const Color kAccentLight = Color(0xFFD4843A);
const Color kAccentSurface = Color(0xFFF7EDE0);
const Color kBotanicalSurface = Color(0x1A4A7A5E);
const Color kGlassBackground = Color(0xB3FFFFFF);

const double kSpacingXXS = 4.0;
const double kSpacingXS = 8.0;
const double kSpacingS = 12.0;
const double kSpacingM = 16.0;
const double kSpacingL = 20.0;
const double kSpacingXL = 24.0;
const double kSpacingXXL = 32.0;
const double kSpacingXXXL = 48.0;

const double kRadiusZero = 0.0;
const double kRadiusSubtle = 10.0;
const double kRadiusStandard = 16.0;
const double kRadiusMedium = 24.0;
const double kRadiusLarge = 32.0;
const double kRadiusPill = 999.0;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 16),
  blurRadius: 40,
  spreadRadius: -12,
  color: Color(0x14000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 32),
  blurRadius: 64,
  spreadRadius: -16,
  color: Color(0x1A000000),
);

const double kStrokeWeight = 1.0;
const double kStrokeWeightMedium = 2.0;
const double kStrokeWeightThick = 3.0;

const Duration kTransitionDuration = Duration(milliseconds: 240);

/// Total height reserved by the floating bottom tab bar (safe area included).
double bottomNavReserve(BuildContext context) {
  return MediaQuery.of(context).padding.bottom + 10.h + 72.h + 16.h;
}

/// Bottom inset for FABs so they sit above the tab bar on any screen size.
double fabBottomOffset(BuildContext context) {
  return bottomNavReserve(context) + 12.h;
}

/// Scroll padding on tab screens so content clears the FAB + nav bar.
double tabScrollBottomPadding(BuildContext context) {
  return fabBottomOffset(context) + 56.h + 16.h;
}

bool isOperational(PreservationSoundness state) {
  return state == PreservationSoundness.distillationReady;
}

Color getPreservationColor(PreservationSoundness state) {
  switch (state) {
    case PreservationSoundness.distillationReady:
      return kAccent;
    case PreservationSoundness.displayCabinet:
      return kSecondaryAccent;
    case PreservationSoundness.copperPitting:
      return const Color(0xFFC88241);
    case PreservationSoundness.glassScoring:
      return kSecondaryText;
    case PreservationSoundness.verdigrisCorrosion:
      return kError;
    case PreservationSoundness.unknown:
      return kSecondaryText;
  }
}

Color getApparatusColor(ApparatusClassification type) {
  switch (type) {
    case ApparatusClassification.gooseneckAlembic:
    case ApparatusClassification.steamJacketedPot:
      return kAccent;
    case ApparatusClassification.glassRetort:
    case ApparatusClassification.fractionalColumn:
      return const Color(0xFF8EC8E8);
    case ApparatusClassification.wormCondenser:
      return kAccentLight;
    case ApparatusClassification.separationFunnel:
      return kSecondaryAccent;
    case ApparatusClassification.brassHydrometer:
      return const Color(0xFFC2A878);
    case ApparatusClassification.other:
      return kSecondaryText;
  }
}
