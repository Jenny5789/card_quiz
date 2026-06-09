import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings()..loadSettings(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AppSettings 변경 감지 → 전체 앱 재빌드
    final settings = context.watch<AppSettings>();

    return MaterialApp(
      title: '퀴즈카드',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF386641)),
        useMaterial3: true,
        // 전체 앱 기본 폰트 크기 적용
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: settings.fontSize),
          bodyMedium: TextStyle(fontSize: settings.fontSize),
          bodySmall: TextStyle(fontSize: settings.fontSize - 2),
          titleLarge: TextStyle(fontSize: settings.fontSize + 8),
          titleMedium: TextStyle(fontSize: settings.fontSize + 4),
          titleSmall: TextStyle(fontSize: settings.fontSize + 2),
          labelLarge: TextStyle(fontSize: settings.fontSize),
          labelMedium: TextStyle(fontSize: settings.fontSize - 1),
          labelSmall: TextStyle(fontSize: settings.fontSize - 2),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => done
              ? const HomeScreen()
              : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}