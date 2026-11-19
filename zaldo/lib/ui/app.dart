import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../state/expense_store.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/summary_screen.dart';
import 'theme.dart';

class ZaldoApp extends StatelessWidget {
  const ZaldoApp({super.key, required this.store, this.now = DateTime.now});
  final ExpenseStore store;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaldo',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Shell(store: store, now: now),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.store, required this.now});
  final ExpenseStore store;
  final DateTime Function() now;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        store: widget.store,
        now: widget.now,
        onHistory: () => _go(1),
        onSummary: () => _go(2),
      ),
      HistoryScreen(store: widget.store, now: widget.now),
      SummaryScreen(store: widget.store, now: widget.now),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.navBackground,
          indicatorColor: AppColors.primary,
          height: 80,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (s) => TextStyle(
              fontSize: 14,
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: s.contains(WidgetState.selected)
                  ? AppColors.onPrimary
                  : AppColors.navInactive,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (s) => IconThemeData(
              color: s.contains(WidgetState.selected)
                  ? AppColors.onPrimary
                  : AppColors.navInactive,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _go,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt),
              label: 'Historial',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Resumen',
            ),
          ],
        ),
      ),
    );
  }
}
