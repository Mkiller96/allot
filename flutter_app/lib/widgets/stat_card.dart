import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatCard extends StatelessWidget {
  final String label;
  final double value;
  final String? sub;
  final bool   accent;
  final bool   isCurrency;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.accent     = false,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final fmtEu = NumberFormat('#,##0.00', 'es_ES');

    final bg     = accent ? cs.primary           : cs.surfaceContainerHigh;
    final fgMain = accent ? cs.onPrimary          : cs.onSurface;
    final fgSub  = accent ? cs.onPrimary.withValues(alpha: 0.75)
                          : cs.onSurface.withValues(alpha: 0.55);

    return Card(
      color:        bg,
      elevation:    accent ? 4 : 1,
      shadowColor:  accent ? cs.primary.withValues(alpha: 0.35) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: tt.labelMedium?.copyWith(color: fgSub)),
            const SizedBox(height: 6),
            Text(
              isCurrency ? '€${fmtEu.format(value)}' : value.toInt().toString(),
              style: tt.headlineSmall?.copyWith(
                  color: fgMain, fontWeight: FontWeight.w800),
            ),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub!, style: tt.bodySmall?.copyWith(color: fgSub)),
            ],
          ],
        ),
      ),
    );
  }
}
