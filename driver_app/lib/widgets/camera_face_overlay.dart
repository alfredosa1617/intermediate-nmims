import 'package:flutter/material.dart';

class CameraFaceOverlay extends StatelessWidget {
  final String statusMessage;
  final bool isFaceAligned;
  final int blinkCount;
  final bool smileDetected;
  final double confidence;

  const CameraFaceOverlay({
    Key? key,
    required this.statusMessage,
    required this.isFaceAligned,
    required this.blinkCount,
    required this.smileDetected,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Darkened vignette perimeter with clear transparent cutout in center
        CustomPaint(
          size: Size.infinite,
          painter: _FaceReticlePainter(isAligned: isFaceAligned),
        ),

        // Top Status Strip
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black.withOpacity(0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      color: isFaceAligned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusMessage,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  'CONF: ${(confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Target Progress Bar
        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black.withOpacity(0.85),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRequirementChip(
                          label: 'BLINK TWICE',
                          progress: '${blinkCount}/2',
                          passed: blinkCount >= 2,
                        ),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildRequirementChip(
                          label: 'SMILE SCAN',
                          progress: smileDetected ? 'VERIFIED' : 'PENDING',
                          passed: smileDetected,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: ((blinkCount.clamp(0, 2) / 2) + (smileDetected ? 1.0 : 0.0)) / 2.0,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementChip({
    required String label,
    required String progress,
    required bool passed,
  }) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_box : Icons.check_box_outline_blank,
          size: 16,
          color: passed ? const Color(0xFF16A34A) : Colors.white54,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            Text(
              progress,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: passed ? const Color(0xFF16A34A) : Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FaceReticlePainter extends CustomPainter {
  final bool isAligned;

  _FaceReticlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final reticlePaint = Paint()
      ..color = isAligned ? const Color(0xFF16A34A) : const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2 - 30);
    final ovalWidth = size.width * 0.72;
    final ovalHeight = size.height * 0.46;
    final rect = Rect.fromCenter(center: center, width: ovalWidth, height: ovalHeight);

    // Draw dark overlay with transparent oval cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(rect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);
    canvas.drawOval(rect, reticlePaint);

    // Draw 4 Swiss orthogonal corner ticks around the target
    final tickLength = 20.0;
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0;

    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(tickLength, 0), tickPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, tickLength), tickPaint);

    // Top-right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-tickLength, 0), tickPaint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, tickLength), tickPaint);

    // Bottom-left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(tickLength, 0), tickPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -tickLength), tickPaint);

    // Bottom-right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-tickLength, 0), tickPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -tickLength), tickPaint);
  }

  @override
  bool shouldRepaint(covariant _FaceReticlePainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}
