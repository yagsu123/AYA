import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'core/router.dart';
import 'core/utils/messenger.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load runtime config before the app starts. A missing or unreadable .env is
  // non-fatal: ApiService falls back to its development base URL.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env bundled — ApiService uses its fallback base URL.
  }

  // Keep the device screen awake while the app is in the foreground so it does
  // not dim or lock during use (e.g. reading an event or the directory). This
  // is best-effort: a platform that rejects the request must never prevent the
  // app from launching, so it runs unawaited and swallows its own failure.
  unawaited(WakelockPlus.enable().catchError((_) {}));

  runApp(const ProviderScope(child: AyaApp()));
}

class AyaApp extends ConsumerWidget {
  const AyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return PlatformProvider(
      settings: PlatformSettingsData(iosUsesMaterialWidgets: true),
      builder: (context) => MaterialApp.router(
        title: 'AYA',
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: router,
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}
