import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 3D Faceted Brilliant-Cut Crystal Diamond Custom Painter.
///
/// High-performance zero-allocation rendering reproducing exact 3D geometry,
/// lighting calculations, metallic gold specular highlights, and diamond brilliance.
class Diamond3DPainter extends CustomPainter {
  Diamond3DPainter({
    required this.rotationY,
    required this.scaleFactor,
    required this.opacity,
  });

  final double rotationY;
  final double scaleFactor;
  final double opacity;

  static const List<double> _lightDir = <double>[0.42, 0.78, 0.52];
  static const double _fov = 460.0;
  static const double _pitchX = 0.36;
  static const double _rollZ = 0.06;

  static final List<List<double>> _vertices = _computeVertices();
  static final List<_DiamondFace> _faces = _computeFaces();
  static final List<double> _normalizedLight = _normalize(_lightDir);

  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _sparklePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.1;

  // Zero-allocation scratch buffers to prevent GC stutter on mobile devices
  static final Float64List _tx = Float64List(_vertices.length);
  static final Float64List _ty = Float64List(_vertices.length);
  static final Float64List _tz = Float64List(_vertices.length);
  static final Float64List _px = Float64List(_vertices.length);
  static final Float64List _py = Float64List(_vertices.length);
  static final List<_RenderedFace> _faceBuffers = List<_RenderedFace>.generate(
    _faces.length,
    (int index) => _RenderedFace(),
  );
  static final Path _facePath = Path();

  static List<List<double>> _computeVertices() {
    const double rGirdle = 76.0;
    const double rTable = 40.0;
    const double hCrown = 30.0;
    const double hGirdleHalf = 2.0;
    const double hPavilion = 72.0;

    final List<List<double>> vertices = <List<double>>[];

    // 1. Table Octagon (indices 0..7)
    for (int i = 0; i < 8; i++) {
      final double ang = (i * math.pi) / 4.0;
      vertices.add(<double>[rTable * math.cos(ang), rTable * math.sin(ang), hCrown]);
    }

    // 2. Upper Girdle (indices 8..23)
    for (int i = 0; i < 16; i++) {
      final double ang = (i * math.pi) / 8.0;
      vertices.add(<double>[rGirdle * math.cos(ang), rGirdle * math.sin(ang), hGirdleHalf]);
    }

    // 3. Lower Girdle (indices 24..39)
    for (int i = 0; i < 16; i++) {
      final double ang = (i * math.pi) / 8.0;
      vertices.add(<double>[rGirdle * math.cos(ang), rGirdle * math.sin(ang), -hGirdleHalf]);
    }

    // 4. Culet apex (index 40)
    vertices.add(<double>[0.0, 0.0, -hPavilion]);

    // 5. Mid-pavilion star vertices (indices 41..48)
    const double rMidPav = 38.0;
    const double hMidPav = -35.0;
    for (int i = 0; i < 8; i++) {
      final double ang = ((i + 0.5) * math.pi) / 4.0;
      vertices.add(<double>[rMidPav * math.cos(ang), rMidPav * math.sin(ang), hMidPav]);
    }

    return List<List<double>>.unmodifiable(vertices);
  }

