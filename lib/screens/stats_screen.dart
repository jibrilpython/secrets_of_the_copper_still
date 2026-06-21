import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/common/apparatus_silhouette.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/models/distillation_vessel_model.dart';
import 'package:secrets_of_the_copper_still/providers/vessel_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DistillationMethod? _selectedMethod;
  bool _showByEra = true;

  @override
  Widget build(BuildContext context) {
    final vesselProv = ref.watch(vesselProvider);
    final entries = vesselProv.entries;
    final isLoading = vesselProv.isLoading;
    final filtered = _selectedMethod == null
        ? entries
        : entries
            .where((e) => e.distillationMethod == _selectedMethod)
            .toList();

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                MediaQuery.of(context).padding.top + 16.h,
                16.w,
                12.h,
              ),
              child: _buildHeader(),
            ),
          ),
          if (isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: CircularProgressIndicator(
                    color: kAccent,
                    strokeWidth: 3,
                  ),
                ),
              ),
            )
          else if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 140.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMethodChips(entries),
                  SizedBox(height: 16.h),
                  if (filtered.isEmpty)
                    _buildFilteredEmpty()
                  else ...[
                    _buildArchiveOverview(filtered),
                    SizedBox(height: 24.h),
                    _buildApparatusSpread(filtered),
                    SizedBox(height: 24.h),
                    _buildPreservationRing(filtered),
                    SizedBox(height: 24.h),
                    _buildDistributionToggle(filtered),
                  ],
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOGBOOK',
          style: GoogleFonts.ibmPlexMono(
            color: kAccent,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Archive Intelligence',
          style: GoogleFonts.cormorantGaramond(
            color: kPrimaryText,
            fontSize: 32.sp,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ApparatusSilhouette(
          type: ApparatusClassification.gooseneckAlembic,
          preservation: PreservationSoundness.unknown,
          size: 72,
        ),
        SizedBox(height: 20.h),
        Text(
          'LOGBOOK EMPTY',
          style: GoogleFonts.ibmPlexMono(
            color: kPrimaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Add vessels to populate archive analytics.',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildFilteredEmpty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Center(
        child: Text(
          'NO VESSELS MATCH THIS FILTER.',
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMethodChips(List<DistillationVesselModel> all) {
    final methods = all.map((e) => e.distillationMethod).toSet().toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: methods.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) return _methodChip('ALL', null);
          final method = methods[index - 1];
          return _methodChip(method.label.toUpperCase(), method);
        },
      ),
    );
  }

  Widget _methodChip(String label, DistillationMethod? method) {
    final selected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: kTransitionDuration,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: selected ? kAccent : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(
            color: selected ? kAccent : kOutline,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: selected ? Colors.white : kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveOverview(List<DistillationVesselModel> filtered) {
    final total = filtered.length;

    final eraCounts = _stringCounts(filtered.map((e) => e.displayEra));
    final methodCounts = _classificationCounts(
      filtered.map((e) => e.distillationMethod),
    );

    final topMethod = _topEnumEntry(methodCounts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ARCHIVE SNAPSHOT'),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSnapshotHeader(
                total: total,
                eraCount: eraCounts.length,
                methodCount: methodCounts.length,
              ),
              SizedBox(height: 20.h),
              Container(height: 1, color: kOutline),
              SizedBox(height: 20.h),
              _buildEraSpan(eraCounts, total),
              if (topMethod != null) ...[
                SizedBox(height: 18.h),
                _snapshotLedgerRow(
                  leading: _methodGlyph(topMethod.key, size: 24),
                  leadingTint: kAccentSurface.withValues(alpha: 0.65),
                  kicker: 'METHOD',
                  title: topMethod.key.label,
                  share: total > 0 ? topMethod.value / total : 0,
                  accent: kAccentLight,
                  trailing: methodCounts.length > 1
                      ? '${methodCounts.length} methods'
                      : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSnapshotHeader({
    required int total,
    required int eraCount,
    required int methodCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          total.toString().padLeft(2, '0'),
          style: GoogleFonts.cormorantGaramond(
            color: kPrimaryText,
            fontSize: 48.sp,
            fontWeight: FontWeight.w700,
            height: 0.95,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          total == 1 ? 'vessel in archive' : 'vessels in archive',
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            _breadthChip('$eraCount ${eraCount == 1 ? 'era' : 'eras'}'),
            _breadthChip('$methodCount methods'),
          ],
        ),
      ],
    );
  }

  Widget _breadthChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          color: kSecondaryText,
          fontSize: 7.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _snapshotLedgerRow({
    required Widget leading,
    required Color leadingTint,
    required String kicker,
    required String title,
    required double share,
    required Color accent,
    String? trailing,
  }) {
    final pct = (share * 100).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: leadingTint,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline),
          ),
          alignment: Alignment.center,
          child: leading,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kicker,
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cormorantGaramond(
                  color: kPrimaryText,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: LinearProgressIndicator(
                  value: share.clamp(0.0, 1.0),
                  minHeight: 5.h,
                  backgroundColor: kBackground,
                  color: accent,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(height: 4.h),
                Text(
                  trailing,
                  style: GoogleFonts.inter(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          '$pct%',
          style: GoogleFonts.ibmPlexMono(
            color: accent,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Map<T, int> _classificationCounts<T>(Iterable<T> values) {
    final counts = <T, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }

  MapEntry<T, int>? _topEnumEntry<T>(Map<T, int> counts) {
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  }

  Widget _methodGlyph(DistillationMethod method, {double size = 22}) {
    final IconData icon;
    switch (method) {
      case DistillationMethod.steamDistillation:
        icon = Icons.water_drop_outlined;
      case DistillationMethod.dryDistillation:
        icon = Icons.local_fire_department_outlined;
      case DistillationMethod.fractional:
        icon = Icons.view_column_outlined;
      case DistillationMethod.vacuum:
        icon = Icons.compress_outlined;
      case DistillationMethod.solventExtraction:
        icon = Icons.science_outlined;
      case DistillationMethod.coldPressing:
        icon = Icons.ac_unit_outlined;
      case DistillationMethod.other:
        icon = Icons.more_horiz;
    }
    return Icon(icon, color: kAccentLight, size: size.sp);
  }

  Widget _buildEraSpan(Map<String, int> eraCounts, int total) {
    const maxVisible = 5;
    final sorted = eraCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visible = sorted.take(maxVisible).toList();
    final hidden = sorted.skip(maxVisible).toList();
    final displayEntries = hidden.isEmpty
        ? visible
        : [
            ...visible,
            MapEntry(
              'Others…',
              hidden.fold<int>(0, (sum, era) => sum + era.value),
            ),
          ];
    final palette = [
      kSecondaryAccent,
      kAccent,
      kAccentLight,
      const Color(0xFF8B6F4E),
      kSecondaryText,
      kOutline,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eraCounts.length == 1 ? 'ERA' : 'ERA SPAN',
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 7.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusPill),
          child: Row(
            children: [
              for (var i = 0; i < displayEntries.length; i++)
                Expanded(
                  flex: displayEntries[i].value,
                  child: Container(
                    height: 12.h,
                    color: palette[i % palette.length],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...displayEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final era = entry.value;
          final fraction = total > 0 ? era.value / total : 0.0;
          final color = palette[index % palette.length];
          final isOthers = era.key == 'Others…';
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    era.key,
                    style: GoogleFonts.cormorantGaramond(
                      color: isOthers ? kSecondaryText : kPrimaryText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontStyle: isOthers ? FontStyle.italic : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 56.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 4.h,
                      backgroundColor: kBackground,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 28.w,
                  child: Text(
                    '${era.value}',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.ibmPlexMono(
                      color: color,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Map<String, int> _stringCounts(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildApparatusSpread(List<DistillationVesselModel> filtered) {
    final counts = <ApparatusClassification, int>{};
    for (final e in filtered) {
      counts[e.apparatusClassification] =
          (counts[e.apparatusClassification] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) return const SizedBox.shrink();

    final maxVal = sorted.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('APPARATUS SPREAD'),
        SizedBox(height: 16.h),
        ...sorted.map(
          (item) => _buildBar(
            label: item.key.label,
            count: item.value,
            maxCount: maxVal,
            total: filtered.length,
            accent: getApparatusColor(item.key),
          ),
        ),
      ],
    );
  }

  Widget _buildBar({
    required String label,
    required int count,
    required int maxCount,
    required int total,
    required Color accent,
  }) {
    final fraction = maxCount > 0 ? count / maxCount : 0.0;
    final pct = total > 0 ? (count / total * 100).toInt() : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28.w,
              child: Text(
                '$pct%',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      color: kPrimaryText,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 5.h,
                      backgroundColor: kOutline,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              count.toString().padLeft(2, '0'),
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreservationRing(List<DistillationVesselModel> filtered) {
    final counts = <PreservationSoundness, int>{};
    for (final e in filtered) {
      counts[e.preservationSoundness] =
          (counts[e.preservationSoundness] ?? 0) + 1;
    }
    final total = filtered.length;
    final operational = counts[PreservationSoundness.distillationReady] ?? 0;
    final pct = total == 0 ? 0.0 : operational / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('PRESERVATION HEALTH'),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 92.w,
                    height: 92.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 92.w,
                          height: 92.w,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 9,
                            color: kBackground,
                          ),
                        ),
                        SizedBox(
                          width: 92.w,
                          height: 92.w,
                          child: CircularProgressIndicator(
                            value: pct,
                            strokeWidth: 9,
                            color: kAccent,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${(pct * 100).toInt()}%',
                              style: GoogleFonts.ibmPlexMono(
                                color: kPrimaryText,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Text(
                      '$operational of $total vessels distillation-ready.',
                      style: GoogleFonts.inter(
                        color: kSecondaryText,
                        fontSize: 13.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ...PreservationSoundness.values.map((state) {
                final c = counts[state] ?? 0;
                if (c == 0) return const SizedBox.shrink();
                final color = getPreservationColor(state);
                final fraction = total > 0 ? c / total : 0.0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 3,
                        child: Text(
                          state.label.split('—').first.trim(),
                          style: GoogleFonts.inter(
                            color: kPrimaryText,
                            fontSize: 11.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 4.h,
                            backgroundColor: kOutline,
                            color: color,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        c.toString(),
                        style: GoogleFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionToggle(List<DistillationVesselModel> filtered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionTitle(
                _showByEra ? 'ERA DISTRIBUTION' : 'LABORATORY DISTRIBUTION',
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showByEra = !_showByEra),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  border: Border.all(color: kOutline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showByEra
                          ? Icons.science_outlined
                          : Icons.schedule_rounded,
                      size: 12.sp,
                      color: kAccent,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _showByEra ? 'BY LAB' : 'BY ERA',
                      style: GoogleFonts.ibmPlexMono(
                        color: kAccent,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _showByEra
            ? _buildEraDistribution(filtered)
            : _buildLabDistribution(filtered),
      ],
    );
  }

  Widget _buildEraDistribution(List<DistillationVesselModel> filtered) {
    final counts = <String, int>{};
    for (final e in filtered) {
      final key = e.displayEra;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return _buildDistributionWrap(counts, kSecondaryAccent);
  }

  Widget _buildLabDistribution(List<DistillationVesselModel> filtered) {
    final counts = <String, int>{};
    for (final e in filtered) {
      final key = e.displayLaboratory;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return _buildDistributionWrap(counts, kAccent);
  }

  Widget _buildDistributionWrap(Map<String, int> counts, Color dot) {
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: sorted
          .map((item) => _distChip(item.key, item.value, dot))
          .toList(),
    );
  }

  Widget _distChip(String label, int count, Color dot) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7.w, height: 7.w, color: dot),
          SizedBox(width: 8.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 180.w),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            count.toString(),
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 3.w, height: 14.h, color: kAccent),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
