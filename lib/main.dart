import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // טוען את קובץ הסודות
  await dotenv.load(fileName: ".env");

  // נאתחל את Supabase בצורה בטוחה
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // מריץ את האפליקציה אחרי שכל התלויות מאותחלות
  runApp(const ProviderScope(child: App()));
}
