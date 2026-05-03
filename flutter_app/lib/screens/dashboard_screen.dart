import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/donut_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _year = DateTime.now().year;
  Map<String, dynamic>? _annual;
  List<double>? _monthly;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ep = context.read<ExpenseProvider>();
    try {
      final a = await ep.fetchAnnual(_year);
      final m = await ep.fetchMonthly(_year);
      final List<double> months = (m['months'] as List<dynamic>)
          .map((e) => ((e as Map<String, dynamic>)['total'] as num).toDouble())
          .toList();
      if (mounted) setState(() { _annual = a; _monthly = months; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<ExpenseProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Panel', style: tt.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Año anterior',
                onPressed: () { setState(() => _year--); _load(); },
              ),
              TextButton(
                onPressed: null,
                child: Text('$_year',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Año siguiente',
                onPressed: _year >= DateTime.now().year
                    ? null
                    : () { setState(() => _year++); _load(); },
              ),
              const SizedBox(width: 8),
            ],
          ),

          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── KPI row ──────────────────────────────────────
                  _KpiRow(annual: _annual),
                  const SizedBox(height: 24),

                  // ── Bar chart ─────────────────────────────────────
                  Text('Gasto mensual',
                      style: tt.labelLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                      child: SizedBox(
                        height: 200,
                        child: BarChartWidget(data: _monthly ?? List.filled(12, 0.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Donut chart ───────────────────────────────────
                  Text('Por categoría',
                      style: tt.labelLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 240,
                        child: DonutChartWidget(
                          byCategory: {
                            for (final item in (_annual?['byCategory'] as List<dynamic>? ?? []))
                              (item as Map<String, dynamic>)['id'] as String:
                              ((item as Map<String, dynamic>)['total'] as num).toDouble(),
                          },
                          ep: ep,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Top 5 months ──────────────────────────────────
                  _TopMonth(monthly: _monthly),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final Map<String, dynamic>? annual;
  const _KpiRow({required this.annual});
  @override
  Widget build(BuildContext context) {
    final total    = (annual?['total']    as num?)?.toDouble() ?? 0.0;
    final count    = annual?['count']     ?? 0;
    final avgMonth = (annual?['avgMonth'] as num?)?.toDouble() ?? 0.0;

    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 500 ? 3 : 1;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: cols == 3 ? 1.7 : 3.5,
        children: [
          StatCard(label: 'Total anual',   value: total,    sub: '$count gastos', accent: true),
          StatCard(label: 'Media mensual', value: avgMonth, sub: 'Por mes'),
          StatCard(label: 'Gastos totales',value: count.toDouble(),
              sub: 'registros', isCurrency: false),
        ],
      );
    });
  }
}

class _TopMonth extends StatelessWidget {
  final List<double>? monthly;
  const _TopMonth({required this.monthly});
  static const _months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
  @override
  Widget build(BuildContext context) {
    if (monthly == null || monthly!.every((v) => v == 0)) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sorted = List.generate(12, (i) => MapEntry(i, monthly![i]))
      ..sort((a,b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Meses más altos',
          style: tt.labelLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6), letterSpacing: 0.8)),
      const SizedBox(height: 10),
      ...top3.map((e) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Text('${e.key+1}', style: TextStyle(color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700)),
          ),
          title: Text(_months[e.key], style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Text('€${e.value.toStringAsFixed(2)}',
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      )),
    ]);
  }
}
