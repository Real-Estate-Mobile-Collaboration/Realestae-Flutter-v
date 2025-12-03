import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/message_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/l10n.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Set your Stripe publishable key for mobile platforms.
    // IMPORTANT: Replace the placeholder below with your actual publishable key.
    // Do NOT commit the real key to source control in production; use a secure config.
    const stripePublishableKey = 'pk_test_replace_with_your_key';

    try {
      if (stripePublishableKey != 'pk_test_replace_with_your_key') {
        Stripe.publishableKey = stripePublishableKey;
        // Apply platform-specific settings (Android / iOS)
        await Stripe.instance.applySettings();
      } else {
        debugPrint('⚠️ Warning: Using placeholder Stripe key. Payment features will not work.');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to initialize Stripe: $e');
      // Don't crash the app - just log the error
    }
  }

  _setupLogging();
  runApp(const MyApp());
}

void _setupLogging() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Real Estate App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              '/map': (context) => const MapScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
