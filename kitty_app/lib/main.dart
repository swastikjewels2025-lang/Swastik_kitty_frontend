import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/kitty_app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow font loading with offline bundled assets priority
  GoogleFonts.config.allowRuntimeFetching = true;

  // Lock app orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system navigation and status bars to seamlessly blend into warm gold canvas
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFAF7F2),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize global environment configuration
  AppConfig.initialize();
          
  runApp(
    const ProviderScope(
      child: KittyApp(),
    ),
  );
}
