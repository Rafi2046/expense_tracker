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
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/services/weekly_summary_service.dart';
import 'package:expense_tracker/core/services/monthly_summary_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/dashboard/pages/weekly_summary_screen.dart';
import 'features/dashboard/pages/daily_summary_screen.dart';
import 'features/dashboard/pages/monthly_summary_screen.dart';
import 'features/splash/pages/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/widgets/app_lock_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Surface framework errors instead of a blank white screen on device.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  ErrorWidget.builder = (details) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Something went wrong:\n${details.exception}',
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      ),
    );
  };
  debugPrint('main: WidgetsFlutterBinding initialized');

  try {
    debugPrint('main: initializing EasyLocalization...');
    await EasyLocalization.ensureInitialized();
    debugPrint('main: EasyLocalization initialization complete');
  } catch (e) {
    debugPrint('main: EasyLocalization initialization error: $e');
  }

  try {
    debugPrint('main: initializing SharedPrefsHelper...');
    await SharedPrefsHelper.init();
    debugPrint('main: SharedPrefsHelper initialization complete');
  } catch (e) {
    debugPrint('main: SharedPrefsHelper initialization error: $e');
  }

  try {
    debugPrint('main: initializing DateFormatting...');
    await initializeDateFormatting(); // Enable local date names (Bangla, Hindi, Urdu)
    debugPrint('main: DateFormatting initialization complete');
  } catch (e) {
    debugPrint('main: DateFormatting initialization error: $e');
  }

  try {
    debugPrint('main: initializing Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('main: Firebase initialization complete');
  } catch (e) {
    debugPrint('main: Firebase initialization error: $e');
  }

  try {
    debugPrint('main: initializing NotificationService...');
    await NotificationService.instance.init();

    // Wire notification tap handler
    NotificationService.onNotificationTapHandler = (payload) {
      debugPrint('onNotificationTapHandler: payload=$payload');

      final context = NotificationService.navigatorKey.currentContext;
      if (context == null) {
        debugPrint('onNotificationTapHandler: navigatorKey context is null');
        return;
      }

      // Handle both payload-based and ID-based routing
      final isWeeklySummary = payload == 'weekly_summary' || payload == 'id:4001';
      final isDailySummary = payload == 'daily_summary' || payload == 'id:5001';
      final isMonthlySummary = payload == 'monthly_summary' || payload == 'id:6001';

      if (isWeeklySummary) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WeeklySummaryScreen(),
            ),
          );
        });
      } else if (isDailySummary) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DailySummaryScreen(),
            ),
          );
        });
      } else if (isMonthlySummary) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MonthlySummaryScreen(),
            ),
          );
        });
      }
    };

    debugPrint('main: NotificationService initialization complete');
  } catch (e) {
    debugPrint('main: NotificationService initialization error: $e');
  }

  // Handle app launch from notification tap (backup when onDidReceiveNotificationResponse doesn't fire)
  try {
    final launchDetails = await NotificationService.instance.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      debugPrint('main: app launched from notification, payload=$payload');
      // Store in SharedPrefs so MyApp can pick it up after the widget tree is built
      if (payload == 'weekly_summary') {
        SharedPrefsHelper.setString('_pending_nav', 'weekly_summary');
      } else if (payload == 'daily_summary') {
        SharedPrefsHelper.setString('_pending_nav', 'daily_summary');
      } else if (payload == 'monthly_summary') {
        SharedPrefsHelper.setString('_pending_nav', 'monthly_summary');
      }
    }
  } catch (e) {
    debugPrint('main: getNotificationAppLaunchDetails error: $e');
  }

  // Read saved profile ID ONCE, before any provider is created.
  // Every data provider receives it directly as a constructor argument,
  // eliminating any reliance on ProxyProvider update timing.
  final initialProfileId =
      SharedPrefsHelper.getString(SharedPrefsHelper.activeProfileKey) ?? 'default_profile';
  debugPrint('main: initial active profile = $initialProfileId');

  // Weekly/monthly in-app summaries (non-blocking).
  // Daily *notification* is scheduled from TransactionProvider after DB load
  // so the body uses today's real total (not a zero race at cold start).
  WeeklySummaryService.checkAndGenerate(profileId: initialProfileId);
  MonthlySummaryService.checkAndGenerate(profileId: initialProfileId);

  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  const supportedLangCodes = ['en', 'bn', 'hi', 'ur'];
  final defaultCode = supportedLangCodes.contains(deviceLocale) ? deviceLocale : 'en';
  final savedLanguageCode = SharedPrefsHelper.getString('app_language_code') ?? defaultCode;
  debugPrint('main: saved/default language code = $savedLanguageCode');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('bn'), Locale('hi'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLanguageCode),
      saveLocale: false,
      child: MultiProvider(
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
            // ProfileManager owns the active id for normal switches. Align the
            // UI to it — never re-read SharedPrefs here (that raced with
            // in-flight switches and could snap back to a stale secondary).
            // Exception: if the active profile was deleted (esp. remotely),
            // follow ProfileProvider's fallback so data providers reload.
            if (!profileProvider.isReady || pm == null) return pm!;

            final activeStillExists = profileProvider.profiles.any(
              (p) => p.id == pm.activeProfileId,
            );
            if (!activeStillExists) {
              final fallbackId = profileProvider.currentProfile.id;
              if (fallbackId != pm.activeProfileId) {
                Future.microtask(() => pm.switchProfile(fallbackId));
              }
              return pm;
            }

            if (profileProvider.currentProfile.id != pm.activeProfileId) {
              Future.microtask(
                () => profileProvider.syncCurrentProfileFromId(pm.activeProfileId),
              );
            }
            return pm;
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
        ChangeNotifierProxyProvider<ProfileManagerProvider, NotificationProvider>(
          create: (_) => NotificationProvider(initialProfileId: initialProfileId)
            ..loadNotifications(),
          update: (_, pm, notifProvider) {
            notifProvider!.updateProfileId(pm.activeProfileId);
            return notifProvider;
          },
        ),
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

/// Tracks whether the BudgetProvider → TransactionProvider callback has been wired.
bool _budgetWired = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('MyApp: build called');
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: SplashScreen(),
      builder: (context, child) {
        if (!_budgetWired) {
          _budgetWired = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final tx = context.read<TransactionProvider>();
            final notif = context.read<NotificationProvider>();
            BudgetProvider.onBudgetChanged = (profileId) {
              if (profileId == tx.activeProfileId) {
                tx.checkBudgetThreshold();
              }
            };
            // Keep dashboard badge in sync when notifications are
            // inserted outside NotificationProvider (budget, summaries).
            NotificationProvider.onDataChanged = () {
              notif.loadNotifications();
            };
          });
        }

        // Handle pending navigation from notification tap (one-shot at startup)
        final pendingNav = SharedPrefsHelper.getString('_pending_nav');
        if (pendingNav != null) {
          SharedPrefsHelper.remove('_pending_nav');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navContext = NotificationService.navigatorKey.currentContext;
            if (navContext == null) return;
            if (pendingNav == 'weekly_summary') {
              Navigator.push(
                navContext,
                MaterialPageRoute(
                  builder: (_) => const WeeklySummaryScreen(),
                ),
              );
            } else if (pendingNav == 'daily_summary') {
              Navigator.push(
                navContext,
                MaterialPageRoute(
                  builder: (_) => const DailySummaryScreen(),
                ),
              );
            } else if (pendingNav == 'monthly_summary') {
              Navigator.push(
                navContext,
                MaterialPageRoute(
                  builder: (_) => const MonthlySummaryScreen(),
                ),
              );
            }
          });
        }
        // child can be null during early MaterialApp frames — child! crashed
        // to a blank white screen on device (esp. release / cold start).
        return AppLockManager(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
