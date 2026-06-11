import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:query_gen/theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'utils/routes.dart';

// ignore: unused_element
// Mantém a referência viva para o GC não desativar a árvore semântica.
// Necessário para que o plugin JS de acessibilidade possa ler flt-semantics
// sem exigir que o usuário clique em "Enable accessibility".
SemanticsHandle? _webSemanticsHandle;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    _webSemanticsHandle = SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static ThemeNotifier of(BuildContext context) {
    return context
        .findAncestorStateOfType<_MyAppState>()!
        .themeNotifier;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeNotifier = ThemeNotifier();

  @override
  void dispose() {
    themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'QueryGen AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeNotifier.mode,
          home: const SplashRouter(),
        );
      },
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService().isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      fadeRoute(loggedIn ? const MainShell() : const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}
