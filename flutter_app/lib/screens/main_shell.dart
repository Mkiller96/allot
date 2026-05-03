import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initialised = true;
      final token = context.read<AuthProvider>().user!.token;
      final ep    = context.read<ExpenseProvider>();
      ep.init(token);
      ApiService.onUnauthorized = () {
        if (!mounted) return;
        context.read<AuthProvider>().logout().then((_) {
          if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        });
      };
      ep.loadCategories().then((_) => ep.loadExpenses());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user     = context.watch<AuthProvider>().user!;
    final cs       = Theme.of(context).colorScheme;
    final thProv   = context.watch<ThemeProvider>();
    final isWide   = MediaQuery.of(context).size.width >= 700;

    final tabs = [
      const (Icons.home_outlined,      Icons.home,           'Inicio'),
      const (Icons.dashboard_outlined, Icons.dashboard,      'Panel'),
      const (Icons.history_outlined,   Icons.history,        'Historial'),
      if (user.isAdmin)
      const (Icons.settings_outlined,  Icons.settings,       'Ajustes'),
    ];

    final screens = [
      const HomeScreen(),
      const DashboardScreen(),
      const HistoryScreen(),
      if (user.isAdmin) const SettingsScreen(),
    ];

    Widget body = screens[_idx];

    if (isWide) {
      // Navigation Rail for tablet/desktop/windows
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _idx,
              onDestinationSelected: (i) => setState(() => _idx = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: Column(children: [
                  Icon(Icons.diamond_outlined, color: cs.primary, size: 28),
                  const SizedBox(height: 4),
                  Text('Allot', style: TextStyle(color: cs.primary,
                      fontWeight: FontWeight.w800, fontSize: 16)),
                ]),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _UserTile(user: user),
                      const SizedBox(height: 8),
                      _ThemeButton(prov: thProv),
                      const SizedBox(height: 4),
                      _LogoutButton(),
                    ]),
                  ),
                ),
              ),
              destinations: tabs.map((t) => NavigationRailDestination(
                icon:         Icon(t.$1),
                selectedIcon: Icon(t.$2),
                label:        Text(t.$3),
              )).toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Bottom navigation for mobile
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: tabs.map((t) => NavigationDestination(
          icon:         Icon(t.$1),
          selectedIcon: Icon(t.$2),
          label:        t.$3,
        )).toList(),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final dynamic user;
  const _UserTile({required this.user});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: cs.primary,
      child: Text(user.username[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final ThemeProvider prov;
  const _ThemeButton({required this.prov});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: prov.isDark ? 'Modo claro' : 'Modo oscuro',
      icon: Icon(prov.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: prov.toggle,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Salir',
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await context.read<AuthProvider>().logout();
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
    );
  }
}
