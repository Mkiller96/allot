import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';

class DonutChartWidget extends StatefulWidget {
  final Map<String, double> byCategory;
  final ExpenseProvider     ep;
  const DonutChartWidget({super.key, required this.byCategory, required this.ep});
  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final total = widget.byCategory.values.fold(0.0, (s, v) => s + v);

    if (total == 0) {
      return Center(child: Text('Sin datos',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))));
    }

    final entries = widget.byCategory.entries.toList()
      ..sort((a,b) => b.value.compareTo(a.value));
    final sections = entries.asMap().entries.map((me) {
      final i    = me.key;
      final e    = me.value;
      final cat  = widget.ep.getCat(e.key);
      final pct  = e.value / total * 100;
      final isTouched = i == _touched;
      return PieChartSectionData(
        value:         e.value,
        color:         cat?.flutterColor ?? cs.primary,
        radius:        isTouched ? 80 : 70,
        titleStyle:    TextStyle(
            fontSize: isTouched ? 13 : 11,
            fontWeight: FontWeight.w700,
            color: Colors.white),
        title:         pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
        badgeWidget:   isTouched ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: cs.surface, borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
          child: Text('€${e.value.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ) : null,
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();

    return Row(children: [
      Expanded(
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 50,
            sectionsSpace: 2,
            pieTouchData: PieTouchData(
              touchCallback: (e, r) {
                setState(() {
                  if (!e.isInterestedForInteractions ||
                      r?.touchedSection == null) {
                    _touched = -1;
                    return;
                  }
                  _touched = r!.touchedSection!.touchedSectionIndex;
                });
              },
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      // Legend
      SizedBox(
        width: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.take(6).map((e) {
            final cat = widget.ep.getCat(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: cat?.flutterColor ?? cs.primary,
                        shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(
                    '${cat?.icon ?? ''} ${cat?.name ?? ''}',
                    style: tt.labelSmall, overflow: TextOverflow.ellipsis)),
              ]),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}
