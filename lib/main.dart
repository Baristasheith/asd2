import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/localization/app_locales.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/services/language_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If `firebase_options.dart` still has the placeholder values (i.e.
  // `flutterfire configure` hasn't been run yet for this project),
  // Firebase throws here. We catch it and show a clear one-screen
  // instruction instead of a crash, so the rest of the app's UI can
  // still be reviewed before the backend is wired up.
  FirebaseOptions? options;
  Object? initError;
  try {
    options = DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: options);
  } catch (e) {
    initError = e;
  }

  runApp(ProviderScope(child: AhmadRestCafeApp(firebaseInitError: initError)));
}

class AhmadRestCafeApp extends ConsumerWidget {
  final Object? firebaseInitError;
  const AhmadRestCafeApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    if (firebaseInitError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _FirebaseSetupNeededScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Ahmad Rest & Cafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.light,

      // ---- Localization wiring ----
      locale: locale,
      supportedLocales: AppLocales.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ---- Routing ----
      routerConfig: appRouter,

      // ---- Force RTL/LTR per active locale, independent of the OS,
      // so the whole app (including Material/Cupertino built-ins) mirrors
      // instantly and correctly the moment the user switches language.
      builder: (context, child) {
        final direction = AppLocales.directionOf(locale.languageCode);
        return Directionality(
          textDirection: direction,
          child: OfflineBanner(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// Shown instead of crashing when `lib/firebase_options.dart` still has
/// placeholder values. See the "Firebase Setup" section in README.md.
class _FirebaseSetupNeededScreen extends StatelessWidget {
  const _FirebaseSetupNeededScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_outlined, color: AppColors.primarySage, size: 48),
                  const SizedBox(height: 24),
                  Text('Firebase Setup Needed', style: AppTextStyles.h2, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'Run `flutterfire configure` from the project root to '
                    'connect this app to your Firebase project, then '
                    'restart. See the "Firebase Setup" section in README.md '
                    'for the full checklist.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
