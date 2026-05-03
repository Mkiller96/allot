import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> data; // 12 values, one per month
  const BarChartWidget({super.key, required this.data});

  static const _months = ['E','F','M','A','M','J','J','A','S','O','N','D'];

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final max = data.fold(0.0, (m, v) => v > m ? v : m);
    final maxY = max == 0 ? 100.0 : (max * 1.2);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => cs.surfaceContainerHighest,
            getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
              '€${rod.toY.toStringAsFixed(2)}',
              TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, meta) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_months[v.toInt()],
                    style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.55))),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) {
                if (v == 0 || v == maxY) return const SizedBox.shrink();
                return Text('€${v.toInt()}',
                    style: TextStyle(fontSize: 9, color: cs.onSurface.withValues(alpha: 0.45)));
              },
            ),
          ),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: cs.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(12, (i) {
          final isCurrentMonth = i == DateTime.now().month - 1;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                color: isCurrentMonth ? cs.primary : cs.primary.withValues(alpha: 0.45),
              ),
            ],
          );
        }),
      ),
    );
  }
}
