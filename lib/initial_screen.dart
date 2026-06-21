import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/common/apparatus_silhouette.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/providers/user_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryText,
      body: Stack(
        children: [
          Positioned(
            top: -80.h,
            right: -60.w,
            child: AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideController.value * 20),
                  child: Container(
                    width: 280.w,
                    height: 280.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          kAccent.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 180.h,
            left: -40.w,
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kSecondaryAccent.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _fadeController,
                  curve: Curves.easeOut,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    ApparatusSilhouette(
                      type: ApparatusClassification.gooseneckAlembic,
                      preservation: PreservationSoundness.distillationReady,
                      size: 48,
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      'Secrets of the\nCopper Still',
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: 48.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kAccent, kAccent.withValues(alpha: 0.2)],
                        ),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Catalog copper alembics, glass retorts, and fractional columns from the era before digital laboratory automation.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w300,
                        height: 1.55,
                      ),
                    ),
                    const Spacer(flex: 3),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const trackHeight = 64.0;
                        final thumbWidth = 72.w;
                        final thumbHeight = 56.h;
                        final hInset = 4.w;
                        final vInset = (trackHeight.h - thumbHeight) / 2;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SWIPE TO ENTER',
                              style: GoogleFonts.ibmPlexMono(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              height: trackHeight.h,
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                hInset,
                                vInset,
                                hInset,
                                vInset,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: LayoutBuilder(
                                builder: (context, inner) {
                                  final maxDrag = math.max(
                                    0.0,
                                    inner.maxWidth - thumbWidth,
                                  );
                                  final progress = maxDrag > 0
                                      ? (_dragOffset / maxDrag).clamp(0.0, 1.0)
                                      : 0.0;

                                  return Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Center(
                                        child: AnimatedOpacity(
                                          opacity: (1 - (progress * 2.5))
                                              .clamp(0.0, 1.0),
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          child: Text(
                                            'Open the archive',
                                            style: GoogleFonts.inter(
                                              color: Colors.white
                                                  .withValues(alpha: 0.45),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: _dragOffset.clamp(0.0, maxDrag),
                                        child: GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            setState(() {
                                              _dragOffset += details.delta.dx;
                                              _dragOffset = _dragOffset.clamp(
                                                0.0,
                                                maxDrag,
                                              );
                                            });
                                          },
                                          onHorizontalDragEnd: (_) {
                                            if (_dragOffset > maxDrag * 0.85) {
                                              ref
                                                  .read(userProvider)
                                                  .setFirstTimeUser(false);
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/home',
                                              );
                                            } else {
                                              setState(() => _dragOffset = 0);
                                            }
                                          },
                                          child: Container(
                                            width: thumbWidth,
                                            height: thumbHeight,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color.lerp(
                                                    kAccent,
                                                    kAccentLight,
                                                    progress,
                                                  )!,
                                                  kAccent,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              border: Border.all(
                                                color: kAccentLight.withValues(
                                                  alpha: 0.35 + progress * 0.15,
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 26.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
