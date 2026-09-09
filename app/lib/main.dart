import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/api_service.dart';
import 'services/app_settings.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';
import 'theme.dart';

const primaryBlue = Color(0xFF0D47A1);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BookScannerApp());
}

class BookScannerApp extends StatelessWidget {
  const BookScannerApp({super.key});
  @override
  Widget build(BuildContext c) {
    return ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext c) {
    return Consumer<AppSettings>(
      builder: (c, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rwanda School Book Scanner',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: Locale(settings.locale),
          supportedLocales: const [
            Locale('en', ''),
            Locale('rw', ''),
            Locale('fr', ''),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _SplashGate(),
        );
      },
    );
  }
}

class _SplashGate extends StatelessWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext c) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiService.discover();
      Provider.of<AppSettings>(c, listen: false).load();
    });
    return FutureBuilder(
      future: ApiService.token(),
      builder: (c, s) => s.connectionState != ConnectionState.done
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()))
          : (s.data != null ? const HomeShell() : const LoginScreen()),
    );
  }
}