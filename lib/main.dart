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
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/providers/account_provider.dart';
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

  // Read saved profile ID ONCE, before any provider is created.
  // Every data provider receives it directly as a constructor argument,
  // eliminating any reliance on ProxyProvider update timing.
  final initialProfileId =
      SharedPrefsHelper.getString(SharedPrefsHelper.activeProfileKey) ?? 'default_profile';
  debugPrint('main: initial active profile = $initialProfileId');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            initialProfileId: initialProfileId,
          ),
        ),
        ChangeNotifierProxyProvider<ProfileProvider, ProfileManagerProvider>(
          create: (_) => ProfileManagerProvider(
            initialProfileId: initialProfileId,
          ),
          update: (_, profileProvider, pm) {
            if (profileProvider.isReady &&
                profileProvider.currentProfile.id != pm!.activeProfileId) {
              Future.microtask(() => pm.switchProfile(profileProvider.currentProfile.id));
            }
            return pm!;
          },
        ),
        ChangeNotifierProxyProvider<ProfileManagerProvider, TransactionProvider>(
          create: (_) => TransactionProvider(
            initialProfileId: initialProfileId,
          ),
          update: (_, pm, txProvider) {
            txProvider!.updateProfileId(pm.activeProfileId);
            return txProvider;
          },
        ),
        ChangeNotifierProxyProvider<ProfileManagerProvider, DebtProvider>(
          create: (_) => DebtProvider(
            initialProfileId: initialProfileId,
          ),
          update: (_, pm, debtProvider) {
            debtProvider!.updateProfileId(pm.activeProfileId);
            return debtProvider;
          },
        ),
        ChangeNotifierProxyProvider<ProfileManagerProvider, BudgetProvider>(
          create: (_) => BudgetProvider(
            initialProfileId: initialProfileId,
          ),
          update: (_, pm, budgetProvider) {
            budgetProvider!.updateProfileId(pm.activeProfileId);
            return budgetProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ShortcutProvider()),
        ChangeNotifierProxyProvider<ProfileManagerProvider, NoteProvider>(
          create: (_) => NoteProvider(
            initialProfileId: initialProfileId,
          ),
          update: (_, pm, noteProvider) {
            noteProvider!.updateProfileId(pm.activeProfileId);
            return noteProvider;
          },
        ),
        ChangeNotifierProxyProvider<ProfileManagerProvider, TourProvider>(
          create: (_) => TourProvider(initialProfileId: initialProfileId),
          update: (_, pm, tourProvider) {
            tourProvider!.updateProfileId(pm.activeProfileId);
            return tourProvider;
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

          create: (_) => ReportsProvider()
            ..updateProfileId(initialProfileId),
          update: (_, pm, txProvider, debtProvider, reportsProvider) {
            reportsProvider!.updateProfileId(pm.activeProfileId);
            reportsProvider.updateProviders(txProvider, debtProvider);
            return reportsProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          ProfileManagerProvider,
          TransactionProvider,
          IncomeAnalyticsProvider
        >(
          create: (_) => IncomeAnalyticsProvider()
            ..updateProfileId(initialProfileId),
          update: (_, pm, txProvider, analyticsProvider) {
            analyticsProvider!.updateProfileId(pm.activeProfileId);
            analyticsProvider.updateTransactions(txProvider.transactions);
            return analyticsProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          ProfileManagerProvider,
          TransactionProvider,
          ExpenseAnalyticsProvider
        >(
          create: (_) => ExpenseAnalyticsProvider()
            ..updateProfileId(initialProfileId),
          update: (_, pm, txProvider, analyticsProvider) {
            analyticsProvider!.updateProfileId(pm.activeProfileId);
            analyticsProvider.updateTransactions(txProvider.transactions);
            return analyticsProvider;
          },
        ),
        ChangeNotifierProxyProvider<
          ProfileManagerProvider,
          AccountProvider
        >(
          create: (_) => AccountProvider(),
          update: (_, pm, accountProvider) {
            accountProvider!.updateProfileId(pm.activeProfileId);
            return accountProvider;
          },
        ),
        ChangeNotifierProxyProvider4<
          ProfileManagerProvider,
          TransactionProvider,
          DebtProvider,
          AccountProvider,
          BalanceAnalyticsProvider
        >(
          create: (_) => BalanceAnalyticsProvider()
            ..updateProfileId(initialProfileId),
          update: (_, pm, txProvider, debtProvider, accountProvider, balanceProvider) {
            balanceProvider!.updateProfileId(pm.activeProfileId);
            balanceProvider.updateData(
              txProvider.transactions,
              debtProvider.items,
              accountProvider.accounts,
            );
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
  final activeProfileId =
      SharedPrefsHelper.getString(SharedPrefsHelper.activeProfileKey) ?? 'default_profile';
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
