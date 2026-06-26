import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:expense_tracker/core/providers/note_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/theme_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/splash/pages/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

// 1. Added Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsHelper.init();
  await initializeDateFormatting(); // Enable local date names (Bangla, Hindi, Urdu)

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ShortcutProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProxyProvider2<TransactionProvider, DebtProvider, ReportsProvider>(
          create: (_) => ReportsProvider(),
          update: (_, txProvider, debtProvider, reportsProvider) =>
              reportsProvider!..updateProviders(txProvider, debtProvider),
        ),
        ChangeNotifierProxyProvider<TransactionProvider, IncomeAnalyticsProvider>(
          create: (_) => IncomeAnalyticsProvider(),
          update: (_, txProvider, analyticsProvider) =>
              (analyticsProvider ?? IncomeAnalyticsProvider())..updateTransactions(txProvider.transactions),
        ),
        ChangeNotifierProxyProvider<TransactionProvider, ExpenseAnalyticsProvider>(
          create: (_) => ExpenseAnalyticsProvider(),
          update: (_, txProvider, analyticsProvider) =>
              (analyticsProvider ?? ExpenseAnalyticsProvider())..updateTransactions(txProvider.transactions),
        ),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: SplashScreen(),
    );
  }
}