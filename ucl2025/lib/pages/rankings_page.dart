import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class RankingsPage extends ConsumerStatefulWidget {
  const RankingsPage({super.key});

  @override
  ConsumerState<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends ConsumerState<RankingsPage> {
  List<dynamic>? _rows;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supabase = ref.read(supabaseProvider);
    final lm = await supabase
        .from('league_members')
        .select('league_id')
        .limit(1)
        .maybeSingle();
    if (lm == null) {
      setState(() {
        _loading = false;
        _rows = [];
      });
      return;
    }
    final leagueId = lm['league_id'];
    final rows = await supabase
        .from('v_league_totals')
        .select('user_id,total_points')
        .eq('league_id', leagueId)
        .order('total_points', ascending: false);
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rankings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rows!.isEmpty
          ? const Center(child: Text('No data'))
          : ListView.builder(
              itemCount: _rows!.length,
              itemBuilder: (context, index) {
                final r = _rows![index];
                return ListTile(
                  leading: Text('#${index + 1}'),
                  title: Text(r['user_id'].toString()),
                  trailing: Text(r['total_points'].toString()),
                );
              },
            ),
    );
  }
}