  static List<_DiamondFace> _computeFaces() {
    const int culetIdx = 40;
    const int midPavStart = 41;
    final List<_DiamondFace> faces = <_DiamondFace>[];

    // 1. Table
    for (int i = 1; i < 7; i++) {
      faces.add(_DiamondFace(indices: <int>[0, i, i + 1], type: 'table'));
    }

    // 2. Crown & Star facets
    for (int i = 0; i < 8; i++) {
      final int t0 = i;
      final int t1 = (i + 1) % 8;
      final int g0 = 8 + i * 2;
      final int g1 = 8 + (i * 2 + 1) % 16;
      final int g2 = 8 + (i * 2 + 2) % 16;

      faces.add(_DiamondFace(indices: <int>[t0, t1, g1], type: 'star'));
      faces.add(_DiamondFace(indices: <int>[t0, g0, g1], type: 'crown'));
      faces.add(_DiamondFace(indices: <int>[t1, g1, g2], type: 'crown'));
    }

    // 3. Girdle bands
    for (int i = 0; i < 16; i++) {
      final int u0 = 8 + i;
      final int u1 = 8 + (i + 1) % 16;
      final int l0 = 24 + i;
      final int l1 = 24 + (i + 1) % 16;
      faces.add(_DiamondFace(indices: <int>[u0, l0, l1], type: 'girdle'));
      faces.add(_DiamondFace(indices: <int>[u0, l1, u1], type: 'girdle'));
    }

    // 4. Pavilion
    for (int i = 0; i < 8; i++) {
      final int l0 = 24 + i * 2;
      final int l1 = 24 + (i * 2 + 1) % 16;
      final int l2 = 24 + (i * 2 + 2) % 16;
      final int mp = midPavStart + i;

      faces.add(_DiamondFace(indices: <int>[l0, l1, mp], type: 'pavilion'));
      faces.add(_DiamondFace(indices: <int>[l1, l2, mp], type: 'pavilion'));
      faces.add(_DiamondFace(indices: <int>[mp, l0, culetIdx], type: 'pavilion'));
      faces.add(_DiamondFace(indices: <int>[mp, culetIdx, l2], type: 'pavilion'));
    }

    return List<_DiamondFace>.unmodifiable(faces);
  }

  static List<double> _normalize(List<double> v) {
    final double len = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (len == 0) return const <double>[0.0, 0.0, 0.0];
    return <double>[v[0] / len, v[1] / len, v[2] / len];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001 || scaleFactor <= 0.001) return;

    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    final double cosY = math.cos(rotationY);
    final double sinY = math.sin(rotationY);
    final double cosX = math.cos(_pitchX);
    final double sinX = math.sin(_pitchX);
    final double cosZ = math.cos(_rollZ);
    final double sinZ = math.sin(_rollZ);

    for (int i = 0; i < _vertices.length; i++) {
      final List<double> v = _vertices[i];
      final double x = v[0] * scaleFactor;
      final double y = v[1] * scaleFactor;
      final double z = v[2] * scaleFactor;

      // Rotation around Y
      final double x1 = x * cosY + z * sinY;
      final double y1 = y;
      final double z1 = -x * sinY + z * cosY;

      // Rotation around X (pitch)
      final double x2 = x1;
      final double y2 = y1 * cosX - z1 * sinX;
      final double z2 = y1 * sinX + z1 * cosX;

      // Rotation around Z (roll)
      final double x3 = x2 * cosZ - y2 * sinZ;
      final double y3 = x2 * sinZ + y2 * cosZ;
      final double z3 = z2;

      _tx[i] = x3;
      _ty[i] = y3;
      _tz[i] = z3;

      final double zDist = math.max(60.0, _fov + z3);
      final double pFactor = _fov / zDist;
      _px[i] = cx + x3 * pFactor;
      _py[i] = cy - y3 * pFactor;
    }

    final int faceCount = _faces.length;
    for (int i = 0; i < faceCount; i++) {
      final _DiamondFace face = _faces[i];
      final int i0 = face.indices[0];
      final int i1 = face.indices[1];
      final int i2 = face.indices[2];

      final double e1x = _tx[i1] - _tx[i0];
      final double e1y = _ty[i1] - _ty[i0];
      final double e1z = _tz[i1] - _tz[i0];

      final double e2x = _tx[i2] - _tx[i0];
      final double e2y = _ty[i2] - _ty[i0];
      final double e2z = _tz[i2] - _tz[i0];

      // Cross product
      double nx = e1y * e2z - e1z * e2y;
      double ny = e1z * e2x - e1x * e2z;
      double nz = e1x * e2y - e1y * e2x;
      final double normLen = math.sqrt(nx * nx + ny * ny + nz * nz);
      if (normLen > 0.000001) {
        nx /= normLen;
        ny /= normLen;
        nz /= normLen;
      }

      final double zAvg = (_tz[i0] + _tz[i1] + _tz[i2]) / 3.0;
      final bool isFront = nz > -0.15;

      final double dotL = math.max(
        0.0,
        nx * _normalizedLight[0] + ny * _normalizedLight[1] + nz * _normalizedLight[2],
      );

      final double rz = 2.0 * dotL * nz - _normalizedLight[2];
      final double specular = math.pow(math.max(0.0, rz), 16).toDouble();

      final _RenderedFace rf = _faceBuffers[i];
      rf.i0 = i0;
      rf.i1 = i1;
      rf.i2 = i2;
      rf.zAvg = zAvg;
      rf.isFront = isFront;
      rf.dotL = dotL;
      rf.specular = specular;
    }

