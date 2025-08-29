import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../widgets/update_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtures = ref.watch(fixturesStreamProvider);
    final teams = ref.watch(teamsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Fixtures')),
      body: Column(
        children: [
          const UpdateBanner(),
          Expanded(
            child: fixtures.when(
              data: (list) {
                final teamMap = teams.maybeWhen(
                  data: (m) => m,
                  orElse: () => <int, String>{},
                );
                if (list.isEmpty) {
                  return const Center(child: Text('No upcoming fixtures'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final f = list[index];
                    final home = teamMap[f['home_team_id']] ?? 'Home';
                    final away = teamMap[f['away_team_id']] ?? 'Away';
                    final date = DateTime.parse(f['kickoff_at'] as String);
                    final fmt = DateFormat(
                      'dd/MM HH:mm',
                    ).format(date.toLocal());
                    return ListTile(
                      title: Text('$home vs $away'),
                      subtitle: Text(fmt),
                      onTap: () => context.push('/fixtures/${f['id']}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Menu')),
          ListTile(
            title: const Text('Rankings'),
            onTap: () => context.push('/rankings'),
          ),
          ListTile(
            title: const Text('Leagues'),
            onTap: () => context.push('/leagues'),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }
}
