import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/common/apparatus_silhouette.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/models/distillation_vessel_model.dart';
import 'package:secrets_of_the_copper_still/providers/vessel_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(vesselProvider).entries;
    final entryCount = entries.length;
    final lastEntry = entryCount > 0 ? entries.last : null;

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
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 140.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIdentityCard(),
                SizedBox(height: 16.h),
                _buildArchiveLedger(
                  entryCount: entryCount,
                  lastEntry: lastEntry,
                ),
                SizedBox(height: 24.h),
                _sectionLabel('DATA MANAGEMENT'),
                SizedBox(height: 12.h),
                _buildClearArchiveRow(
                  context: context,
                  ref: ref,
                  entryCount: entryCount,
                ),
                SizedBox(height: 28.h),
                Center(
                  child: Text(
                    '',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText.withValues(alpha: 0.7),
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
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
          'SETTINGS',
          style: GoogleFonts.ibmPlexMono(
            color: kAccent,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Still Registry',
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

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.ibmPlexMono(
        color: kSecondaryText,
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildIdentityCard() {
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
                    kAccentSurface.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -20.w,
              top: -20.h,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kAccent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 14.h,
              bottom: 14.h,
              child: Container(
                width: 3.w,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(kRadiusPill),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 18.w, 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ApparatusSilhouette(
                    type: ApparatusClassification.gooseneckAlembic,
                    preservation: PreservationSoundness.distillationReady,
                    size: 48,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secrets of the\nCopper Still',
                          style: GoogleFonts.cormorantGaramond(
                            color: kPrimaryText,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'A digital archive for vintage distillation apparatus — alembics, retorts, columns, and the laboratories that kept them.',
                          style: GoogleFonts.inter(
                            color: kSecondaryText,
                            fontSize: 12.sp,
                            height: 1.45,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveLedger({
    required int entryCount,
    required DistillationVesselModel? lastEntry,
  }) {
    return Container(
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
          _sectionLabel('ARCHIVE STATUS'),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entryCount.toString().padLeft(2, '0'),
                style: GoogleFonts.cormorantGaramond(
                  color: kPrimaryText,
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                  height: 0.9,
                ),
              ),
              SizedBox(width: 10.w),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  entryCount == 1 ? 'vessel filed' : 'vessels filed',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: kOutline),
          SizedBox(height: 14.h),
          Text(
            'LAST CATALOG ENTRY',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 7.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 6.h),
          if (lastEntry != null) ...[
            Text(
              lastEntry.alembicLedgerKey.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: kAccent,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              '${_formatDate(lastEntry.dateAdded)} · ${lastEntry.displayArtisan}',
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else
            Text(
              'No apparatus cataloged yet.',
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClearArchiveRow({
    required BuildContext context,
    required WidgetRef ref,
    required int entryCount,
  }) {
    final enabled = entryCount > 0;

    return GestureDetector(
      onTap: enabled ? () => _showClearAllDialog(context, ref) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(
              color: enabled
                  ? kError.withValues(alpha: 0.35)
                  : kOutline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: enabled ? kError : kOutline,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PURGE ARCHIVE',
                      style: GoogleFonts.ibmPlexMono(
                        color: enabled ? kError : kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      enabled
                          ? 'Permanently remove all vessel records'
                          : 'Nothing to remove',
                      style: GoogleFonts.inter(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.delete_outline_rounded,
                color: enabled ? kError : kSecondaryText,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
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
                        'PURGE ARCHIVE?',
                        style: GoogleFonts.ibmPlexMono(
                          color: kError,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Purge archive',
                        style: GoogleFonts.cormorantGaramond(
                          color: kPrimaryText,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'All vessel records will be permanently deleted. This cannot be undone.',
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
                                final prov = ref.read(vesselProvider);
                                while (prov.entries.isNotEmpty) {
                                  prov.deleteEntry(0);
                                }
                                Navigator.pop(ctx);
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
                                'PURGE',
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
