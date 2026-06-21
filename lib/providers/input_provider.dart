import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _alembicLedgerKey = '';
  ApparatusClassification _apparatusClassification =
      ApparatusClassification.gooseneckAlembic;
  ArtisanHallmark _artisanHallmark = ArtisanHallmark.other;
  String _customArtisanHallmark = '';
  String _condensationSurfaceArea = '';
  String _volumetricCapacityBounds = '';
  JointJoineryArchitecture _jointJoineryArchitecture =
      JointJoineryArchitecture.groundGlassTaper;
  String _metallurgicalGaugeThickness = '';
  String _physicalProportions = '';
  PreservationSoundness _preservationSoundness = PreservationSoundness.unknown;
  LaboratoryGroundZero _laboratoryGroundZero = LaboratoryGroundZero.other;
  String _customLaboratoryGroundZero = '';
  DistillationMethod _distillationMethod = DistillationMethod.steamDistillation;
  Era _era = Era.other;
  String _customEra = '';
  String _temperatureRange = '';
  CalibrationOrigin _calibrationOrigin = CalibrationOrigin.other;
  String _customCalibrationOrigin = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get alembicLedgerKey => _alembicLedgerKey;
  ApparatusClassification get apparatusClassification =>
      _apparatusClassification;
  ArtisanHallmark get artisanHallmark => _artisanHallmark;
  String get customArtisanHallmark => _customArtisanHallmark;
  String get condensationSurfaceArea => _condensationSurfaceArea;
  String get volumetricCapacityBounds => _volumetricCapacityBounds;
  JointJoineryArchitecture get jointJoineryArchitecture =>
      _jointJoineryArchitecture;
  String get metallurgicalGaugeThickness => _metallurgicalGaugeThickness;
  String get physicalProportions => _physicalProportions;
  PreservationSoundness get preservationSoundness => _preservationSoundness;
  LaboratoryGroundZero get laboratoryGroundZero => _laboratoryGroundZero;
  String get customLaboratoryGroundZero => _customLaboratoryGroundZero;
  DistillationMethod get distillationMethod => _distillationMethod;
  Era get era => _era;
  String get customEra => _customEra;
  String get temperatureRange => _temperatureRange;
  CalibrationOrigin get calibrationOrigin => _calibrationOrigin;
  String get customCalibrationOrigin => _customCalibrationOrigin;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set alembicLedgerKey(String v) {
    _alembicLedgerKey = v;
    notifyListeners();
  }

  set apparatusClassification(ApparatusClassification v) {
    _apparatusClassification = v;
    notifyListeners();
  }

  set artisanHallmark(ArtisanHallmark v) {
    _artisanHallmark = v;
    notifyListeners();
  }

  set customArtisanHallmark(String v) {
    _customArtisanHallmark = v;
    notifyListeners();
  }

  set condensationSurfaceArea(String v) {
    _condensationSurfaceArea = v;
    notifyListeners();
  }

  set volumetricCapacityBounds(String v) {
    _volumetricCapacityBounds = v;
    notifyListeners();
  }

  set jointJoineryArchitecture(JointJoineryArchitecture v) {
    _jointJoineryArchitecture = v;
    notifyListeners();
  }

  set metallurgicalGaugeThickness(String v) {
    _metallurgicalGaugeThickness = v;
    notifyListeners();
  }

  set physicalProportions(String v) {
    _physicalProportions = v;
    notifyListeners();
  }

  set preservationSoundness(PreservationSoundness v) {
    _preservationSoundness = v;
    notifyListeners();
  }

  set laboratoryGroundZero(LaboratoryGroundZero v) {
    _laboratoryGroundZero = v;
    notifyListeners();
  }

  set customLaboratoryGroundZero(String v) {
    _customLaboratoryGroundZero = v;
    notifyListeners();
  }

  set distillationMethod(DistillationMethod v) {
    _distillationMethod = v;
    notifyListeners();
  }

  set era(Era v) {
    _era = v;
    notifyListeners();
  }

  set customEra(String v) {
    _customEra = v;
    notifyListeners();
  }

  set temperatureRange(String v) {
    _temperatureRange = v;
    notifyListeners();
  }

  set calibrationOrigin(CalibrationOrigin v) {
    _calibrationOrigin = v;
    notifyListeners();
  }

  set customCalibrationOrigin(String v) {
    _customCalibrationOrigin = v;
    notifyListeners();
  }

  set notes(String v) {
    _notes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _alembicLedgerKey = '';
    _apparatusClassification = ApparatusClassification.gooseneckAlembic;
    _artisanHallmark = ArtisanHallmark.other;
    _customArtisanHallmark = '';
    _condensationSurfaceArea = '';
    _volumetricCapacityBounds = '';
    _jointJoineryArchitecture = JointJoineryArchitecture.groundGlassTaper;
    _metallurgicalGaugeThickness = '';
    _physicalProportions = '';
    _preservationSoundness = PreservationSoundness.unknown;
    _laboratoryGroundZero = LaboratoryGroundZero.other;
    _customLaboratoryGroundZero = '';
    _distillationMethod = DistillationMethod.steamDistillation;
    _era = Era.other;
    _customEra = '';
    _temperatureRange = '';
    _calibrationOrigin = CalibrationOrigin.other;
    _customCalibrationOrigin = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