    // Painter's algorithm: sort back-to-front by depth (furthest with largest zAvg first)
    _faceBuffers.sort((_RenderedFace a, _RenderedFace b) => b.zAvg.compareTo(a.zAvg));

    for (int i = 0; i < faceCount; i++) {
      final _RenderedFace item = _faceBuffers[i];
      final double p0x = _px[item.i0];
      final double p0y = _py[item.i0];
      final double p1x = _px[item.i1];
      final double p1y = _py[item.i1];
      final double p2x = _px[item.i2];
      final double p2y = _py[item.i2];

      _facePath.reset();
      _facePath.moveTo(p0x, p0y);
      _facePath.lineTo(p1x, p1y);
      _facePath.lineTo(p2x, p2y);
      _facePath.close();

      if (!item.isFront) {
        // Back facet shading (translucent warm champagne gold)
        _fillPaint.color = Color.fromRGBO(210, 175, 115, 0.22 * opacity);
        canvas.drawPath(_facePath, _fillPaint);

        _strokePaint.color = Color.fromRGBO(185, 145, 80, 0.30 * opacity);
        _strokePaint.strokeWidth = math.min(2.5, 0.5 * math.max(1.0, scaleFactor * 0.35));
        canvas.drawPath(_facePath, _strokePaint);
      } else {
        final double lit = item.dotL;
        final double spec = item.specular;

        // Radiant Crystal & Gold: Luminous brilliant-cut facet shading
        final int r = (248 + lit * 7).clamp(0, 255).toInt();
        final int g = (240 + lit * 12 - spec * 10).clamp(0, 255).toInt();
        final int b = (215 + lit * 20 - spec * 25).clamp(0, 255).toInt();
        final double a = (0.80 + lit * 0.14 + spec * 0.06).clamp(0.0, 0.98) * opacity;

        _fillPaint.color = Color.fromRGBO(r, g, b, a);
        canvas.drawPath(_facePath, _fillPaint);

        // Radiant gold facet edges
        final double edgeAlpha = (0.65 + spec * 0.35).clamp(0.0, 1.0) * opacity;
        _strokePaint.color = Color.fromRGBO(190, 142, 60, edgeAlpha);
        _strokePaint.strokeWidth = math.min(3.5, math.max(0.8, 0.95 * (scaleFactor * 0.38)));
        canvas.drawPath(_facePath, _strokePaint);

        // Optional specular star sparkle
        if (spec > 0.82 && scaleFactor < 5.0) {
          final double spSize = 5.0 * spec;
          _sparklePaint.color = Color.fromRGBO(
            235,
            180,
            55,
            (0.95 * spec * opacity).clamp(0.0, 1.0),
          );
          canvas.drawLine(Offset(p0x - spSize, p0y), Offset(p0x + spSize, p0y), _sparklePaint);
          canvas.drawLine(Offset(p0x, p0y - spSize), Offset(p0x, p0y + spSize), _sparklePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant Diamond3DPainter oldDelegate) {
    return oldDelegate.rotationY != rotationY ||
        oldDelegate.scaleFactor != scaleFactor ||
        oldDelegate.opacity != opacity;
  }
}

class _DiamondFace {
  const _DiamondFace({required this.indices, required this.type});
  final List<int> indices;
  final String type;
}

class _RenderedFace {
  int i0 = 0;
  int i1 = 0;
  int i2 = 0;
  double zAvg = 0.0;
  bool isFront = false;
  double dotL = 0.0;
  double specular = 0.0;
}
