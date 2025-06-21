import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'package:device_preview/device_preview.dart';
import 'package:rivo_app/core/toast/toast_service.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  try {
    developer.log('🚀 Starting app initialization...');
    
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('✅ Flutter binding initialized');

    // Load environment variables
    developer.log('🔧 Loading environment variables...');
    await dotenv.load(fileName: ".env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Missing Supabase configuration in .env file');
    }
    
    developer.log('✅ Environment variables loaded');
    developer.log('🌐 Supabase URL: ${supabaseUrl.substring(0, 20)}...');
    
    // Initialize Supabase
    developer.log('🔌 Initializing Supabase...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    developer.log('✅ Supabase initialized successfully');

    // Initialize Toast Service
    developer.log('🍞 Initializing Toast Service...');
    ToastService().init(messengerKey);
    developer.log('✅ Toast Service initialized');

    // Run the app
    developer.log('🚀 Running the app...');
    runApp(
      ProviderScope(
        child: DevicePreview(
          enabled: true,
          builder: (context) => const App(),
        ),
      ),
    );
    developer.log('✅ App started successfully');
  } catch (e, stackTrace) {
    developer.log('❌ Error during app initialization: $e');
    developer.log('📝 Stack trace: $stackTrace');
    
    // Show error UI if possible
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
