import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/expense_tile.dart';
import '../widgets/add_expense_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses(period: 'month');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ep   = context.watch<ExpenseProvider>();
    final user = context.watch<AuthProvider>().user!;
    final cs   = Theme.of(context).colorScheme;
    final tt   = Theme.of(context).textTheme;
    final now  = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final monthEx  = ep.expenses;
    final todayEx  = ep.expenses.where((e) => e.date == todayStr).toList();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEx   = ep.expenses.where((e) {
      final d = DateTime.parse(e.date);
      return !d.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day));
    }).toList();

    final monthTotal = monthEx.fold(0.0, (s, e) => s + e.amount);
    final todayTotal = todayEx.fold(0.0, (s, e) => s + e.amount);
    final weekTotal  = weekEx.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ep.loadExpenses(period: 'month'),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text('Inicio', style: tt.headlineMedium),
              actions: [
                if (user.canWrite)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilledButton.icon(
                      onPressed: () => _openAddSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir gasto'),
                    ),
                  ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Stat cards ─────────────────────────────────────
                  _StatRow(
                    monthTotal: monthTotal, monthCount: monthEx.length,
                    todayTotal: todayTotal, todayCount: todayEx.length,
                    weekTotal: weekTotal,   weekCount: weekEx.length,
                  ),
                  const SizedBox(height: 24),

                  // ── Top cats ───────────────────────────────────────
                  Text('Top categorías este mes',
                      style: tt.labelLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  _TopCats(expenses: monthEx, ep: ep, total: monthTotal),
                  const SizedBox(height: 24),

                  // ── Today list ─────────────────────────────────────
                  Text('Gastos de hoy',
                      style: tt.labelLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  if (ep.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (todayEx.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Sin gastos hoy',
                          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))),
                    )
                  else
                    ...todayEx.reversed.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ExpenseTile(expense: e, ep: ep, user: user),
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !user.canWrite
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Añadir'),
            ),
    );
  }

  void _openAddSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const AddExpenseSheet(),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final double monthTotal, todayTotal, weekTotal;
  final int    monthCount, todayCount, weekCount;
  const _StatRow({
    required this.monthTotal, required this.monthCount,
    required this.todayTotal, required this.todayCount,
    required this.weekTotal,  required this.weekCount,
  });
  @override
  Widget build(BuildContext context) {
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
          StatCard(label: 'Gasto del mes', value: monthTotal,
              sub: '$monthCount gastos', accent: true),
          StatCard(label: 'Gasto hoy',     value: todayTotal,
              sub: '$todayCount gastos'),
          StatCard(label: 'Esta semana',   value: weekTotal,
              sub: '$weekCount gastos'),
        ],
      );
    });
  }
}

class _TopCats extends StatelessWidget {
  final List<dynamic> expenses;
  final ExpenseProvider ep;
  final double total;
  const _TopCats({required this.expenses, required this.ep, required this.total});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bycat = <String, double>{};
    for (final e in expenses) bycat[e.categoryId] = (bycat[e.categoryId] ?? 0) + e.amount;
    final sorted = bycat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top3   = sorted.take(3).toList();
    if (top3.isEmpty) {
      return Text('Sin gastos este mes',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)));
    }
    return Column(
      children: top3.map((entry) {
        final cat = ep.getCat(entry.key);
        final pct = total > 0 ? entry.value / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: cat?.flutterColor ?? Colors.grey,
                        shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text('${cat?.icon ?? ''} ${cat?.name ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct, minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: cat?.flutterColor ?? cs.primary,
                  ),
                )),
                const SizedBox(width: 12),
                Text('€${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}
