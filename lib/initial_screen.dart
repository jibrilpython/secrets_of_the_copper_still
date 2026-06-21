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
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _IntroBackdropPainter(
                    pulse: _slideController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
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
                        final trackHeight = 64.h;
                        final thumbWidth = 72.w;
                        final hInset = 4.w;
                        final vInset = 4.h;

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
                            SizedBox(
                              height: trackHeight,
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, track) {
                                    final thumbHeight =
                                        track.maxHeight - (vInset * 2);
                                    final laneWidth =
                                        track.maxWidth - (hInset * 2);
                                    final maxDrag = math.max(
                                      0.0,
                                      laneWidth - thumbWidth,
                                    );
                                    final progress = maxDrag > 0
                                        ? (_dragOffset / maxDrag).clamp(0.0, 1.0)
                                        : 0.0;

                                    return Stack(
                                      clipBehavior: Clip.none,
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
                                                color: Colors.white.withValues(
                                                  alpha: 0.45,
                                                ),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: hInset +
                                              _dragOffset.clamp(0.0, maxDrag),
                                          top: vInset,
                                          width: thumbWidth,
                                          height: thumbHeight,
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
                                            child: DecoratedBox(
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
                                                    alpha:
                                                        0.35 + progress * 0.15,
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

class _IntroBackdropPainter extends CustomPainter {
  _IntroBackdropPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF12100E),
            kPrimaryText,
            const Color(0xFF221810),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Offset.zero & size),
    );

    final warmGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.15, 0.92),
        radius: 0.75,
        colors: [
          kAccent.withValues(alpha: 0.07 + pulse * 0.02),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, warmGlow);

    final gridStepX = size.width / 11;
    final gridStepY = size.height / 18;
    final gridPaint = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.035);

    for (var x = gridStepX; x < size.width; x += gridStepX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = gridStepY; y < size.height; y += gridStepY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final copperLine = Paint()
      ..strokeWidth = 1
      ..color = kAccent.withValues(alpha: 0.08);
    for (final yFactor in [0.38, 0.52, 0.66]) {
      final y = size.height * yFactor;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), copperLine);
    }

    final ringCenter = Offset(
      size.width * 0.78,
      size.height * (0.28 + pulse * 0.015),
    );
    for (var i = 0; i < 4; i++) {
      final radius = size.width * (0.18 + i * 0.07);
      canvas.drawOval(
        Rect.fromCenter(
          center: ringCenter,
          width: radius * 2,
          height: radius * 1.15,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = kAccent.withValues(alpha: 0.06 - i * 0.008),
      );
    }

    final coilPath = Path();
    final coilOrigin = Offset(size.width * 0.62, size.height * 0.72);
    final coilW = size.width * 0.28;
    final coilH = size.height * 0.16;
    coilPath.moveTo(coilOrigin.dx, coilOrigin.dy);
    for (var i = 0; i < 5; i++) {
      final t = (i + 1) / 5.0;
      final left = i.isEven;
      final cx = coilOrigin.dx + (left ? -coilW * 0.28 : coilW * 0.28);
      final cy = coilOrigin.dy - coilH * t;
      final ex = coilOrigin.dx + (left ? -coilW * 0.42 : coilW * 0.42);
      final ey = cy - coilH * 0.05;
      coilPath.quadraticBezierTo(cx, cy, ex, ey);
    }

    canvas.drawPath(
      coilPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = kAccent.withValues(alpha: 0.07),
    );

    canvas.drawPath(
      coilPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = kAccent.withValues(alpha: 0.025)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant _IntroBackdropPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}
