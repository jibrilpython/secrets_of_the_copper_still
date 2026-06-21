import 'dart:math';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';

class LedgerKeyGenerator {
  static final _random = Random();

  static String generate({
    required ApparatusClassification apparatus,
    required DistillationMethod method,
  }) {
    final serial = 1000 + _random.nextInt(9000);
    final methodSuffix = _methodSuffix(method);
    return 'SCS-STILL-$serial-${apparatus.code}-$methodSuffix';
  }

  static String _methodSuffix(DistillationMethod method) {
    switch (method) {
      case DistillationMethod.steamDistillation:
        return 'BOTAN';
      case DistillationMethod.dryDistillation:
        return 'RESIN';
      case DistillationMethod.fractional:
        return 'FRACT';
      case DistillationMethod.vacuum:
        return 'VACUM';
      case DistillationMethod.solventExtraction:
        return 'SOLVT';
      case DistillationMethod.coldPressing:
        return 'PRESS';
      case DistillationMethod.other:
        return 'MISC';
    }
  }
}
