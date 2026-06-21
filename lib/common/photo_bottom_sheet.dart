import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secrets_of_the_copper_still/common/apparatus_silhouette.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/providers/image_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

void photoBottomSheet(
  BuildContext context,
  ImageNotifier imageProv,
  int index,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: kOutline,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: kAccentSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kAccent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Center(
                    child: ApparatusSilhouette(
                      type: ApparatusClassification.gooseneckAlembic,
                      preservation: PreservationSoundness.distillationReady,
                      size: 28,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Document Apparatus',
                  style: GoogleFonts.cormorantGaramond(
                    color: kPrimaryText,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Photograph on warm ivory — profile forward, no props',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: kSecondaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: _PhotoTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(ctx);
                      await imageProv.pickImage(source: ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _PhotoTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(ctx);
                      await imageProv.pickImage(source: ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8.h),
        ],
      ),
    ),
  );
}

class _PhotoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 28.h),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          children: [
            Icon(icon, color: kAccent, size: 32.sp),
            SizedBox(height: 12.h),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
