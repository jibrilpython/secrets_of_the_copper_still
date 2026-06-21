import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

class TemperatureRangePicker extends StatefulWidget {
  final String initialRange;
  final ValueChanged<String> onChanged;

  const TemperatureRangePicker({
    super.key,
    this.initialRange = '',
    required this.onChanged,
  });

  static (double, double) parseRange(String value) {
    final match = RegExp(r'(\d+)\s*°?\s*C?\s*[–\-]\s*(\d+)').firstMatch(value);
    if (match != null) {
      return (
        double.tryParse(match.group(1)!) ?? 40,
        double.tryParse(match.group(2)!) ?? 200,
      );
    }
    return (60, 180);
  }

  @override
  State<TemperatureRangePicker> createState() => _TemperatureRangePickerState();
}

class _TemperatureRangePickerState extends State<TemperatureRangePicker> {
  static const _floor = 20.0;
  static const _ceiling = 300.0;

  late double _low;
  late double _high;

  @override
  void initState() {
    super.initState();
    final parsed = TemperatureRangePicker.parseRange(widget.initialRange);
    _low = parsed.$1.clamp(_floor, _ceiling - 10);
    _high = parsed.$2.clamp(_low + 10, _ceiling);
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  void _emit() {
    widget.onChanged('${_low.toInt()}°C – ${_high.toInt()}°C');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEMPERATURE RANGE',
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _tempReadout(_low, 'MIN'),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: kAccentSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                    child: Text(
                      'OPERATING ENVELOPE',
                      style: GoogleFonts.ibmPlexMono(
                        color: kAccent,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  _tempReadout(_high, 'MAX'),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 56.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _RheostatTrack(
                      low: _low,
                      high: _high,
                      floor: _floor,
                      ceiling: _ceiling,
                    ),
                    RangeSlider(
                      values: RangeValues(_low, _high),
                      min: _floor,
                      max: _ceiling,
                      divisions: 28,
                      activeColor: kAccent,
                      inactiveColor: kOutline,
                      overlayColor: WidgetStateProperty.all(
                        kAccent.withValues(alpha: 0.12),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _low = v.start;
                          _high = v.end;
                        });
                        _emit();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_floor.toInt()}°C',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 9.sp,
                    ),
                  ),
                  Text(
                    '${_ceiling.toInt()}°C',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _tempReadout(double value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 7.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          '${value.toInt()}°C',
          style: GoogleFonts.ibmPlexMono(
            color: kPrimaryText,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RheostatTrack extends StatelessWidget {
  final double low;
  final double high;
  final double floor;
  final double ceiling;

  const _RheostatTrack({
    required this.low,
    required this.high,
    required this.floor,
    required this.ceiling,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 56.h),
      painter: _RheostatPainter(
        low: low,
        high: high,
        floor: floor,
        ceiling: ceiling,
      ),
    );
  }
}

class _RheostatPainter extends CustomPainter {
  final double low;
  final double high;
  final double floor;
  final double ceiling;

  _RheostatPainter({
    required this.low,
    required this.high,
    required this.floor,
    required this.ceiling,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height / 2;
    const inset = 24.0;
    final trackW = size.width - inset * 2;

    final trackPaint = Paint()
      ..color = kOutline
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(inset, trackY),
      Offset(inset + trackW, trackY),
      trackPaint,
    );

    final lowFrac = (low - floor) / (ceiling - floor);
    final highFrac = (high - floor) / (ceiling - floor);
    final activePaint = Paint()
      ..color = kAccent.withValues(alpha: 0.35)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(inset + trackW * lowFrac, trackY),
      Offset(inset + trackW * highFrac, trackY),
      activePaint,
    );

    final tickPaint = Paint()
      ..color = kSecondaryText.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var i = 0; i <= 10; i++) {
      final x = inset + trackW * (i / 10);
      canvas.drawLine(Offset(x, trackY - 10), Offset(x, trackY + 10), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RheostatPainter old) =>
      old.low != low || old.high != high;
}
