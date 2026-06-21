import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/common/photo_bottom_sheet.dart';
import 'package:secrets_of_the_copper_still/common/temperature_range_picker.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/providers/image_provider.dart';
import 'package:secrets_of_the_copper_still/providers/input_provider.dart';
import 'package:secrets_of_the_copper_still/providers/vessel_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';
import 'package:secrets_of_the_copper_still/utils/ledger_key_generator.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _EraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered =
        newValue.text.replaceAll(RegExp(r'[^0-9sS]'), '').toLowerCase();
    if (filtered.isEmpty) return TextEditingValue.empty;
    if (filtered.contains('s') && !filtered.endsWith('s')) {
      final parts = filtered.split('s');
      final fixed = '${parts.first}s';
      return TextEditingValue(
        text: fixed,
        selection: TextSelection.collapsed(offset: fixed.length),
      );
    }
    final digitPart = filtered.replaceAll('s', '');
    if (digitPart.length > 4 || filtered.length > 5) return oldValue;
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  late TextEditingController _ledgerCtrl;
  late TextEditingController _customArtisanCtrl;
  late TextEditingController _customLabCtrl;
  late TextEditingController _condensationCtrl;
  late TextEditingController _capacityCtrl;
  late TextEditingController _gaugeCtrl;
  late TextEditingController _proportionsCtrl;
  late TextEditingController _customEraCtrl;
  late TextEditingController _customCalibCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _ledgerCtrl = TextEditingController(text: p.alembicLedgerKey);
    _customArtisanCtrl = TextEditingController(text: p.customArtisanHallmark);
    _customLabCtrl =
        TextEditingController(text: p.customLaboratoryGroundZero);
    _condensationCtrl = TextEditingController(text: p.condensationSurfaceArea);
    _capacityCtrl = TextEditingController(text: p.volumetricCapacityBounds);
    _gaugeCtrl = TextEditingController(text: p.metallurgicalGaugeThickness);
    _proportionsCtrl = TextEditingController(text: p.physicalProportions);
    _customEraCtrl = TextEditingController(text: p.customEra);
    _customCalibCtrl = TextEditingController(text: p.customCalibrationOrigin);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));

    if (!widget.isEdit && p.alembicLedgerKey.isEmpty) {
      final key = LedgerKeyGenerator.generate(
        apparatus: p.apparatusClassification,
        method: p.distillationMethod,
      );
      _ledgerCtrl.text = key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(inputProvider).alembicLedgerKey = key;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _ledgerCtrl,
      _customArtisanCtrl,
      _customLabCtrl,
      _condensationCtrl,
      _capacityCtrl,
      _gaugeCtrl,
      _proportionsCtrl,
      _customEraCtrl,
      _customCalibCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _regenerateKey() {
    final p = ref.read(inputProvider);
    final key = LedgerKeyGenerator.generate(
      apparatus: p.apparatusClassification,
      method: p.distillationMethod,
    );
    _ledgerCtrl.text = key;
    p.alembicLedgerKey = key;
  }

  void _syncFields() {
    final p = ref.read(inputProvider);
    p.alembicLedgerKey = _ledgerCtrl.text;
    p.customArtisanHallmark = _customArtisanCtrl.text;
    p.artisanHallmark = ArtisanHallmark.other;
    p.customLaboratoryGroundZero = _customLabCtrl.text;
    p.laboratoryGroundZero = LaboratoryGroundZero.other;
    p.condensationSurfaceArea = _condensationCtrl.text;
    p.volumetricCapacityBounds = _capacityCtrl.text;
    p.metallurgicalGaugeThickness = _gaugeCtrl.text;
    p.physicalProportions = _proportionsCtrl.text;
    p.customEra = _customEraCtrl.text;
    p.customCalibrationOrigin = _customCalibCtrl.text;
    p.notes = _notesCtrl.text;
    p.tags = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    _syncFields();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SavingDialog(identifier: _ledgerCtrl.text),
    );
    await Future.delayed(const Duration(milliseconds: 1400));
    if (widget.isEdit) {
      ref.read(vesselProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(vesselProvider).addEntry(ref);
    }
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: kTransitionDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPanelBg,
      appBar: AppBar(
        backgroundColor: kPanelBg.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kPrimaryText, size: 28.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'EDIT VESSEL' : 'NEW VESSEL',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: kAccent,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Identify', 'Specify', 'Archive'];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 16.h),
      child: Row(
        children: List.generate(3, (i) {
          final isComplete = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: i <= _currentStep ? kAccent : kOutline,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: kTransitionDuration,
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: isActive
                            ? kAccent
                            : isComplete
                                ? kAccent.withValues(alpha: 0.12)
                                : kPanelBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive || isComplete ? kAccent : kOutline,
                        ),
                      ),
                      child: Center(
                        child: isComplete
                            ? Icon(Icons.check_rounded,
                                color: kAccent, size: 16.sp)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.ibmPlexMono(
                                  color: isActive
                                      ? Colors.white
                                      : kSecondaryText,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      labels[i],
                      style: GoogleFonts.ibmPlexMono(
                        color: isActive ? kAccent : kSecondaryText,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: i < _currentStep ? kAccent : kOutline,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vessel\nRegistry.',
            style: GoogleFonts.cormorantGaramond(
              color: kPrimaryText,
              fontSize: 48.sp,
              fontWeight: FontWeight.w600,
              height: 0.9,
            ),
          ),
          SizedBox(height: 24.h),
          _buildPhotoSection(),
          SizedBox(height: 32.h),
          _buildLedgerField(),
          _buildEnumSelectGroup<ApparatusClassification>(
            label: 'APPARATUS CLASSIFICATION',
            values: ApparatusClassification.values,
            current: ref.watch(inputProvider).apparatusClassification,
            onSelected: (v) {
              ref.read(inputProvider).apparatusClassification = v;
              if (!widget.isEdit) _regenerateKey();
            },
            labelBuilder: (v) => v.label,
          ),
          _buildEnumSelectGroup<DistillationMethod>(
            label: 'DISTILLATION METHOD',
            values: DistillationMethod.values,
            current: ref.watch(inputProvider).distillationMethod,
            onSelected: (v) {
              ref.read(inputProvider).distillationMethod = v;
              if (!widget.isEdit) _regenerateKey();
            },
            labelBuilder: (v) => v.label,
          ),
          _premiumField(
            label: 'ARTISAN HALLMARK',
            ctrl: _customArtisanCtrl,
            hint: 'e.g. AetherAlembic Smithing, Meridian Scientific Glass',
            onChanged: (v) =>
                ref.read(inputProvider).customArtisanHallmark = v,
          ),
          _premiumField(
            label: 'LABORATORY GROUND ZERO',
            ctrl: _customLabCtrl,
            hint:
                'e.g. Forgotten alpine herbal distillery, historic coastal perfume lab',
            onChanged: (v) =>
                ref.read(inputProvider).customLaboratoryGroundZero = v,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical\nParameters.',
            style: GoogleFonts.cormorantGaramond(
              color: kPrimaryText,
              fontSize: 48.sp,
              fontWeight: FontWeight.w600,
              height: 0.9,
            ),
          ),
          SizedBox(height: 32.h),
          _premiumField(
            label: 'VOLUMETRIC CAPACITY BOUNDS',
            ctrl: _capacityCtrl,
            hint: 'e.g. 5-Gallon Boiling Pot, 500mL Retort Flask',
            onChanged: (v) =>
                ref.read(inputProvider).volumetricCapacityBounds = v,
          ),
          _premiumField(
            label: 'CONDENSATION SURFACE AREA',
            ctrl: _condensationCtrl,
            hint: 'e.g. 120 sq-in jacketed surface, 8-turn copper spiral',
            onChanged: (v) =>
                ref.read(inputProvider).condensationSurfaceArea = v,
          ),
          _buildEnumSelectGroup<JointJoineryArchitecture>(
            label: 'JOINT JOINERY ARCHITECTURE',
            values: JointJoineryArchitecture.values,
            current: ref.watch(inputProvider).jointJoineryArchitecture,
            onSelected: (v) =>
                ref.read(inputProvider).jointJoineryArchitecture = v,
            labelBuilder: (v) => v.label,
          ),
          _premiumField(
            label: 'METALLURGICAL GAUGE THICKNESS',
            ctrl: _gaugeCtrl,
            hint: 'e.g. 16-gauge hammered copper, 2mm borosilicate',
            onChanged: (v) =>
                ref.read(inputProvider).metallurgicalGaugeThickness = v,
          ),
          _premiumField(
            label: 'PHYSICAL PROPORTIONS',
            ctrl: _proportionsCtrl,
            hint: 'Height, footprint, empty mass in kg',
            onChanged: (v) => ref.read(inputProvider).physicalProportions = v,
          ),
          TemperatureRangePicker(
            initialRange: ref.watch(inputProvider).temperatureRange,
            onChanged: (v) => ref.read(inputProvider).temperatureRange = v,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Archival\nRecord.',
            style: GoogleFonts.cormorantGaramond(
              color: kPrimaryText,
              fontSize: 48.sp,
              fontWeight: FontWeight.w600,
              height: 0.9,
            ),
          ),
          SizedBox(height: 32.h),
          _buildEnumSelectGroup<Era>(
            label: 'ERA OF PRODUCTION',
            values: Era.values,
            current: ref.watch(inputProvider).era,
            onSelected: (v) => ref.read(inputProvider).era = v,
            labelBuilder: (v) => v.label,
          ),
          if (ref.watch(inputProvider).era == Era.other)
            _premiumField(
              label: 'CUSTOM ERA',
              ctrl: _customEraCtrl,
              hint: 'e.g. 1880s, 1960s',
              onChanged: (v) => ref.read(inputProvider).customEra = v,
              inputFormatters: [_EraInputFormatter()],
            ),
          _buildEnumSelectGroup<CalibrationOrigin>(
            label: 'CALIBRATION ORIGIN',
            values: CalibrationOrigin.values,
            current: ref.watch(inputProvider).calibrationOrigin,
            onSelected: (v) => ref.read(inputProvider).calibrationOrigin = v,
            labelBuilder: (v) => v.label,
          ),
          if (ref.watch(inputProvider).calibrationOrigin ==
              CalibrationOrigin.other)
            _premiumField(
              label: 'CUSTOM CALIBRATION SITE',
              ctrl: _customCalibCtrl,
              hint: 'Steel mill, foundry, or ceramic kiln',
              onChanged: (v) =>
                  ref.read(inputProvider).customCalibrationOrigin = v,
            ),
          _buildEnumSelectGroup<PreservationSoundness>(
            label: 'PRESERVATION SOUNDNESS',
            values: PreservationSoundness.values,
            current: ref.watch(inputProvider).preservationSoundness,
            onSelected: (v) =>
                ref.read(inputProvider).preservationSoundness = v,
            labelBuilder: (v) => v.label.split('—').first.trim(),
          ),
          _premiumField(
            label: 'TAGS',
            ctrl: _tagsCtrl,
            hint: 'Comma-separated tags',
            onChanged: (_) {},
          ),
          _premiumField(
            label: 'NOTES',
            ctrl: _notesCtrl,
            hint: 'Archival condition notes...',
            maxLines: 4,
            onChanged: (v) => ref.read(inputProvider).notes = v,
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ALEMBIC LEDGER KEY',
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              if (!widget.isEdit)
                GestureDetector(
                  onTap: _regenerateKey,
                  child: Text(
                    'REGENERATE',
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          TextField(
            controller: _ledgerCtrl,
            readOnly: !widget.isEdit,
            onChanged: (v) => ref.read(inputProvider).alembicLedgerKey = v,
            style: GoogleFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'SCS-STILL-2291-BOTAN-M',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kBackground, width: 2.0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kAccent, width: 2.0),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumField({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: GoogleFonts.inter(
              color: kPrimaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: kSecondaryText.withValues(alpha: 0.3),
                fontSize: 18.sp,
                fontWeight: FontWeight.w300,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kBackground, width: 2.0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kAccent, width: 2.0),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnumSelectGroup<T>({
    required String label,
    required List<T> values,
    required T current,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: values.map((val) {
            final isSel = val == current;
            return GestureDetector(
              onTap: () => onSelected(val),
              child: AnimatedContainer(
                duration: kTransitionDuration,
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSel ? kPrimaryText : kBackground,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(
                    color: isSel ? kPrimaryText : kOutline,
                  ),
                ),
                child: Text(
                  labelBuilder(val).toUpperCase(),
                  style: GoogleFonts.inter(
                    color: isSel ? Colors.white : kPrimaryText,
                    fontSize: 11.sp,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () =>
          photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: imgPath != null && File(imgPath).existsSync()
            ? Image.file(File(imgPath), fit: BoxFit.cover)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: kSecondaryText.withValues(alpha: 0.5),
                      size: 40.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'UPLOAD APPARATUS PHOTOGRAPH',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNavButtons() {
    final isLast = _currentStep >= 2;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: kPanelBg,
        border: Border(top: BorderSide(color: kOutline.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Material(
              color: kBackground,
              borderRadius: BorderRadius.circular(kRadiusPill),
              child: InkWell(
                onTap: () => _pageController.previousPage(
                  duration: kTransitionDuration,
                  curve: Curves.easeInOut,
                ),
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: Icon(Icons.arrow_back_rounded,
                      color: kPrimaryText, size: 22.sp),
                ),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 12.w),
          Expanded(
            child: Material(
              color: kAccent,
              borderRadius: BorderRadius.circular(kRadiusPill),
              elevation: 0,
              child: InkWell(
                onTap: _nextStep,
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Submit to Registry' : 'Continue',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  final String identifier;
  const _SavingDialog({required this.identifier});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusMedium),
          boxShadow: const [kShadowFloat],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccent.withValues(alpha: 0.08),
              ),
              child: Center(
                child: SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: CircularProgressIndicator(
                    color: kAccent,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'CATALOGING VESSEL',
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              identifier,
              style: GoogleFonts.cormorantGaramond(
                color: kAccent,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16.h),
            Text(
              'Writing to permanent archive…',
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
