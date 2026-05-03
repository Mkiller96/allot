import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/category_form.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _usersLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.isAdmin == true) _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _usersLoading = true);
    try {
      final users = await context.read<AuthProvider>().getUsers();
      if (mounted) setState(() => _users = users);
    } catch (_) {}
    if (mounted) setState(() => _usersLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ep     = context.watch<ExpenseProvider>();
    final user   = context.watch<AuthProvider>().user!;
    final thProv = context.watch<ThemeProvider>();
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Ajustes', style: tt.headlineMedium),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance ─────────────────────────────────────
                _SectionHeader('Apariencia'),
                Card(
                  child: SwitchListTile(
                    secondary: Icon(thProv.isDark ? Icons.dark_mode : Icons.light_mode),
                    title: const Text('Modo oscuro'),
                    subtitle: Text(thProv.isDark ? 'Activado' : 'Desactivado'),
                    value: thProv.isDark,
                    onChanged: (_) => thProv.toggle(),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Account ────────────────────────────────────────
                _SectionHeader('Cuenta'),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primary,
                      child: Text(user.username[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                    title: Text(user.username,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(user.role.toUpperCase(),
                        style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                    trailing: TextButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Salir'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Categories (admin only) ─────────────────────────
                if (user.isAdmin) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _SectionHeader('Categorías'),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva'),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const CategoryFormDialog(),
                      ),
                    ),
                  ]),
                  ...ep.categories.map((cat) => Card(
                    child: ListTile(
                      leading: Text(cat.icon, style: const TextStyle(fontSize: 22)),
                      title:   Text(cat.name),
                      trailing: cat.isCustom
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: cs.error,
                              tooltip: 'Eliminar',
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Eliminar categoría'),
                                    content: Text('¿Eliminar "${cat.name}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Eliminar')),
                                    ],
                                  ),
                                );
                                if (ok == true && context.mounted) {
                                  await ep.deleteCategory(cat.id);
                                }
                              },
                            )
                          : null,
                    ),
                  )),
                  const SizedBox(height: 20),

                  // ── Users management (admin only) ───────────────────
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _SectionHeader('Usuarios'),
                    if (_usersLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadUsers,
                        tooltip: 'Actualizar',
                      ),
                  ]),
                  ..._users.map((u) {
                    final isMe  = u['id'] == user.id;
                    final uRole = (u['role'] as String).toUpperCase();
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.secondaryContainer,
                          child: Text(
                            (u['username'] as String)[0].toUpperCase(),
                            style: TextStyle(color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(u['username'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(uRole,
                            style: TextStyle(color: cs.primary, fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        trailing: isMe
                            ? Chip(
                                label: const Text('Tú'),
                                backgroundColor: cs.primaryContainer,
                              )
                            : IconButton(
                                icon: Icon(Icons.delete_outline, color: cs.error),
                                tooltip: 'Eliminar usuario',
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Eliminar usuario'),
                                      content: Text('¿Eliminar a "${u['username']}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                              backgroundColor: cs.error),
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true && context.mounted) {
                                    try {
                                      await context.read<AuthProvider>()
                                          .deleteUser(u['id'] as int);
                                      await _loadUsers();
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── Danger zone ──────────────────────────────────
                  _SectionHeader('Zona de peligro'),
                  Card(
                    color: cs.errorContainer,
                    child: ListTile(
                      leading: Icon(Icons.delete_forever, color: cs.error),
                      title: Text('Eliminar todos mis gastos',
                          style: TextStyle(color: cs.onErrorContainer)),
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Borrar todos los gastos'),
                            content: const Text('Esta acción es irreversible. ¿Continuar?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar')),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: cs.error),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Borrar todo'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          await ep.deleteAll();
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),

                // ── App info ───────────────────────────────────────
                Center(child: Text('Allot v1.0.0',
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.3),
                        fontSize: 12))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: cs.onSurface.withValues(alpha: 0.5))),
    );
  }
}
