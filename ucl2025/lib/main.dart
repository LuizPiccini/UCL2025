import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/fixture_page.dart';
import 'pages/rankings_page.dart';
import 'pages/leagues_page.dart';
import 'pages/profile_page.dart';
import 'providers.dart';

const supabaseUrl = 'https://okygocsblpqgwnypwife.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/fixtures/:id',
          builder: (context, state) =>
              FixturePage(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/rankings',
          builder: (context, state) => const RankingsPage(),
        ),
        GoRoute(
          path: '/leagues',
          builder: (context, state) => const LeaguesPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
      redirect: (context, state) {
        final loggedIn = session != null;
        final loggingIn = state.uri.path == '/login';
        if (!loggedIn) return loggingIn ? null : '/login';
        if (loggingIn) return '/home';
        return null;
      },
    );

    return MaterialApp.router(title: 'UCL Fantasy', routerConfig: router);
  }
}
