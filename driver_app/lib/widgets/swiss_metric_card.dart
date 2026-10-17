import 'package:flutter/material.dart';

class SwissMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final Color? valueColor;
  final Widget? trailing;

  const SwissMetricCard({
    Key? key,
    required this.label,
    required this.value,
    this.subLabel,
    this.valueColor,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: valueColor ?? const Color(0xFF111827),
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              subLabel!.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
