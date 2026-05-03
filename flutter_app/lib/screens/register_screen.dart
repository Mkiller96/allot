import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _userCtrl      = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  String  _role        = 'user';
  bool    _obscure     = true;
  bool    _obscureConf = true;
  bool    _loading     = false;
  String? _error;

  static const _roleOptions = [
    ('admin', '🛡️', 'Administrador'),
    ('user',  '👤', 'Usuario'),
  ];

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final api = ApiService();
      await api.post('/auth/register', {
        'username': _userCtrl.text.trim(),
        'password': _passCtrl.text,
        'role':     _role,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada. Inicia sesión.')),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No se pudo conectar al servidor');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final thProv = context.watch<ThemeProvider>();

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
                            style: tt.displaySmall?.copyWith(
                                color: cs.primary, fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 6),
                      Text('Crear cuenta',
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6))),
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

                      // Password
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
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if (v.length < 4) return 'Mínimo 4 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm password
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConf,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConf
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureConf = !_obscureConf),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Error
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_error!,
                              style: TextStyle(color: cs.error, fontSize: 13)),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Crear cuenta'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Back to login
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                      ),
                      const SizedBox(height: 4),

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
