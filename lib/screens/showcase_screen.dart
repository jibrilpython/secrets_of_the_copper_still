import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secrets_of_the_copper_still/common/apparatus_silhouette.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/models/distillation_vessel_model.dart';
import 'package:secrets_of_the_copper_still/providers/vessel_provider.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

const Color kLabDark = Color(0xFF181410);
const Color kCondensateShine = Color(0xFFB8D4E8);

Color methodVaporColor(DistillationMethod method) {
  switch (method) {
    case DistillationMethod.steamDistillation:
      return const Color(0xFFD4843A);
    case DistillationMethod.dryDistillation:
      return const Color(0xFFE8A04A);
    case DistillationMethod.fractional:
      return const Color(0xFFB8D4E8);
    case DistillationMethod.vacuum:
      return const Color(0xFF9BB8D4);
    case DistillationMethod.solventExtraction:
      return const Color(0xFF6FA882);
    case DistillationMethod.coldPressing:
      return const Color(0xFFA8D8E8);
    case DistillationMethod.other:
      return const Color(0xFF7A7268);
  }
}

double stillIntensity(int vesselCount) {
  if (vesselCount <= 1) return 0.22;
  if (vesselCount <= 3) return 0.42;
  if (vesselCount <= 6) return 0.62;
  if (vesselCount <= 10) return 0.82;
  return 1.0;
}

class VaporBubble {
  Offset position;
  double radius;
  double speed;
  double opacity;
  double wobble;
  double depth;
  Color color;

  VaporBubble({
    required this.position,
    required this.color,
    this.radius = 3,
    this.speed = 1.2,
    this.opacity = 0.7,
    this.wobble = 0,
    this.depth = 1,
  });
}

class CondensateDroplet {
  double progress;
  double speed;
  double size;
  Color color;

  CondensateDroplet({
    required this.color,
    this.progress = 0,
    this.speed = 0.004,
    this.size = 3,
  });
}

class HeatBurst {
  Offset origin;
  double radius;
  double opacity;
  double intensity;
  Color color;

  HeatBurst({
    required this.origin,
    required this.color,
    this.intensity = 1.0,
  })  : radius = 0,
        opacity = 1.0;

  void tick() {
    radius += 3.5 * intensity;
    opacity = 1.0 - (radius / 120).clamp(0.0, 1.0);
  }

  bool get isDead => opacity <= 0;
}

class CoilTrace {
  final double targetT;
  final Color color;
  final int nodeIndex;
  double headT;
  double opacity;
  bool hapticFired;

  CoilTrace({
    required this.targetT,
    required this.color,
    required this.nodeIndex,
  })  : headT = 0,
        opacity = 1,
        hapticFired = false;
}

class FlaskRipple {
  double radius;
  double opacity;

  FlaskRipple() : radius = 4, opacity = 0.85;

  void tick() {
    radius += 2.2;
    opacity -= 0.035;
  }

  bool get isDead => opacity <= 0;
}

class VesselNode {
  final DistillationVesselModel model;
  final int index;
  final double pathT;

  VesselNode({
    required this.model,
    required this.index,
    required this.pathT,
  });
}

class _FieldLayout {
  _FieldLayout(this.size, this.tiltAngle);

  final Size size;
  final double tiltAngle;

  Offset get pivot => Offset(size.width * 0.5, size.height * 0.45);
  Offset get potCenter => Offset(size.width * 0.5, size.height * 0.82);
  Offset get flaskCenter => pointOnWorm(1.0);

  Path buildWormPath() {
    final pot = potCenter;
    final path = Path();
    final coilW = size.width * 0.52;
    final coilH = size.height * 0.36;
    final origin = Offset(pot.dx, pot.dy - 56.h);

    path.moveTo(origin.dx, origin.dy);
    for (var i = 0; i < 6; i++) {
      final t = (i + 1) / 6.0;
      final left = i.isEven;
      final cx = origin.dx + (left ? -coilW * 0.32 : coilW * 0.32);
      final cy = origin.dy - coilH * t;
      final ex = origin.dx + (left ? -coilW * 0.46 : coilW * 0.46);
      final ey = cy - coilH * 0.06;
      path.quadraticBezierTo(cx, cy, ex, ey);
    }
    return path;
  }

