import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/api_config.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';
import 'package:riyo_app/screens/home_feed_screen.dart';
import 'package:riyo_app/screens/exam_results_screen.dart';
import 'package:riyo_app/screens/attendance_screen.dart';
import 'package:riyo_app/screens/profile_screen.dart';
import 'package:riyo_app/screens/exam_result_detail_screen.dart';

// Single shared API client. The 401 handler is set after MaterialApp is built
// so the navigator is available to pop to the login screen when the token expires.
final RiyoApi api = RiyoApi.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort: hit the site root once so the InfinityFree JS-challenge
  // cookie is set. If it fails the warmup is silently ignored and the first
  // real API call may surface an `invalidResponse` error (handled gracefully).
  try {
    await api.warmup();
  } catch (_) {}
  runApp(const RiyoApp());
}

class RiyoApp extends StatefulWidget {
  const RiyoApp({super.key});
  @override
  State<RiyoApp> createState() => _RiyoAppState();
}

class _RiyoAppState extends State<RiyoApp> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // When the API reports an expired/invalid session, clear the token and
    // pop everything back to the login screen.
    api.setUnauthorizedHandler(() {
      _navKey.currentState?.popUntil((r) => r.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Riyo',
    theme: RiyoTheme.dark,
    darkTheme: RiyoTheme.dark,
    themeMode: ThemeMode.dark,
    navigatorKey: _navKey,
    home: const _RootGate(),
    debugShowCheckedModeBanner: false,
    routes: {
      '/exam-result': (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return ExamResultDetailScreen(
          examResult: args?['examResult'] as Map<String, dynamic>? ?? {},
          session: args?['session'] as String? ?? '',
          className: args?['className'] as String? ?? '',
        );
      },
      '/exam-results': (context) => const ExamResultsScreen(),
      '/attendance': (context) => const AttendanceScreen(),
    },
  );
}

/// Decides whether to show login or the main app, based on a stored token.
class _RootGate extends StatefulWidget {
  const _RootGate();
  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  bool? _hasToken;

  @override
  void initState() {
    super.initState();
    api.token.then((t) {
      if (!mounted) return;
      setState(() => _hasToken = t != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasToken == null) return const LoadingView(message: 'Starting Riyo…');
    return _hasToken! ? const MainApp() : const LoginScreen();
  }
}

/// Login screen — X-style centered card on black background
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;
  String? _err;

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final res = await api.login(_user.text.trim(), _pass.text);
      if (!mounted) return;
      if (res['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainApp()),
        );
      } else {
        setState(() => _err = 'Unexpected response from the server.');
      }
    } catch (e) {
      if (mounted) setState(() => _err = friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(color: RiyoTheme.black),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RiyoTheme.space6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('assets/riyo_logo.png', height: 72),
                const SizedBox(height: RiyoTheme.space4),
                // Title
                Text(
                  'Welcome back',
                  style: RiyoTheme.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: RiyoTheme.space2),
                Text(
                  'Sign in to your student account',
                  style: RiyoTheme.bodyMedium.copyWith(
                    color: RiyoTheme.gray400,
                  ),
                ),
                const SizedBox(height: RiyoTheme.space6),
                // Form card
                Container(
                  decoration: BoxDecoration(
                    color: RiyoTheme.gray900,
                    borderRadius: BorderRadius.circular(RiyoTheme.radiusXl),
                    border: Border.all(color: RiyoTheme.gray700, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(RiyoTheme.space6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _user,
                        enabled: !_busy,
                        style: RiyoTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Admission No / Username',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          labelStyle: RiyoTheme.bodyMedium.copyWith(
                            color: RiyoTheme.gray400,
                          ),
                        ),
                      ),
                      const SizedBox(height: RiyoTheme.space4),
                      TextField(
                        controller: _pass,
                        enabled: !_busy,
                        obscureText: true,
                        style: RiyoTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          labelStyle: RiyoTheme.bodyMedium.copyWith(
                            color: RiyoTheme.gray400,
                          ),
                        ),
                      ),
                      const SizedBox(height: RiyoTheme.space4),
                      if (_err != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: RiyoTheme.space3,
                          ),
                          child: Text(
                            _err!,
                            style: RiyoTheme.bodyMedium.copyWith(
                              color: RiyoTheme.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _login,
                          child: _busy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(
                                      RiyoTheme.black,
                                    ),
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RiyoTheme.space5),
                Text(
                  'Riyo v7.2.0',
                  style: RiyoTheme.labelSmall.copyWith(
                    color: RiyoTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Main app with bottom navigation bar (5 tabs like X)
class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = const [
      HomeFeedScreen(),
      ExamResultsScreen(),
      AttendanceScreen(),
      ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // Scroll to top if already on this tab (like X)
      // Could add scroll controller logic here
    }
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) => setState(() => _currentIndex = index),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment_rounded),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
