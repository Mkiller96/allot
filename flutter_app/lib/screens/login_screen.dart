import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _userCtrl  = TextEditingController();
  final _passCtrl  = TextEditingController();
  String _role     = 'admin';
  bool   _obscure  = true;

  static const _roleOptions = [
    ('admin', '🛡️', 'Administrador'),
    ('user',  '👤', 'Usuario'),
    ('guest', '👁️', 'Invitado'),
  ];

  @override
  void dispose() {
    _userCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_userCtrl.text.trim(), _passCtrl.text, _role);
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _loginAsGuest() async {
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login('invitado', '', 'guest');
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final auth    = context.watch<AuthProvider>();
    final thProv  = context.watch<ThemeProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.diamond_outlined, color: cs.primary, size: 32),
                        const SizedBox(width: 10),
                        Text('Allot',
                            style: tt.displaySmall?.copyWith(color: cs.primary,
                                fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 6),
                      Text('Control de Gastos Personales',
                          style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 28),

                      // Role chips
                      Wrap(spacing: 8, children: _roleOptions.map((r) {
                        final selected = _role == r.$1;
                        return ChoiceChip(
                          label: Text('${r.$2} ${r.$3}'),
                          selected:      selected,
                          onSelected:    (_) => setState(() => _role = r.$1),
                          selectedColor: cs.primary.withValues(alpha: 0.18),
                          labelStyle: TextStyle(
                            color:      selected ? cs.primary : null,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        );
                      }).toList()),
                      const SizedBox(height: 20),

                      // Username
                      TextFormField(
                        controller: _userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 14),

                      // Password (hidden for guest)
                      if (_role != 'guest') ...[
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Error
                      if (auth.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(auth.error!,
                              style: TextStyle(color: cs.error, fontSize: 13)),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _submit,
                          child: auth.loading
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2,
                                      color: Colors.white))
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Guest quick login
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: auth.loading ? null : _loginAsGuest,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Continuar como invitado'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Register link
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/register'),
                        child: const Text('¿Sin cuenta? Crear una'),
                      ),
                      const SizedBox(height: 8),

                      // Theme toggle
                      TextButton.icon(
                        onPressed: thProv.toggle,
                        icon: Icon(thProv.isDark ? Icons.light_mode : Icons.dark_mode,
                            size: 18),
                        label: Text(thProv.isDark ? 'Modo claro' : 'Modo oscuro',
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
