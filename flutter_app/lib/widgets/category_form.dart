import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({super.key});
  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _icon    = '🏷️';
  Color  _color   = const Color(0xFF2E7D32);
  bool   _saving  = false;

  static const _icons = [
    '🍔','🚗','🎬','📄','🛒','💊','🎮','✈️','👕','📚',
    '🏋️','🐶','☕','🏠','💡','🎵','🎁','🏷️','💼','🌿',
  ];
  static const _colors = [
    Color(0xFF2E7D32), Color(0xFFE53935), Color(0xFF1976D2),
    Color(0xFFF57C00), Color(0xFF7B1FA2), Color(0xFF00838F),
    Color(0xFF558B2F), Color(0xFF6D4C41), Color(0xFFE91E63),
    Color(0xFF546E7A),
  ];

  String _toHex(Color c) =>
      '#${c.r.round().toRadixString(16).padLeft(2,'0')}'
      '${c.g.round().toRadixString(16).padLeft(2,'0')}'
      '${c.b.round().toRadixString(16).padLeft(2,'0')}';

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<ExpenseProvider>().addCategory({
        'name':  _nameCtrl.text.trim(),
        'icon':  _icon,
        'color': _toHex(_color),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Nueva categoría', style: TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 340,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre', prefixIcon: Icon(Icons.label_outline)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              // Icon picker
              Align(alignment: Alignment.centerLeft,
                  child: Text('Icono', style: TextStyle(
                      fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55)))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: _icons.map((ic) => GestureDetector(
                  onTap: () => setState(() => _icon = ic),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _icon == ic ? cs.primaryContainer : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(ic, style: const TextStyle(fontSize: 20))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              // Color picker
              Align(alignment: Alignment.centerLeft,
                  child: Text('Color', style: TextStyle(
                      fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55)))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _colors.map((c) => GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: _color == c
                          ? Border.all(color: cs.onSurface, width: 2.5)
                          : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Crear'),
        ),
      ],
    );
  }
}
