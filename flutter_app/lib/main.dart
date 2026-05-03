import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const AllotApp());
}

class AllotApp extends StatelessWidget {
  const AllotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (ctx, themeProv, authProv, _) {
          return MaterialApp(
            title: 'Allot',
            debugShowCheckedModeBanner: false,
            theme:      AppTheme.light(),
            darkTheme:  AppTheme.dark(),
            themeMode:  themeProv.mode,
            home: const _AuthGate(),
            routes: {
              '/login':    (_) => const LoginScreen(),
              '/home':     (_) => const MainShell(),
              '/register': (_) => const RegisterScreen(),
            },
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    await context.read<AuthProvider>().tryAutoLogin();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final loggedIn = context.watch<AuthProvider>().user != null;
    return loggedIn ? const MainShell() : const LoginScreen();
  }
}
