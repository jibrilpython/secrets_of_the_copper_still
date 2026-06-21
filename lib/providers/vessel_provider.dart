import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secrets_of_the_copper_still/models/distillation_vessel_model.dart';
import 'package:secrets_of_the_copper_still/providers/image_provider.dart';
import 'package:secrets_of_the_copper_still/providers/input_provider.dart';
import 'package:secrets_of_the_copper_still/utils/ledger_key_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class VesselNotifier extends ChangeNotifier {
  VesselNotifier() {
    loadEntries();
  }

  List<DistillationVesselModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'scs_vessels_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => DistillationVesselModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    final ledgerKey = p.alembicLedgerKey.trim().isNotEmpty
        ? p.alembicLedgerKey.trim()
        : LedgerKeyGenerator.generate(
            apparatus: p.apparatusClassification,
            method: p.distillationMethod,
          );

    final newEntry = DistillationVesselModel(
      id: _uuid.v4(),
      alembicLedgerKey: ledgerKey,
      apparatusClassification: p.apparatusClassification,
      artisanHallmark: p.artisanHallmark,
      customArtisanHallmark: p.customArtisanHallmark,
      condensationSurfaceArea: p.condensationSurfaceArea,
      volumetricCapacityBounds: p.volumetricCapacityBounds,
      jointJoineryArchitecture: p.jointJoineryArchitecture,
      metallurgicalGaugeThickness: p.metallurgicalGaugeThickness,
      physicalProportions: p.physicalProportions,
      preservationSoundness: p.preservationSoundness,
      laboratoryGroundZero: p.laboratoryGroundZero,
      customLaboratoryGroundZero: p.customLaboratoryGroundZero,
      distillationMethod: p.distillationMethod,
      era: p.era,
      customEra: p.customEra,
      temperatureRange: p.temperatureRange,
      calibrationOrigin: p.calibrationOrigin,
      customCalibrationOrigin: p.customCalibrationOrigin,
      notes: p.notes,
      photoPath:
          imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: p.dateAdded,
    );

    entries = [...entries, newEntry];
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    final updatedEntry = DistillationVesselModel(
      id: existing.id,
      alembicLedgerKey: p.alembicLedgerKey.trim().isNotEmpty
          ? p.alembicLedgerKey.trim()
          : existing.alembicLedgerKey,
      apparatusClassification: p.apparatusClassification,
      artisanHallmark: p.artisanHallmark,
      customArtisanHallmark: p.customArtisanHallmark,
      condensationSurfaceArea: p.condensationSurfaceArea,
      volumetricCapacityBounds: p.volumetricCapacityBounds,
      jointJoineryArchitecture: p.jointJoineryArchitecture,
      metallurgicalGaugeThickness: p.metallurgicalGaugeThickness,
      physicalProportions: p.physicalProportions,
      preservationSoundness: p.preservationSoundness,
      laboratoryGroundZero: p.laboratoryGroundZero,
      customLaboratoryGroundZero: p.customLaboratoryGroundZero,
      distillationMethod: p.distillationMethod,
      era: p.era,
      customEra: p.customEra,
      temperatureRange: p.temperatureRange,
      calibrationOrigin: p.calibrationOrigin,
      customCalibrationOrigin: p.customCalibrationOrigin,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    final newList = List<DistillationVesselModel>.from(entries);
    newList[index] = updatedEntry;
    entries = newList;

    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    final newList = List<DistillationVesselModel>.from(entries);
    newList.removeAt(index);
    entries = newList;

    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.alembicLedgerKey = entry.alembicLedgerKey;
    p.apparatusClassification = entry.apparatusClassification;
    p.artisanHallmark = entry.artisanHallmark;
    p.customArtisanHallmark = entry.customArtisanHallmark;
    p.condensationSurfaceArea = entry.condensationSurfaceArea;
    p.volumetricCapacityBounds = entry.volumetricCapacityBounds;
    p.jointJoineryArchitecture = entry.jointJoineryArchitecture;
    p.metallurgicalGaugeThickness = entry.metallurgicalGaugeThickness;
    p.physicalProportions = entry.physicalProportions;
    p.preservationSoundness = entry.preservationSoundness;
    p.laboratoryGroundZero = entry.laboratoryGroundZero;
    p.customLaboratoryGroundZero = entry.customLaboratoryGroundZero;
    p.distillationMethod = entry.distillationMethod;
    p.era = entry.era;
    p.customEra = entry.customEra;
    p.temperatureRange = entry.temperatureRange;
    p.calibrationOrigin = entry.calibrationOrigin;
    p.customCalibrationOrigin = entry.customCalibrationOrigin;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final vesselProvider = ChangeNotifierProvider<VesselNotifier>(
  (ref) => VesselNotifier(),
);
