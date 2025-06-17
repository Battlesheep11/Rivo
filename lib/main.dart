import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'package:device_preview/device_preview.dart';
import 'package:rivo_app/core/toast/toast_service.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  ToastService().init(messengerKey);


  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: true,
        builder: (context) => const App(),
      ),
    ),
  );
}
