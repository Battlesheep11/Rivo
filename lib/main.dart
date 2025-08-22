import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rivo_app_beta/core/analytics/route_observer.dart';
import 'package:rivo_app_beta/core/analytics/analytics_service.dart'; 
import 'app.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Portrait only
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Missing Supabase configuration in .env file');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    await Firebase.initializeApp();

    await AnalyticsService.logAppOpened();

    ToastService().init(messengerKey);

    runApp(
      ProviderScope(
        child: MaterialApp(
          scaffoldMessengerKey: messengerKey,
          navigatorObservers: [analyticsObserver],
          home: App(),
        ),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
