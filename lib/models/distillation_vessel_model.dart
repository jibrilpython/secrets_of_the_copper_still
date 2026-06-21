import 'package:secrets_of_the_copper_still/enum/my_enums.dart';

class DistillationVesselModel {
  String id;
  String alembicLedgerKey;
  ApparatusClassification apparatusClassification;
  ArtisanHallmark artisanHallmark;
  String customArtisanHallmark;
  String condensationSurfaceArea;
  String volumetricCapacityBounds;
  JointJoineryArchitecture jointJoineryArchitecture;
  String metallurgicalGaugeThickness;
  String physicalProportions;
  PreservationSoundness preservationSoundness;
  LaboratoryGroundZero laboratoryGroundZero;
  String customLaboratoryGroundZero;
  DistillationMethod distillationMethod;
  Era era;
  String customEra;
  String temperatureRange;
  CalibrationOrigin calibrationOrigin;
  String customCalibrationOrigin;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  DistillationVesselModel({
    required this.id,
    required this.alembicLedgerKey,
    required this.apparatusClassification,
    this.artisanHallmark = ArtisanHallmark.other,
    this.customArtisanHallmark = '',
    this.condensationSurfaceArea = '',
    this.volumetricCapacityBounds = '',
    this.jointJoineryArchitecture = JointJoineryArchitecture.other,
    this.metallurgicalGaugeThickness = '',
    this.physicalProportions = '',
    this.preservationSoundness = PreservationSoundness.unknown,
    this.laboratoryGroundZero = LaboratoryGroundZero.other,
    this.customLaboratoryGroundZero = '',
    this.distillationMethod = DistillationMethod.other,
    this.era = Era.other,
    this.customEra = '',
    this.temperatureRange = '',
    this.calibrationOrigin = CalibrationOrigin.other,
    this.customCalibrationOrigin = '',
    this.notes = '',
    this.photoPath = '',
    this.tags = const [],
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  String get displayEra =>
      era == Era.other && customEra.isNotEmpty ? customEra : era.label;

  String get displayArtisan => customArtisanHallmark.isNotEmpty
      ? customArtisanHallmark
      : artisanHallmark.label;

  String get displayLaboratory => customLaboratoryGroundZero.isNotEmpty
      ? customLaboratoryGroundZero
      : laboratoryGroundZero.label;

  String get displayCalibrationOrigin =>
      calibrationOrigin == CalibrationOrigin.other &&
              customCalibrationOrigin.isNotEmpty
          ? customCalibrationOrigin
          : calibrationOrigin.label;

  String get capacityBadge {
    if (volumetricCapacityBounds.isEmpty) return '';
    return volumetricCapacityBounds;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alembicLedgerKey': alembicLedgerKey,
        'apparatusClassification': apparatusClassification.name,
        'artisanHallmark': artisanHallmark.name,
        'customArtisanHallmark': customArtisanHallmark,
        'condensationSurfaceArea': condensationSurfaceArea,
        'volumetricCapacityBounds': volumetricCapacityBounds,
        'jointJoineryArchitecture': jointJoineryArchitecture.name,
        'metallurgicalGaugeThickness': metallurgicalGaugeThickness,
        'physicalProportions': physicalProportions,
        'preservationSoundness': preservationSoundness.name,
        'laboratoryGroundZero': laboratoryGroundZero.name,
        'customLaboratoryGroundZero': customLaboratoryGroundZero,
        'distillationMethod': distillationMethod.name,
        'era': era.name,
        'customEra': customEra,
        'temperatureRange': temperatureRange,
        'calibrationOrigin': calibrationOrigin.name,
        'customCalibrationOrigin': customCalibrationOrigin,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory DistillationVesselModel.fromJson(Map<String, dynamic> json) =>
      DistillationVesselModel(
        id: json['id'] ?? '',
        alembicLedgerKey: json['alembicLedgerKey'] ?? '',
        apparatusClassification: ApparatusClassification.values
                .asNameMap()[json['apparatusClassification']] ??
            ApparatusClassification.other,
        artisanHallmark: ArtisanHallmark.values
                .asNameMap()[json['artisanHallmark']] ??
            ArtisanHallmark.other,
        customArtisanHallmark: json['customArtisanHallmark'] ?? '',
        condensationSurfaceArea: json['condensationSurfaceArea'] ?? '',
        volumetricCapacityBounds: json['volumetricCapacityBounds'] ?? '',
        jointJoineryArchitecture: JointJoineryArchitecture.values
                .asNameMap()[json['jointJoineryArchitecture']] ??
            JointJoineryArchitecture.other,
        metallurgicalGaugeThickness: json['metallurgicalGaugeThickness'] ?? '',
        physicalProportions: json['physicalProportions'] ?? '',
        preservationSoundness: PreservationSoundness.values
                .asNameMap()[json['preservationSoundness']] ??
            PreservationSoundness.unknown,
        laboratoryGroundZero: LaboratoryGroundZero.values
                .asNameMap()[json['laboratoryGroundZero']] ??
            LaboratoryGroundZero.other,
        customLaboratoryGroundZero: json['customLaboratoryGroundZero'] ?? '',
        distillationMethod: DistillationMethod.values
                .asNameMap()[json['distillationMethod']] ??
            DistillationMethod.other,
        era: Era.values.asNameMap()[json['era']] ?? Era.other,
        customEra: json['customEra'] ?? '',
        temperatureRange: json['temperatureRange'] ?? '',
        calibrationOrigin: CalibrationOrigin.values
                .asNameMap()[json['calibrationOrigin']] ??
            CalibrationOrigin.other,
        customCalibrationOrigin: json['customCalibrationOrigin'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
