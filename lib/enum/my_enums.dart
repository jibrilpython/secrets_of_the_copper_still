enum ApparatusClassification {
  gooseneckAlembic('Gooseneck Alembic'),
  wormCondenser('Worm Condenser'),
  fractionalColumn('Fractional Column'),
  glassRetort('Glass Retort'),
  separationFunnel('Separation Funnel'),
  steamJacketedPot('Steam-Jacketed Pot'),
  brassHydrometer('Brass Hydrometer'),
  other('Other');

  const ApparatusClassification(this.label);
  final String label;

  String get code {
    switch (this) {
      case ApparatusClassification.gooseneckAlembic:
        return 'ALEMB';
      case ApparatusClassification.wormCondenser:
        return 'WORM';
      case ApparatusClassification.fractionalColumn:
        return 'FRACT';
      case ApparatusClassification.glassRetort:
        return 'RETOR';
      case ApparatusClassification.separationFunnel:
        return 'FUNNL';
      case ApparatusClassification.steamJacketedPot:
        return 'STEAM';
      case ApparatusClassification.brassHydrometer:
        return 'HYDRO';
      case ApparatusClassification.other:
        return 'MISC';
    }
  }
}

enum DistillationMethod {
  steamDistillation('Steam Distillation'),
  dryDistillation('Dry Distillation'),
  fractional('Fractional'),
  vacuum('Vacuum'),
  solventExtraction('Solvent Extraction'),
  coldPressing('Cold Pressing'),
  other('Other');

  const DistillationMethod(this.label);
  final String label;

  String get code {
    switch (this) {
      case DistillationMethod.steamDistillation:
        return 'STEAM';
      case DistillationMethod.dryDistillation:
        return 'DRY';
      case DistillationMethod.fractional:
        return 'FRAC';
      case DistillationMethod.vacuum:
        return 'VAC';
      case DistillationMethod.solventExtraction:
        return 'SOLV';
      case DistillationMethod.coldPressing:
        return 'COLD';
      case DistillationMethod.other:
        return 'MISC';
    }
  }
}

enum JointJoineryArchitecture {
  groundGlassTaper('Ground-glass Standard Taper Joint'),
  rivetedCopperFlange('Riveted Copper Flange with Linseed Paste Seal'),
  threadedBrassUnion('Threaded Brass Union'),
  silverSoldered('Silver-Soldered Copper Joint'),
  other('Other');

  const JointJoineryArchitecture(this.label);
  final String label;
}

enum PreservationSoundness {
  distillationReady('Distillation-Ready — Seals Intact'),
  displayCabinet('Display Cabinet — Museum Preserved'),
  copperPitting('Copper Pitting — Shallow Surface Depth'),
  glassScoring('Glass Scoring — Visible Score Lines'),
  verdigrisCorrosion('Verdigris Corrosion — Active Oxidation'),
  unknown('Unknown');

  const PreservationSoundness(this.label);
  final String label;
}

enum ArtisanHallmark {
  aetherAlembic('AetherAlembic Smithing'),
  meridianGlass('Meridian Scientific Glass'),
  providenceCopper('Providence Copper & Brass'),
  grasseAtelier('Grasse Atelier Works'),
  alpineCopper('Alpine Copper Foundry'),
  other('Other / Unknown');

  const ArtisanHallmark(this.label);
  final String label;
}

enum LaboratoryGroundZero {
  alpineHerbalDistillery('Forgotten Alpine Herbal Distillery'),
  coastalPerfumeLab('Historic Coastal Perfume Lab Warehouse'),
  cityChemicalArchives('Old City Industrial Chemical Archives'),
  florentineRosewater('Florentine Rosewater Processing Plant'),
  parisPharmacie('Paris École de Pharmacie Annex'),
  londonApothecary('London Apothecary Laboratory'),
  other('Other / Unrecorded');

  const LaboratoryGroundZero(this.label);
  final String label;
}

enum CalibrationOrigin {
  steelMill('Steel Mill Calibration Works'),
  copperFoundry('Copper Foundry & Brass Works'),
  ceramicKiln('Ceramic Kiln Laboratory'),
  glassworks('Scientific Glassworks'),
  other('Other / Unknown');

  const CalibrationOrigin(this.label);
  final String label;
}

enum Era {
  era1850s('1850s'),
  era1880s('1880s'),
  era1910s('1910s'),
  era1930s('1930s'),
  era1950s('1950s'),
  era1960s('1960s'),
  other('Uncertain');

  const Era(this.label);
  final String label;
}
