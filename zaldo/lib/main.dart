import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/expense_repository.dart';
import 'state/expense_store.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = ExpenseStore(PrefsExpenseRepository(prefs));
  await store.load();
  runApp(ZaldoApp(store: store));
}
