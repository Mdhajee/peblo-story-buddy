import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BuddyCharacter extends StatefulWidget {
  final bool isHappy;
  final bool isPlaying;

  const BuddyCharacter({
    super.key,
    this.isHappy = false,
    this.isPlaying = false,
  });

  @override
  State<BuddyCharacter> createState() => _BuddyCharacterState();
}

class _BuddyCharacterState extends State<BuddyCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.isPlaying ? _bounceAnim.value : 0),
          child: child,
        );
      },
      child: CustomPaint(
        size: const Size(140, 140),
        painter: _BuddyPainter(
          isHappy: widget.isHappy,
          isPlaying: widget.isPlaying,
        ),
      ),
    );
  }
}

class _BuddyPainter extends CustomPainter {
  final bool isHappy;
  final bool isPlaying;

  _BuddyPainter({required this.isHappy, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Body
    final bodyPaint = Paint()..color = AppTheme.primary;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 15), width: 80, height: 70),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Head
    final headPaint = Paint()..color = AppTheme.primaryLight;
    canvas.drawCircle(Offset(cx, cy - 22), 36, headPaint);

    // Head shine
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawCircle(Offset(cx - 10, cy - 32), 12, shinePaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 13, cy - 22), 10, eyePaint);
    canvas.drawCircle(Offset(cx + 13, cy - 22), 10, eyePaint);

    // Pupils
    final pupilPaint = Paint()..color = AppTheme.textDark;
    if (isHappy) {
      final smileEyePaint = Paint()
        ..color = AppTheme.textDark
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - 13, cy - 18), width: 14, height: 10),
        3.14, 3.14, false, smileEyePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 13, cy - 18), width: 14, height: 10),
        3.14, 3.14, false, smileEyePaint,
      );
    } else {
      canvas.drawCircle(Offset(cx - 13 + (isPlaying ? 1 : 0), cy - 22), 5, pupilPaint);
      canvas.drawCircle(Offset(cx + 13 + (isPlaying ? 1 : 0), cy - 22), 5, pupilPaint);
      final eyeShinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(cx - 11, cy - 24), 2, eyeShinePaint);
      canvas.drawCircle(Offset(cx + 15, cy - 24), 2, eyeShinePaint);
    }

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isHappy) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy - 6), width: 28, height: 18),
        0, 3.14, false,
        mouthPaint..color = const Color(0xFFFF6B6B),
      );
    } else if (isPlaying) {
      canvas.drawCircle(Offset(cx, cy - 6), 7, Paint()..color = const Color(0xFF2D1B69));
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy - 4), width: 22, height: 12),
        0, 3.14, false, mouthPaint,
      );
    }

    // Antenna
    final antennaPaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 58), Offset(cx, cy - 46), antennaPaint);
    canvas.drawCircle(Offset(cx, cy - 62), 7, Paint()..color = AppTheme.accent);

    // Arms
    final armPaint = Paint()..color = AppTheme.primaryLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 50, cy + 18), width: 20, height: 36),
        const Radius.circular(10),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 50, cy + 18), width: 20, height: 36),
        const Radius.circular(10),
      ),
      armPaint,
    );

    // Legs
    final legPaint = Paint()..color = AppTheme.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 20, cy + 60), width: 18, height: 30),
        const Radius.circular(9),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 20, cy + 60), width: 18, height: 30),
        const Radius.circular(9),
      ),
      legPaint,
    );

    // Gear detail
    final gearPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy + 15), 12, gearPaint);
    canvas.drawCircle(Offset(cx, cy + 15), 5, Paint()..color = Colors.white.withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter old) =>
      old.isHappy != isHappy || old.isPlaying != isPlaying;
}
