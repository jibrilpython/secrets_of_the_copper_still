import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secrets_of_the_copper_still/models/distillation_vessel_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<DistillationVesselModel> filteredList(
    List<DistillationVesselModel> list,
  ) {
    if (searchQuery.isEmpty) {
      return list;
    }
    final query = searchQuery.toLowerCase();
    return list
        .where(
          (item) =>
              item.alembicLedgerKey.toLowerCase().contains(query) ||
              item.displayArtisan.toLowerCase().contains(query) ||
              item.displayLaboratory.toLowerCase().contains(query) ||
              item.condensationSurfaceArea.toLowerCase().contains(query) ||
              item.volumetricCapacityBounds.toLowerCase().contains(query) ||
              item.displayEra.toLowerCase().contains(query) ||
              item.apparatusClassification.label.toLowerCase().contains(query) ||
              item.distillationMethod.label.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)),
        )
        .toList();
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
