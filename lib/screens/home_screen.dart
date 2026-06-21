import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/common/apparatus_silhouette.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/models/distillation_vessel_model.dart';
import 'package:secrets_of_the_copper_still/providers/image_provider.dart';
import 'package:secrets_of_the_copper_still/providers/input_provider.dart';
import 'package:secrets_of_the_copper_still/providers/search_provider.dart';
import 'package:secrets_of_the_copper_still/providers/vessel_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DistillationMethod? _selectedMethodFilter;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final vesselProv = ref.watch(vesselProvider);
    final allEntries = vesselProv.entries;

    final filteredByMethod = _selectedMethodFilter == null
        ? allEntries
        : allEntries
            .where((e) => e.distillationMethod == _selectedMethodFilter)
            .toList();
    final entries = searchProv.filteredList(filteredByMethod);

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          if (vesselProv.isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2.h,
                color: kAccent,
                backgroundColor: kOutline,
              ),
            ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildHeader(allEntries.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: 10.h),
                      _buildMethodFilterChips(),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
              if (entries.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    0,
                    16.w,
                    tabScrollBottomPadding(context),
                  ),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final mainIndex = allEntries.indexOf(entry);
                      return _buildVesselCard(context, entry, mainIndex);
                    },
                  ),
                ),
            ],
          ),
          Positioned(
            right: 24.w,
            bottom: fabBottomOffset(context),
            child: FloatingActionButton.extended(
              onPressed: () {
                ref.read(inputProvider).clearAll();
                ref.read(imageProvider).clearImage();
                Navigator.pushNamed(context, '/add_screen');
              },
              backgroundColor: kPrimaryText,
              elevation: 8,
              label: Text(
                'ADD VESSEL',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              icon: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          16.w,
          MediaQuery.of(context).padding.top + 12.h,
          16.w,
          8.h,
        ),
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
                  border: Border.all(color: kOutline),
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
                right: -24.w,
                top: -24.h,
                child: Container(
                  width: 110.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kAccent.withValues(alpha: 0.07),
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
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 14.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THE',
                            style: GoogleFonts.ibmPlexMono(
                              color: kSecondaryText,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.5,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 38.sp,
                                fontWeight: FontWeight.w700,
                                height: 0.95,
                                letterSpacing: -0.5,
                                color: kPrimaryText,
                              ),
                              children: [
                                const TextSpan(text: 'Still'),
                                TextSpan(
                                  text: '.',
                                  style: TextStyle(color: kAccent),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Container(
                                width: 3.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius:
                                      BorderRadius.circular(kRadiusPill),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w300,
                                      height: 1.2,
                                      color: kSecondaryText,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Secrets of the ',
                                      ),
                                      TextSpan(
                                        text: 'Copper Still',
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.italic,
                                          color: kAccent,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: kAccent.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(kRadiusSubtle),
                            border: Border.all(
                              color: kAccent.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Center(
                            child: ApparatusSilhouette(
                              type: ApparatusClassification.gooseneckAlembic,
                              preservation:
                                  PreservationSoundness.distillationReady,
                              size: 26,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryText,
                            borderRadius:
                                BorderRadius.circular(kRadiusPill),
                          ),
                          child: Text(
                            count.toString().padLeft(2, '0'),
                            style: GoogleFonts.ibmPlexMono(
                              color: kAccentLight,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
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
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (v) => ref.read(searchProvider.notifier).setSearchQuery(v),
      style: GoogleFonts.inter(
        color: kPrimaryText,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'SEARCH APPARATUS...',
        hintStyle: GoogleFonts.inter(
          color: kSecondaryText.withValues(alpha: 0.4),
          fontSize: 16.sp,
          letterSpacing: 0.5,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 12.w),
          child: Icon(
            Icons.search_rounded,
            color: isFocused ? kAccent : kSecondaryText.withValues(alpha: 0.5),
            size: 24.sp,
          ),
        ),
        filled: true,
        fillColor: kPanelBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          borderSide: const BorderSide(color: kOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          borderSide: const BorderSide(color: kOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          borderSide: const BorderSide(color: kAccent, width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
      ),
    );
  }

  Widget _buildMethodFilterChips() {
    return SizedBox(
      height: 42.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _buildChip('ALL', null),
          ...DistillationMethod.values
              .where((m) => m != DistillationMethod.other)
              .map((m) => _buildChip(m.label.toUpperCase(), m)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, DistillationMethod? method) {
    final isSelected = _selectedMethodFilter == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethodFilter = method),
      child: AnimatedContainer(
        duration: kTransitionDuration,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(
            color: isSelected ? kAccent : kOutline,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: isSelected ? Colors.white : kSecondaryText,
            fontSize: 9.sp,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildVesselCard(
    BuildContext context,
    DistillationVesselModel entry,
    int mainIndex,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': mainIndex},
      ),
      child: AnimatedContainer(
        duration: kTransitionDuration,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          boxShadow: const [kShadowSubtle],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(
            color: kAccent,
            width: kStrokeWeight,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130.h,
              width: double.infinity,
              child: Hero(
                tag: 'item-$mainIndex',
                child: Container(
                  width: double.infinity,
                  color: kBackground.withValues(alpha: 0.5),
                  child: (entry.photoPath.isNotEmpty &&
                          imagePath != null &&
                          File(imagePath).existsSync())
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : Center(
                          child: ApparatusSilhouette(
                            type: entry.apparatusClassification,
                            preservation: entry.preservationSoundness,
                            size: 64.sp,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ApparatusSilhouette(
                        type: entry.apparatusClassification,
                        preservation: entry.preservationSoundness,
                        size: 18,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          entry.alembicLedgerKey.toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(
                            color: isOperational(entry.preservationSoundness)
                                ? kAccent
                                : kSecondaryAccent,
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    entry.displayArtisan,
                    style: GoogleFonts.inter(
                      color: kPrimaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    entry.apparatusClassification.label.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.capacityBadge.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _buildCapacityBadge(entry.capacityBadge),
                  ],
                  if (entry.displayLaboratory.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _buildProvenanceTag(entry.displayLaboratory),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityBadge(String capacity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        border: Border.all(color: kOutline),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        capacity,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.ibmPlexMono(
          color: kAccent,
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProvenanceTag(String lab) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: kBotanicalSurface,
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        lab,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.ibmPlexMono(
          color: kSecondaryAccent,
          fontSize: 7.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 100.h),
      child: Column(
        children: [
          ApparatusSilhouette(
            type: ApparatusClassification.gooseneckAlembic,
            preservation: PreservationSoundness.unknown,
            size: 80.sp,
          ),
          SizedBox(height: 24.h),
          Text(
            'NO APPARATUS IN THIS STILL YET.',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