  Offset pointOnWorm(double t) {
    final metrics = buildWormPath().computeMetrics().first;
    final tangent = metrics.getTangentForOffset(
      metrics.length * t.clamp(0.0, 1.0),
    );
    return tangent?.position ?? potCenter;
  }

  Offset toScreen(Offset local) {
    final v = local - pivot;
    final c = math.cos(tiltAngle);
    final s = math.sin(tiltAngle);
    return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c) + pivot;
  }

  double get nodeRadius => 20.w;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  final List<VaporBubble> _vapors = [];
  final List<CondensateDroplet> _droplets = [];
  final List<HeatBurst> _heatBursts = [];
  final List<VesselNode> _nodes = [];
  final List<CoilTrace> _coilTraces = [];
  final List<FlaskRipple> _flaskRipples = [];

  double _tiltAngle = 0;
  double _tiltVelocity = 0;
  double _dragTiltStart = 0;
  double _dragStartX = 0;
  bool _isDragging = false;
  bool _isMapBuilt = false;
  int _lastHash = -1;
  bool _nodeSyncScheduled = false;
  int? _focusedIndex;
  bool _panelLocked = false;
  double _pulse = 0;
  double _flaskFill = 0;
  Size _fieldSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final entries = ref.read(vesselProvider).entries;
    if (entries.isEmpty || _fieldSize == Size.zero) return;

    final layout = _FieldLayout(_fieldSize, _tiltAngle);
    final intensity = stillIntensity(entries.length);
    final potCenter = layout.potCenter;
    final maxVapors = (40 + intensity * 70).round();
    final maxDroplets = (12 + intensity * 40).round();
    bool changed = false;

    _pulse += 0.04;

    if (!_isDragging && !_panelLocked) {
      _tiltAngle += _tiltVelocity;
      _tiltVelocity *= 0.92;
      _tiltAngle += (0 - _tiltAngle) * 0.06;
      _tiltAngle = _tiltAngle.clamp(-0.5, 0.5);
      changed = true;
    }

    final vaporTarget = (8 + intensity * 18 + _heatBursts.length * 2).round();
    if (_vapors.length < vaporTarget) {
      final method = entries[math.Random().nextInt(entries.length)].distillationMethod;
      _vapors.add(
        VaporBubble(
          position: layout.toScreen(
            Offset(
              potCenter.dx + (math.Random().nextDouble() - 0.5) * 36.w,
              potCenter.dy - 18.h,
            ),
          ),
          color: methodVaporColor(method),
          radius: 2 + math.Random().nextDouble() * 4,
          speed: (0.7 + math.Random().nextDouble() * 1.2) * (0.6 + intensity * 0.7),
          wobble: math.Random().nextDouble() * math.pi * 2,
          depth: 0.6 + math.Random().nextDouble() * 0.8,
        ),
      );
      changed = true;
    }

    if (intensity > 0.35 &&
        math.Random().nextDouble() < 0.04 * intensity &&
        _nodes.isNotEmpty) {
      final node = _nodes[math.Random().nextInt(_nodes.length)];
      final local = layout.pointOnWorm(node.pathT);
      _vapors.add(
        VaporBubble(
          position: layout.toScreen(
            Offset(
              local.dx + (math.Random().nextDouble() - 0.5) * 20.w,
              local.dy + (math.Random().nextDouble() - 0.5) * 12.h,
            ),
          ),
          color: methodVaporColor(node.model.distillationMethod),
          radius: 1.5 + math.Random().nextDouble() * 3,
          speed: 0.5 + math.Random().nextDouble(),
          opacity: 0.55,
        ),
      );
      changed = true;
    }

    for (final burst in _heatBursts) {
      if (math.Random().nextDouble() < 0.28 * burst.intensity) {
        final angle = math.Random().nextDouble() * math.pi * 2;
        final dist = math.Random().nextDouble() * burst.radius * 0.45;
        _vapors.add(
          VaporBubble(
            position: burst.origin +
                Offset(math.cos(angle) * dist, math.sin(angle) * dist),
            color: burst.color,
            radius: 2 + math.Random().nextDouble() * 5,
            speed: 1.2 + math.Random().nextDouble() * 1.8,
          ),
        );
        changed = true;
      }
    }

    for (int i = _vapors.length - 1; i >= 0; i--) {
      final v = _vapors[i];
      v.wobble += 0.07;
      v.position = Offset(
        v.position.dx + math.sin(v.wobble) * 0.5 * v.depth,
        v.position.dy - v.speed * (0.8 + v.depth * 0.4),
      );
      v.opacity -= 0.003;
      v.radius += 0.016;
      if (v.opacity <= 0 || v.position.dy < _fieldSize.height * 0.1) {
        _vapors.removeAt(i);
      }
      changed = true;
    }

    final dropletChance = 0.04 + intensity * 0.12;
    if (_droplets.length < maxDroplets && math.Random().nextDouble() < dropletChance) {
      final method = entries[math.Random().nextInt(entries.length)].distillationMethod;
      _droplets.add(
        CondensateDroplet(
          color: methodVaporColor(method),
          progress: 0.01,
          speed: (0.0025 + math.Random().nextDouble() * 0.002) *
              (0.7 + intensity * 0.8),
        ),
      );
      changed = true;
    }

    for (int i = _droplets.length - 1; i >= 0; i--) {
      final d = _droplets[i];
      d.progress += d.speed * (1 + _tiltAngle.abs() * 0.45);
      if (d.progress >= 1) {
        _flaskFill = (_flaskFill + 0.035 * intensity).clamp(0.0, 1.0);
        _flaskRipples.add(FlaskRipple());
        _droplets.removeAt(i);
      }
      changed = true;
    }

    for (int i = _coilTraces.length - 1; i >= 0; i--) {
      final trace = _coilTraces[i];
      trace.headT += 0.022;
      if (trace.headT >= trace.targetT && !trace.hapticFired) {
        trace.hapticFired = true;
        HapticFeedback.mediumImpact();
        final node = _nodes.firstWhere((n) => n.index == trace.nodeIndex);
        final local = layout.pointOnWorm(node.pathT);
        for (var j = 0; j < 6; j++) {
          _vapors.add(
            VaporBubble(
              position: layout.toScreen(local),
              color: trace.color,
              radius: 2 + math.Random().nextDouble() * 3,
              speed: 0.6 + math.Random().nextDouble(),
              opacity: 0.8,
            ),
          );
        }
      }
      if (trace.headT >= trace.targetT + 0.08) {
        trace.opacity -= 0.04;
      }
      if (trace.opacity <= 0) _coilTraces.removeAt(i);
      changed = true;
    }

    for (int i = _heatBursts.length - 1; i >= 0; i--) {
      _heatBursts[i].tick();
      if (_heatBursts[i].isDead) _heatBursts.removeAt(i);
      changed = true;
    }

    for (int i = _flaskRipples.length - 1; i >= 0; i--) {
      _flaskRipples[i].tick();
      if (_flaskRipples[i].isDead) _flaskRipples.removeAt(i);
      changed = true;
    }

    _flaskFill = (_flaskFill - 0.0008).clamp(0.0, 1.0);

    while (_vapors.length > maxVapors) {
      _vapors.removeAt(0);
    }

    if (changed) setState(() {});
  }

  void _scheduleNodeSync(
    List<DistillationVesselModel> entries,
    Size size,
    int stateVersion,
  ) {
    if (size == Size.zero) return;

    final hash = Object.hash(
      stateVersion,
      entries.length,
      size.width.round(),
      size.height.round(),
    );
    if (_isMapBuilt && _lastHash == hash) return;
    if (_nodeSyncScheduled) return;

    _nodeSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodeSyncScheduled = false;
      if (!mounted) return;

      final latest = ref.read(vesselProvider);
      final latestHash = Object.hash(
        latest.stateVersion,
        latest.entries.length,
        size.width.round(),
        size.height.round(),
      );
      if (_isMapBuilt && _lastHash == latestHash) return;

      setState(() {
        _fieldSize = size;
        _rebuildNodes(latest.entries, size, latestHash);
      });
    });
  }

  void _rebuildNodes(
    List<DistillationVesselModel> entries,
    Size size,
    int hash,
  ) {
    _isMapBuilt = true;
    _lastHash = hash;
    _nodes.clear();

    if (entries.isEmpty) return;

    final layout = _FieldLayout(size, 0);
    const candidateSteps = 56;
    final minDist = layout.nodeRadius * 2.35;
    final placedPositions = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final targetT = (i + 1) / (entries.length + 1);
      double? chosenT;
      var bestPenalty = double.infinity;

      for (var step = 1; step < candidateSteps; step++) {
        final t = step / candidateSteps;
        if (t < 0.06 || t > 0.94) continue;
        final pos = layout.pointOnWorm(t);

        var tooClose = false;
        for (final placed in placedPositions) {
          if ((pos - placed).distance < minDist) {
            tooClose = true;
            break;
          }
        }
        if (tooClose) continue;

        final penalty = (t - targetT).abs();
        if (penalty < bestPenalty) {
          bestPenalty = penalty;
          chosenT = t;
        }
      }

      chosenT ??= targetT.clamp(0.06, 0.94);
      placedPositions.add(layout.pointOnWorm(chosenT));
      _nodes.add(
        VesselNode(
          model: entries[i],
          index: i,
          pathT: chosenT,
        ),
      );
    }
  }

  void _openNode(VesselNode node) {
    if (_panelLocked) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _panelLocked = true;
      _focusedIndex = node.index;
    });
  }

  void _traceNode(VesselNode node) {
    if (_panelLocked) return;
    HapticFeedback.selectionClick();
    setState(() {
      _coilTraces.add(
        CoilTrace(
          targetT: node.pathT,
          color: methodVaporColor(node.model.distillationMethod),
          nodeIndex: node.index,
        ),
      );
    });
  }

  void _spawnHeat(Offset local) {
    if (_panelLocked) return;
    HapticFeedback.lightImpact();
    setState(() {
      _heatBursts.add(
        HeatBurst(
          origin: local,
          color: kAccent,
          intensity: 1.1 + stillIntensity(ref.read(vesselProvider).entries.length),
        ),
      );
      for (var i = 0; i < 8; i++) {
        _vapors.add(
          VaporBubble(
            position: local +
                Offset((math.Random().nextDouble() - 0.5) * 24, 8),
            color: kAccentLight,
            speed: 1.0 + math.Random().nextDouble() * 1.4,
            radius: 2 + math.Random().nextDouble() * 3,
          ),
        );
      }
    });
  }

  void _onTapDown(TapDownDetails details) {
    if (_panelLocked) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final layout = _FieldLayout(_fieldSize, _tiltAngle);
    for (final node in _nodes) {
      final pos = layout.toScreen(layout.pointOnWorm(node.pathT));
      if ((pos - local).distance < layout.nodeRadius + 12.w) return;
    }
    _spawnHeat(local);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_panelLocked) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final layout = _FieldLayout(_fieldSize, _tiltAngle);
    for (final node in _nodes) {
      final pos = layout.toScreen(layout.pointOnWorm(node.pathT));
      if ((pos - local).distance < layout.nodeRadius + 12.w) return;
    }

    _isDragging = true;
    _dragTiltStart = _tiltAngle;
    _dragStartX = local.dx;
    _tiltVelocity = 0;
    HapticFeedback.selectionClick();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_panelLocked || !_isDragging) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    setState(() {
      _tiltAngle =
          (_dragTiltStart + (local.dx - _dragStartX) * 0.0028).clamp(-0.5, 0.5);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    _tiltVelocity = details.velocity.pixelsPerSecond.dx * 0.000015;
    HapticFeedback.lightImpact();
  }

  void _releasePanel() {
    setState(() {
      _panelLocked = false;
      _focusedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vessel = ref.watch(vesselProvider);
    final entries = vessel.entries;

    return Scaffold(
      backgroundColor: kLabDark,
      body: entries.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                _fieldSize = size;
                _scheduleNodeSync(entries, size, vessel.stateVersion);
                return _buildFieldView(entries);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ApparatusSilhouette(
            type: ApparatusClassification.wormCondenser,
            preservation: PreservationSoundness.unknown,
            size: 80.sp,
          ),
          SizedBox(height: 24.h),
          Text(
            'STILL OFFLINE',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Catalog vessels to ignite the condensate field',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldView(List<DistillationVesselModel> entries) {
    final layout = _FieldLayout(_fieldSize, _tiltAngle);
    final intensity = stillIntensity(entries.length);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _CondensateFieldPainter(
                layout: layout,
                vapors: _vapors,
                droplets: _droplets,
                heatBursts: _heatBursts,
                nodes: _nodes,
                coilTraces: _coilTraces,
                flaskFill: _flaskFill,
                flaskRipples: _flaskRipples,
                pulse: _pulse,
                intensity: intensity,
                dimNodes: _panelLocked,
                focusedIndex: _focusedIndex,
              ),
              size: Size.infinite,
            ),
          ),
          ..._nodes.map((node) => _buildNodeTarget(node, layout)),
          ..._nodes.map((node) => _buildNodeOverlay(node, layout)),
          if (!_panelLocked) _buildHud(intensity, entries.length),
          if (_panelLocked && _focusedIndex != null)
            _buildFocusPanel(entries[_focusedIndex!]),
        ],
      ),
    );
  }

  Widget _buildNodeTarget(VesselNode node, _FieldLayout layout) {
    final pos = layout.toScreen(layout.pointOnWorm(node.pathT));
    final r = layout.nodeRadius + 10.w;

    return Positioned(
      left: pos.dx - r,
      top: pos.dy - r,
      width: r * 2,
      height: r * 2,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _openNode(node),
        onLongPress: () => _traceNode(node),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildNodeOverlay(VesselNode node, _FieldLayout layout) {
    final pos = layout.toScreen(layout.pointOnWorm(node.pathT));
    final r = layout.nodeRadius;
    final dim = _panelLocked && _focusedIndex != node.index;
    final tracing = _coilTraces.any((t) => t.nodeIndex == node.index);

    return Positioned(
      left: pos.dx - r,
      top: pos.dy - r,
      child: IgnorePointer(
        child: AnimatedScale(
          scale: tracing ? 1.12 : 1.0,
          duration: kTransitionDuration,
          child: AnimatedOpacity(
            opacity: dim ? 0.35 : 1,
            duration: kTransitionDuration,
            child: SizedBox(
              width: r * 2,
              height: r * 2,
              child: Center(
                child: ApparatusSilhouette(
                  type: node.model.apparatusClassification,
                  preservation: node.model.preservationSoundness,
                  size: r * 0.72,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHud(double intensity, int count) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 32.h,
      left: 24.w,
      right: 24.w,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: kLabDark.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kAccent.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'ORIGIN MAP',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Condensate Field',
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontSize: 36.sp,
              fontWeight: FontWeight.w600,
              height: 0.95,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kAccent.withValues(alpha: 0.25)),
            ),
            child: Text(
              'TOUCH HEAT · DRAG TILT · HOLD NODE',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: intensity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${(intensity * 100).round()}% STILL LOAD',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent.withValues(alpha: 0.7),
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFocusPanel(DistillationVesselModel entry) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _releasePanel,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: kLabDark.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Container(
            width: 0.88.sw,
            constraints: BoxConstraints(maxHeight: 0.72.sh),
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(kRadiusMedium),
              boxShadow: const [kShadowFloat],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: kOutline)),
                  ),
                  child: Row(
                    children: [
                      ApparatusSilhouette(
                        type: entry.apparatusClassification,
                        preservation: entry.preservationSoundness,
                        size: 28.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          entry.alembicLedgerKey.toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(
                            color: kAccent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.displayArtisan,
                          style: GoogleFonts.cormorantGaramond(
                            color: kPrimaryText,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w600,
                            height: 0.95,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 16.h),
                        _detailRow('Apparatus', entry.apparatusClassification.label),
                        _detailRow('Method', entry.distillationMethod.label),
                        _detailRow('Era', entry.displayEra),
                        _detailRow('Laboratory', entry.displayLaboratory),
                        _detailRow(
                          'Preservation',
                          entry.preservationSoundness.label.split('—').first.trim(),
                        ),
                        if (entry.volumetricCapacityBounds.isNotEmpty)
                          _detailRow('Capacity', entry.volumetricCapacityBounds),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final idx = _focusedIndex;
                    _releasePanel();
                    if (idx != null) {
                      Navigator.pushNamed(
                        context,
                        '/info_screen',
                        arguments: {'index': idx},
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    color: kPrimaryText,
                    child: Center(
                      child: Text(
                        'OPEN VESSEL DOSSIER',
                        style: GoogleFonts.ibmPlexMono(
                          color: kAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CondensateFieldPainter extends CustomPainter {
  final _FieldLayout layout;
  final List<VaporBubble> vapors;
  final List<CondensateDroplet> droplets;
  final List<HeatBurst> heatBursts;
  final List<VesselNode> nodes;
  final List<CoilTrace> coilTraces;
  final List<FlaskRipple> flaskRipples;
  final double pulse;
  final double intensity;
  final double flaskFill;
  final bool dimNodes;
  final int? focusedIndex;

  _CondensateFieldPainter({
    required this.layout,
    required this.vapors,
    required this.droplets,
    required this.heatBursts,
    required this.nodes,
    required this.coilTraces,
    required this.flaskRipples,
    required this.pulse,
    required this.intensity,
    required this.flaskFill,
    required this.dimNodes,
    required this.focusedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLabGrid(canvas, size);
    _drawAmbientGlow(canvas, size);

    canvas.save();
    canvas.translate(layout.pivot.dx, layout.pivot.dy);
    canvas.rotate(layout.tiltAngle);
    canvas.translate(-layout.pivot.dx, -layout.pivot.dy);

    _drawCollectingFlask(canvas, size);
    _drawStillPot(canvas, size);
    _drawWormCondenser(canvas, size);
    _drawCoilTraces(canvas);
    _drawDroplets(canvas);
    _drawNodes(canvas);
    canvas.restore();

    _drawVapors(canvas);
    _drawHeatBursts(canvas);
  }

  void _drawLabGrid(Canvas canvas, Size size) {
    final frameRect = Rect.fromLTWH(
      12.w,
      12.h,
      size.width - 24.w,
      size.height - 24.h,
    );
    final gridTop = math.max(frameRect.top, size.height * 0.28);

    canvas.save();
    canvas.clipRect(frameRect);

    const verticalCount = 11;
    const horizontalCount = 12;
    final gridHeight = frameRect.bottom - gridTop;
    final stepX = frameRect.width / verticalCount;
    final stepY = gridHeight / horizontalCount;

    for (var i = 1; i < verticalCount; i++) {
      final x = frameRect.left + i * stepX;
      final paint = Paint()
        ..color = kAccent.withValues(alpha: 0.08 + (i % 3) * 0.015)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x, gridTop),
        Offset(x, frameRect.bottom),
        paint,
      );
    }

    for (var j = 0; j <= horizontalCount; j++) {
      final y = gridTop + j * stepY;
      if (y > frameRect.bottom) continue;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.05 + (j % 2) * 0.012)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(frameRect.left, y),
        Offset(frameRect.right, y),
        paint,
      );
    }

    canvas.restore();

    final frame = Paint()
      ..color = kAccent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(frameRect, frame);
  }

  void _drawAmbientGlow(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          kAccent.withValues(alpha: 0.08 + intensity * 0.14),
          Colors.transparent,
        ],
        radius: 0.65,
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.58),
      );
    canvas.drawRect(Offset.zero & size, glow);
  }

  void _drawCollectingFlask(Canvas canvas, Size size) {
    final center = layout.flaskCenter;
    final w = 28.w;
    final h = 38.h;

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      Radius.circular(6.r),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = kCondensateShine.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = kCondensateShine.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - h * 0.42),
        width: w * 0.55,
        height: 8.h,
      ),
      Paint()
        ..color = kCondensateShine.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    if (flaskFill > 0.02) {
      final fillH = h * 0.75 * flaskFill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            center.dx - w * 0.38,
            center.dy + h * 0.32 - fillH,
            center.dx + w * 0.38,
            center.dy + h * 0.32,
          ),
          Radius.circular(4.r),
        ),
        Paint()..color = kCondensateShine.withValues(alpha: 0.35 + intensity * 0.2),
      );
    }

    for (final ripple in flaskRipples) {
      canvas.drawCircle(
        Offset(center.dx, center.dy + h * 0.1),
        ripple.radius,
        Paint()
          ..color = kCondensateShine.withValues(alpha: ripple.opacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawStillPot(Canvas canvas, Size size) {
    final cx = layout.potCenter.dx;
    final cy = layout.potCenter.dy;
    final w = size.width * 0.36;
    final h = size.height * 0.1;
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(h * 0.42));
    final bodyTop = cy - h * 0.5;
    final neckTop = bodyTop + h * 0.06;
    final neckBottom = cy - 56.h;
    final neckTopW = 18.w;
    final neckBottomW = 10.w;
    final lipRect = Rect.fromCenter(
      center: Offset(cx, bodyTop + h * 0.04),
      width: w * 0.9,
      height: h * 0.14,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + h * 0.46),
        width: w * 0.78,
        height: h * 0.28,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5A3010),
            kAccent,
            kAccentLight.withValues(alpha: 0.88),
            kAccent,
            const Color(0xFF4A280C),
          ],
          stops: const [0.0, 0.25, 0.52, 0.78, 1.0],
        ).createShader(bodyRect),
    );

    final neckPath = Path()
      ..moveTo(cx - neckTopW * 0.5, neckTop)
      ..lineTo(cx - neckBottomW * 0.5, neckBottom)
      ..lineTo(cx + neckBottomW * 0.5, neckBottom)
      ..lineTo(cx + neckTopW * 0.5, neckTop)
      ..close();
    canvas.drawPath(
      neckPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF5A3010),
            kAccent,
            const Color(0xFF5A3010),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromLTRB(
            cx - neckTopW * 0.5,
            neckBottom,
            cx + neckTopW * 0.5,
            neckTop,
          ),
        ),
    );

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = kAccent.withValues(alpha: 0.4 + intensity * 0.12);

    canvas.drawRRect(bodyRRect, outline);
    canvas.drawPath(neckPath, outline);

    canvas.drawOval(
      lipRect,
      Paint()
        ..color = const Color(0xFF3D220A).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final flameAlpha = 0.32 + intensity * 0.42 + math.sin(pulse) * 0.07;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + h * 0.62),
        width: 64.w + intensity * 36.w,
        height: 34.h + intensity * 16.h,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            kAccentLight.withValues(alpha: flameAlpha),
            kAccent.withValues(alpha: flameAlpha * 0.2),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(cx, cy + h * 0.62),
            width: 64.w + intensity * 36.w,
            height: 34.h + intensity * 16.h,
          ),
        ),
    );
  }

  void _drawWormCondenser(Canvas canvas, Size size) {
    final path = layout.buildWormPath();

    final glowPaint = Paint()
      ..color = kAccent.withValues(alpha: 0.1 + intensity * 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);

    final coilPaint = Paint()
      ..color = kAccentLight.withValues(alpha: 0.55 + intensity * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, coilPaint);

    final innerPaint = Paint()
      ..color = kCondensateShine.withValues(alpha: 0.18 + intensity * 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, innerPaint);
  }

  void _drawCoilTraces(Canvas canvas) {
    final path = layout.buildWormPath();
    final metrics = path.computeMetrics().first;

    for (final trace in coilTraces) {
      final head = (trace.headT * metrics.length).clamp(0.0, metrics.length);
      final tail = (math.max(0, trace.headT - 0.18) * metrics.length)
          .clamp(0.0, metrics.length);
      if (head <= tail) continue;

      final segment = metrics.extractPath(tail, head);
      final glow = Paint()
        ..color = trace.color.withValues(alpha: trace.opacity * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(segment, glow);

      final core = Paint()
        ..color = trace.color.withValues(alpha: trace.opacity * 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(segment, core);

      final headPos = metrics.getTangentForOffset(head)?.position;
      if (headPos != null) {
        canvas.drawCircle(
          headPos,
          5,
          Paint()..color = Colors.white.withValues(alpha: trace.opacity * 0.8),
        );
      }
    }
  }

  void _drawNodes(Canvas canvas) {
    for (final node in nodes) {
      final pos = layout.pointOnWorm(node.pathT);
      final color = getApparatusColor(node.model.apparatusClassification);
      final methodColor = methodVaporColor(node.model.distillationMethod);
      final isFocused = focusedIndex == node.index;
      final dim = dimNodes && !isFocused;
      final r = layout.nodeRadius;
      final ring = r + 4 + math.sin(pulse + node.pathT * 6) * 2;
      final sphereRect = Rect.fromCircle(center: pos, radius: r);

      canvas.drawOval(
        Rect.fromCenter(
          center: pos + Offset(0, r * 0.38),
          width: r * 1.55,
          height: r * 0.48,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: dim ? 0.12 : 0.34)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      canvas.drawCircle(
        pos,
        ring + 6,
        Paint()
          ..color = methodColor.withValues(alpha: dim ? 0.04 : 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      canvas.drawCircle(
        pos,
        ring,
        Paint()
          ..color = methodColor.withValues(alpha: dim ? 0.06 : 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.38, -0.42),
            radius: 0.92,
            colors: [
              Colors.white.withValues(alpha: dim ? 0.18 : 0.42),
              color.withValues(alpha: dim ? 0.55 : 0.92),
              kLabDark.withValues(alpha: dim ? 0.65 : 0.95),
            ],
            stops: const [0.0, 0.42, 1.0],
          ).createShader(sphereRect),
      );

      canvas.drawCircle(
        pos,
        r * 0.78,
        Paint()
          ..shader = RadialGradient(
            colors: [
              kLabDark.withValues(alpha: dim ? 0.35 : 0.55),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: pos, radius: r * 0.78)),
      );

      canvas.drawCircle(
        pos + Offset(-r * 0.3, -r * 0.34),
        r * 0.2,
        Paint()..color = Colors.white.withValues(alpha: dim ? 0.22 : 0.62),
      );

      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: r - 1.5),
        math.pi * 0.12,
        math.pi * 0.76,
        false,
        Paint()
          ..color = methodColor.withValues(alpha: dim ? 0.18 : 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = color.withValues(alpha: dim ? 0.35 : 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isFocused ? 3 : 2,
      );

      if (isFocused) {
        canvas.drawCircle(
          pos,
          r + 2.5,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
  }

  void _drawVapors(Canvas canvas) {
    for (final v in vapors) {
      final paint = Paint()
        ..color = v.color.withValues(alpha: v.opacity * 0.75)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * v.depth);
      canvas.drawCircle(v.position, v.radius, paint);
      canvas.drawCircle(
        v.position,
        v.radius * 0.45,
        Paint()..color = Colors.white.withValues(alpha: v.opacity * 0.3),
      );
    }
  }

  void _drawDroplets(Canvas canvas) {
    for (final d in droplets) {
      final pos = layout.pointOnWorm(1 - d.progress);
      canvas.drawCircle(
        pos,
        d.size,
        Paint()..color = d.color.withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        pos + const Offset(1, 1),
        d.size * 0.35,
        Paint()..color = Colors.white.withValues(alpha: 0.65),
      );
    }
  }

  void _drawHeatBursts(Canvas canvas) {
    for (final h in heatBursts) {
      final paint = Paint()
        ..color = h.color.withValues(alpha: h.opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(h.origin, h.radius, paint);
      canvas.drawCircle(
        h.origin,
        h.radius * 0.35,
        Paint()..color = h.color.withValues(alpha: h.opacity * 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CondensateFieldPainter oldDelegate) => true;
}
