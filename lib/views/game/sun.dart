import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class SolarSystem extends StatelessWidget {
  const SolarSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Solar System')),
      body: Center(
        child: SizedBox(
          width: 600,
          height: 1200,
          child: CustomSolarSystem(),
        ),
      ),
    );
  }
}

class CustomSolarSystem extends StatefulWidget {
  const CustomSolarSystem({super.key});

  @override
  _CustomSolarSystemState createState() => _CustomSolarSystemState();
}

class _CustomSolarSystemState extends State<CustomSolarSystem> with TickerProviderStateMixin {
  late AnimationController _controller;
  List<ui.Image> images = [];
  final List<String> imageUrls = [
    'https://img.alicdn.com/imgextra/i1/O1CN01oVLbLx22VlN34KDQs_!!6000000007126-2-tps-800-800.png', // Sun
    'https://img.alicdn.com/imgextra/i2/O1CN01UjgqIB1SrRxQfrflh_!!6000000002300-2-tps-800-800.png', // Mercury
    'https://img.alicdn.com/imgextra/i3/O1CN01JGEgLU1dfxnVvp91R_!!6000000003764-2-tps-800-800.png', // Venus
    'https://img.alicdn.com/imgextra/i4/O1CN01R6wlzD1IhhMlBcGLg_!!6000000000925-2-tps-800-800.png', // Earth
    'https://img.alicdn.com/imgextra/i4/O1CN01Ad5SeB20tv1nfRoA2_!!6000000006908-2-tps-800-800.png', // Moon
    'https://img.alicdn.com/imgextra/i1/O1CN01OlZAk81OVEHJ0pazq_!!6000000001710-2-tps-800-800.png', // Mars
    'https://img.alicdn.com/imgextra/i2/O1CN01MA3Mk51bAhWxWxHim_!!6000000003425-2-tps-800-800.png', // Jupiter
    'https://img.alicdn.com/imgextra/i2/O1CN01NG2FjS1XDDEofNNhg_!!6000000002889-2-tps-800-800.png', // Saturn
    'https://img.alicdn.com/imgextra/i1/O1CN01wnxTX51xIPkTHqPBr_!!6000000006420-2-tps-800-800.png', // Uranus
    'https://img.alicdn.com/imgextra/i1/O1CN01LTf0rT25zwJWsIDkD_!!6000000007598-2-tps-800-800.png', // Neptune
  ];
  final List<double> planetSizes = [60, 5, 8, 10, 3, 7, 12, 24, 9, 8];
  final List<double> orbitRadii = [60, 90, 120, 150, 180, 210, 240, 270];
  final List<double> speeds = [4, 3, 2, 1.5, 1, 0.8, 0.5, 0.4];

  @override
  void initState() {
    super.initState();
    _loadImages();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    for (var url in imageUrls) {
      final data = await NetworkAssetBundle(Uri.parse(url)).load(url);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frameInfo = await codec.getNextFrame();
      images.add(frameInfo.image);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (images.length != imageUrls.length) {
      return Center(child: CircularProgressIndicator());
    }
    return CustomPaint(
      painter: SolarSystemPainter(images, _controller.value),
      size: Size(600, 1200),
    );
  }
}

class Star {
  final Offset position;
  final double size;
  final double opacity;

  Star(this.position, this.size, this.opacity);
}

class SolarSystemPainter extends CustomPainter {
  final List<ui.Image> images;
  final double animationValue;
  final List<Star> stars = [];

  SolarSystemPainter(this.images, this.animationValue) {
    final random = Random();
    for (int i = 0; i < 200; i++) {
      double x = random.nextDouble() * 600;
      double y = random.nextDouble() * 1200;
      double size = 0.5 + random.nextDouble();
      double opacity = 0.5 + random.nextDouble() * 0.5;
      stars.add(Star(Offset(x, y), size, opacity));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient backgroundGradient = RadialGradient(
      colors: [Color(0xFF1C2837), Color(0xFF050608)],
      center: Alignment.center,
      radius: 1.0,
    );

    canvas.drawRect(rect, Paint()..shader = backgroundGradient.createShader(rect));

    // Draw stars
    for (final star in stars) {
      canvas.drawCircle(star.position, star.size, Paint()..color = Colors.white.withOpacity(star.opacity));
    }

    // Draw sun and planets
    final sunSize = 60.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 100; // Adjusted to fit within the screen

    // Draw sun
    canvas.drawImageRect(
      images[0] as ui.Image,
      Rect.fromLTWH(0, 0, images[0].width.toDouble(), images[0].height.toDouble()),
      Rect.fromLTWH(centerX - sunSize / 2, centerY - sunSize / 2, sunSize, sunSize),
      Paint(),
    );

    // Define orbits and draw planets
    final List<double> orbitRadii = [60, 90, 120, 150, 180, 210, 240, 270];
    final List<double> speeds = [4, 3, 2, 1.5, 1, 0.8, 0.5, 0.4];
    final List<double> sizes = [5, 8, 10, 3, 7, 12, 24, 9];

    for (int i = 0; i < orbitRadii.length; i++) {
      double angle = animationValue * 2 * pi * speeds[i];
      double x = centerX + orbitRadii[i] * cos(angle);
      double y = centerY + orbitRadii[i] * sin(angle);

      // Draw orbit
      final Paint orbitPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withOpacity(0.2);
        // ..dashPattern = [2, 2];
      canvas.drawOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: orbitRadii[i]), orbitPaint);

      // Draw planet
      canvas.drawImageRect(
        images[i + 1],
        Rect.fromLTWH(0, 0, images[i + 1].width.toDouble(), images[i + 1].height.toDouble()),
        Rect.fromLTWH(x - sizes[i] / 2, y - sizes[i] / 2, sizes[i], sizes[i]),
        Paint(),
      );

      // Draw moon around Earth
      if (i == 2) {
        double moonAngle = animationValue * 2 * pi * 5; // Faster than Earth
        double moonRadius = 10.0;
        double moonX = x + moonRadius * cos(moonAngle);
        double moonY = y + moonRadius * sin(moonAngle);
        canvas.drawImageRect(
          images[4],
          Rect.fromLTWH(0, 0, images[4].width.toDouble(), images[4].height.toDouble()),
          Rect.fromLTWH(moonX - 3 / 2, moonY - 3 / 2, 3, 3),
          Paint(),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



