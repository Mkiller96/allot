import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/user.dart';
import '../providers/expense_provider.dart';
import 'add_expense_sheet.dart';

class ExpenseTile extends StatelessWidget {
  final Expense         expense;
  final ExpenseProvider ep;
  final AppUser         user;
  const ExpenseTile({super.key, required this.expense, required this.ep, required this.user});

  @override
  Widget build(BuildContext context) {
    final cat = ep.getCat(expense.categoryId);
    final cs  = Theme.of(context).colorScheme;
    final dt  = DateTime.tryParse(expense.date);
    final dateLabel = dt != null
        ? DateFormat('dd MMM yyyy', 'es_ES').format(dt)
        : expense.date;
    final fmtEu = NumberFormat('#,##0.00', 'es_ES');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (cat?.flutterColor ?? cs.primary).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(cat?.icon ?? '💸',
              style: const TextStyle(fontSize: 20))),
        ),
        title: Text(cat?.name ?? 'Sin categoría',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: expense.note?.isNotEmpty == true
            ? Text(expense.note!, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)))
            : Text(dateLabel,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('€${fmtEu.format(expense.amount)}',
                style: TextStyle(color: cs.primary,
                    fontWeight: FontWeight.w800, fontSize: 15)),
            if (user.canWrite)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Editar',
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => AddExpenseSheet(expense: expense),
                ),
              ),
            if (user.canDelete)
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                tooltip: 'Eliminar',
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Eliminar gasto'),
                      content: Text('¿Eliminar €${fmtEu.format(expense.amount)}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar')),
                        FilledButton(onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar')),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) await ep.deleteExpense(expense.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}
