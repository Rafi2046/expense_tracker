import 'package:expense_tracker/core/providers/app_lock_provider.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:expense_tracker/core/providers/session_provider.dart';
import 'package:expense_tracker/core/providers/note_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/theme_provider.dart';
import 'package:expense_tracker/core/providers/privacy_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/splash/pages/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/widgets/app_lock_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsHelper.init();
  await initializeDateFormatting(); // Enable local date names (Bangla, Hindi, Urdu)

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ProfileManagerProvider()),
        ChangeNotifierProxyProvider<ProfileManagerProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, profileManager, txProvider) {
            txProvider!.updateProfileId(profileManager.activeProfileId);
            return txProvider;
          },
        ),
        ChangeNotifierProxyProvider<ProfileManagerProvider, DebtProvider>(
          create: (_) => DebtProvider(),
          update: (_, profileManager, debtProvider) {
            debtProvider!.updateProfileId(profileManager.activeProfileId);
            return debtProvider;
          },
        ),
        ChangeNotifierProxyProvider<ProfileManagerProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (_, profileManager, budgetProvider) {
            budgetProvider!.updateProfileId(profileManager.activeProfileId);
            return budgetProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ShortcutProvider()),
        ChangeNotifierProxyProvider<ProfileManagerProvider, NoteProvider>(
          create: (_) => NoteProvider(),
          update: (_, profileManager, noteProvider) {
            noteProvider!.updateProfileId(profileManager.activeProfileId);
            return noteProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ChangeNotifierProvider(create: (_) => BiometricAuthProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => PrivacyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider3<
          ProfileManagerProvider,
          TransactionProvider,
          DebtProvider,
          ReportsProvider
        >(
          create: (_) => ReportsProvider(),
          update: (_, profileManager, txProvider, debtProvider, reportsProvider) {
            reportsProvider!.updateProfileId(profileManager.activeProfileId);
            reportsProvider.updateProviders(txProvider, debtProvider);
            return reportsProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          ProfileManagerProvider,
          TransactionProvider,
          IncomeAnalyticsProvider
        >(
          create: (_) => IncomeAnalyticsProvider(),
          update: (_, profileManager, txProvider, analyticsProvider) {
            analyticsProvider!.updateProfileId(profileManager.activeProfileId);
            analyticsProvider.updateTransactions(txProvider.transactions);
            return analyticsProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          ProfileManagerProvider,
          TransactionProvider,
          ExpenseAnalyticsProvider
        >(
          create: (_) => ExpenseAnalyticsProvider(),
          update: (_, profileManager, txProvider, analyticsProvider) {
            analyticsProvider!.updateProfileId(profileManager.activeProfileId);
            analyticsProvider.updateTransactions(txProvider.transactions);
            return analyticsProvider;
          },
        ),
        ChangeNotifierProxyProvider3<
          ProfileManagerProvider,
          TransactionProvider,
          DebtProvider,
          BalanceAnalyticsProvider
        >(
          create: (_) => BalanceAnalyticsProvider(),
          update: (_, profileManager, txProvider, debtProvider, balanceProvider) {
            balanceProvider!.updateProfileId(profileManager.activeProfileId);
            balanceProvider.updateData(txProvider.transactions, debtProvider.items);
            return balanceProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );

  verifyFirestoreSchema();
}

Future<void> verifyFirestoreSchema() async {
  final prefsKey = 'active_profile_id';
  final activeProfileId =
      SharedPrefsHelper.getString(prefsKey) ?? 'default_profile';
  debugPrint('Firestore Active Profile: $activeProfileId');

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Transaction Doc Sample: No authenticated user');
      return;
    }
    final docs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .limit(1)
        .get();
    if (docs.docs.isEmpty) {
      debugPrint('Transaction Doc Sample: No transaction documents found');
      return;
    }
    final doc = docs.docs.first;
    debugPrint('Transaction Doc Sample: profileId=${doc.data()['profileId']}');
  } catch (e) {
    debugPrint('Transaction Doc Sample: Error - $e');
  }
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
      builder: (context, child) => AppLockManager(child: child!),
    );
  }
}
