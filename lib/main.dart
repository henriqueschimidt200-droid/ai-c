import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (_) {
    // The app still opens when Firebase has not been configured yet.
    // This prevents the release APK from getting stuck on the splash screen.
  }
  runApp(AICreatorApp(firebaseReady: firebaseReady));
}

class AICreatorApp extends StatelessWidget {
  final bool firebaseReady;
  const AICreatorApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF070812);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Creator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF10111D),
          surfaceContainerHighest: const Color(0xFF171827),
        ),
      ),
      home: firebaseReady
          ? StreamBuilder(
              stream: AuthService.authStateChanges,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _Splash();
                }
                return snapshot.hasData ? const HomeScreen() : const LoginScreen();
              },
            )
          : const LoginScreen(firebaseUnavailable: true),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets_ai_icon.png', width: 88, height: 88)),
        SizedBox(height: 18),
        Text('AI Creator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}
