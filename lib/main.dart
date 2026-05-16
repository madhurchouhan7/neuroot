import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 1 — Firebase init
  await FirebaseService.initialize();

  // Phase 1 — Hive local DB init
  await Hive.initFlutter();
  // Hive boxes are opened lazily in their respective feature providers.

  // Immersive edge-to-edge UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Portrait-only lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: NeurootApp()));
}

class NeurootApp extends ConsumerWidget {
  const NeurootApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router is built inside ConsumerWidget so it has access to `ref`
    // for the Riverpod-aware auth redirect.
    final router = buildAppRouter(ref);

    return MaterialApp.router(
      title: 'Neuroot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
