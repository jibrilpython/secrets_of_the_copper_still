import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/common/apparatus_silhouette.dart';
import 'package:secrets_of_the_copper_still/models/distillation_vessel_model.dart';
import 'package:secrets_of_the_copper_still/providers/image_provider.dart';
import 'package:secrets_of_the_copper_still/providers/vessel_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final index = args['index'] as int;

    final vesselProv = ref.watch(vesselProvider);
    if (index >= vesselProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          backgroundColor: kBackground,
          title: Text(
            'VESSEL NOT FOUND',
            style: GoogleFonts.ibmPlexMono(fontSize: 12.sp),
          ),
        ),
        body: Center(
          child: Text(
            'The requested apparatus could not be located in the registry.',
            style: GoogleFonts.inter(color: kSecondaryText, fontSize: 16.sp),
          ),
        ),
      );
    }

    final entry = vesselProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final hasPhoto = entry.photoPath.isNotEmpty &&
        imagePath != null &&
        File(imagePath).existsSync();

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor: kBackground,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = MediaQuery.of(context).padding.top;
                final collapsedHeight = topPadding + kToolbarHeight;
                final expandRatio = ((constraints.maxHeight - collapsedHeight) /
                        (280.h - collapsedHeight))
                    .clamp(0.0, 1.0);
                final onImage = expandRatio > 0.12;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'item-$index',
                            child: hasPhoto
                                ? Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: kPrimaryText,
                                    child: Center(
                                      child: ApparatusSilhouette(
                                        type: entry.apparatusClassification,
                                        preservation: entry.preservationSoundness,
                                        size: 100,
                                      ),
                                    ),
                                  ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!onImage)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 1,
                          color: kOutline,
                        ),
                      ),
                    Positioned(
                      top: topPadding,
                      left: 0,
                      right: 0,
                      height: kToolbarHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            _heroAction(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.pop(context),
                              onImage: onImage,
                            ),
                            const Spacer(),
                            _heroAction(
                              icon: Icons.delete_outline_rounded,
                              onTap: () =>
                                  _showDeleteDialog(context, ref, index),
                              onImage: onImage,
                            ),
                            SizedBox(width: 8.w),
                            _heroAction(
                              icon: Icons.edit_outlined,
                              onTap: () {
                                ref.read(vesselProvider).fillInput(ref, index);
                                Navigator.pushNamed(
                                  context,
                                  '/add_screen',
                                  arguments: {'index': index, 'isEdit': true},
                                );
                              },
                              onImage: onImage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIdentityCard(entry),
                  SizedBox(height: 24.h),
                  _buildSpecSection(
                    'APPARATUS SPECIFICATION',
                    _specificationRows(entry),
                  ),
                  SizedBox(height: 24.h),
                  _buildSpecSection(
                    'PROVENANCE',
                    _provenanceRows(entry),
                  ),
                  if (entry.notes.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _sectionTitle('ARCHIVAL NOTES'),
                    SizedBox(height: 12.h),
                    _buildNotesPanel(entry.notes),
                  ],
                  if (entry.tags.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildTags(entry.tags),
                  ],
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroAction({
    required IconData icon,
    required VoidCallback onTap,
    required bool onImage,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: 40.w, height: 40.w),
      onPressed: onTap,
      icon: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          color: onImage ? Colors.black.withValues(alpha: 0.25) : kPanelBg,
          border: Border.all(
            color: onImage
                ? Colors.white.withValues(alpha: 0.2)
                : kOutline,
          ),
          boxShadow: onImage ? null : const [kShadowSubtle],
        ),
        child: Icon(
          icon,
          color: onImage ? Colors.white : kPrimaryText,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(kRadiusPill),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecSection(String title, List<_SpecRow> rows) {
    final visible = rows.where((r) => r.value.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        SizedBox(height: 12.h),
        _buildSpecPanel(rows: visible),
      ],
    );
  }

  Widget _buildIdentityCard(DistillationVesselModel entry) {
    final preservationColor = getPreservationColor(entry.preservationSoundness);
    final preservationLabel = entry.preservationSoundness.label
        .split('—')
        .first
        .trim()
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        boxShadow: const [kShadowSubtle],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kPanelBg,
                border: Border.all(color: kAccent.withValues(alpha: 0.35)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kPanelBg,
                    kAccentSurface.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 14.h,
              bottom: 14.h,
              child: Container(
                width: 3.w,
                color: kAccent,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ApparatusSilhouette(
                        type: entry.apparatusClassification,
                        preservation: entry.preservationSoundness,
                        size: 40,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.apparatusClassification.label
                                  .toUpperCase(),
                              style: GoogleFonts.ibmPlexMono(
                                color: kAccent,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              entry.displayArtisan,
                              style: GoogleFonts.cormorantGaramond(
                                color: kPrimaryText,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.05,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    entry.alembicLedgerKey.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _metaChip(
                        preservationLabel,
                        color: preservationColor,
                        filled: true,
                      ),
                      _metaChip(entry.distillationMethod.label),
                      if (entry.capacityBadge.isNotEmpty)
                        _metaChip(entry.capacityBadge),
                      _metaChip(entry.displayEra),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(String label, {Color? color, bool filled = false}) {
    final chipColor = color ?? kSecondaryText;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: filled ? chipColor.withValues(alpha: 0.12) : kBackground,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(
          color: filled ? chipColor.withValues(alpha: 0.3) : kOutline,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          color: chipColor,
          fontSize: 7.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  List<_SpecRow> _specificationRows(DistillationVesselModel entry) {
    return [
      _SpecRow('Apparatus', entry.apparatusClassification.label),
      _SpecRow('Method', entry.distillationMethod.label),
      _SpecRow('Artisan', entry.displayArtisan),
      if (entry.volumetricCapacityBounds.isNotEmpty)
        _SpecRow('Capacity', entry.volumetricCapacityBounds),
      if (entry.condensationSurfaceArea.isNotEmpty)
        _SpecRow('Condensation', entry.condensationSurfaceArea),
      _SpecRow('Joinery', entry.jointJoineryArchitecture.label),
      if (entry.metallurgicalGaugeThickness.isNotEmpty)
        _SpecRow('Gauge', entry.metallurgicalGaugeThickness),
      if (entry.physicalProportions.isNotEmpty)
        _SpecRow('Proportions', entry.physicalProportions),
      if (entry.temperatureRange.isNotEmpty)
        _SpecRow('Temperature', entry.temperatureRange),
      _SpecRow(
        'Condition',
        entry.preservationSoundness.label,
        valueColor: getPreservationColor(entry.preservationSoundness),
      ),
    ];
  }

  List<_SpecRow> _provenanceRows(DistillationVesselModel entry) {
    return [
      _SpecRow('Era', entry.displayEra),
      _SpecRow('Laboratory', entry.displayLaboratory),
      _SpecRow('Calibration', entry.displayCalibrationOrigin),
      _SpecRow('Catalogued', _formatDate(entry.dateAdded)),
    ];
  }

  Widget _buildSpecPanel({
    required List<_SpecRow> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rows.asMap().entries.map((item) {
            final row = item.value;
            final isLast = item.key == rows.length - 1;
            return Column(
              children: [
                _ledgerRow(row.label, row.value, valueColor: row.valueColor),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Container(height: 1, color: kOutline),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _ledgerRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96.w,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: valueColor ?? kPrimaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesPanel(String notes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kBotanicalSurface,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kSecondaryAccent.withValues(alpha: 0.22)),
      ),
      child: Text(
        notes,
        style: GoogleFonts.inter(
          color: kPrimaryText,
          fontSize: 14.sp,
          height: 1.55,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: tags
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kOutline),
              ),
              child: Text(
                tag.toUpperCase(),
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 3.w, color: kError),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REMOVE FROM REGISTRY',
                        style: GoogleFonts.ibmPlexMono(
                          color: kError,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Delete vessel',
                        style: GoogleFonts.cormorantGaramond(
                          color: kPrimaryText,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'This record will be permanently removed from the alembic archive.',
                        style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 14.sp,
                          height: 1.45,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kSecondaryText,
                                side: const BorderSide(color: kOutline),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(kRadiusSubtle),
                                ),
                              ),
                              child: Text(
                                'KEEP',
                                style: GoogleFonts.ibmPlexMono(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ref.read(vesselProvider).deleteEntry(index);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kError,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(kRadiusSubtle),
                                ),
                              ),
                              child: Text(
                                'DELETE',
                                style: GoogleFonts.ibmPlexMono(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecRow {
  const _SpecRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}
