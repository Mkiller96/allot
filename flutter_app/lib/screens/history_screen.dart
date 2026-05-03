import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';
import '../widgets/add_expense_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _period  = 'month';
  String _sort    = 'newest';
  String? _catId;
  final _searchCtrl = TextEditingController();

  static const _periods = {
    'month': 'Este mes',
    'year':  'Este año',
    'all':   'Todo',
  };
  static const _sorts = {
    'newest':  'Más reciente',
    'oldest':  'Más antiguo',
    'highest': 'Mayor importe',
    'lowest':  'Menor importe',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(context.read<ExpenseProvider>());
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _load(ExpenseProvider ep) {
    ep.loadExpenses(
      period: _period,
      catId:  _catId ?? '',
      sort:   _sort,
      search: _searchCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ep   = context.watch<ExpenseProvider>();
    final user = context.watch<AuthProvider>().user!;
    final cs   = Theme.of(context).colorScheme;
    final tt   = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Historial', style: tt.headlineMedium),
          ),
          // ── Filters ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(children: [
                // Search
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar nota…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              _load(ep);
                              setState(() {});
                            })
                        : null,
                  ),
                  onSubmitted: (_) => _load(ep),
                  onChanged: (v) {
                    setState(() {});
                    if (v.isEmpty) _load(ep);
                  },
                ),
                const SizedBox(height: 10),
                // Period + sort chips
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _period,
                      decoration: const InputDecoration(
                          labelText: 'Período', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      items: _periods.entries.map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _period = v);
                        _load(ep);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sort,
                      decoration: const InputDecoration(
                          labelText: 'Ordenar', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      items: _sorts.entries.map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _sort = v);
                        _load(ep);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                // Category chips
                if (ep.categories.isNotEmpty)
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          label: const Text('Todas'),
                          selected: _catId == null,
                          onSelected: (_) { setState(() => _catId = null); _load(ep); },
                        ),
                        const SizedBox(width: 6),
                        ...ep.categories.map((c) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            avatar: Text(c.icon),
                            label: Text(c.name),
                            selected: _catId == c.id,
                            onSelected: (_) {
                              setState(() => _catId = _catId == c.id ? null : c.id);
                              _load(ep);
                            },
                          ),
                        )),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ]),
            ),
          ),

          // ── List ─────────────────────────────────────────────────
          if (ep.loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (ep.expenses.isEmpty)
            SliverFillRemaining(
              child: Center(child: Text('Sin resultados',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ExpenseTile(expense: ep.expenses[i], ep: ep, user: user),
                  ),
                  childCount: ep.expenses.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: user.canWrite
          ? FloatingActionButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => const AddExpenseSheet(),
              ).then((_) => _load(ep)),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
