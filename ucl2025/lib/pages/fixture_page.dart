import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class FixturePage extends ConsumerStatefulWidget {
  final String id;
  const FixturePage({super.key, required this.id});

  @override
  ConsumerState<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends ConsumerState<FixturePage> {
  final _homeCtrl = TextEditingController();
  final _awayCtrl = TextEditingController();
  Map<String, dynamic>? _fixture;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supabase = ref.read(supabaseProvider);
    final fixture = await supabase
        .from('fixtures')
        .select()
        .eq('id', widget.id)
        .single();
    Map<String, dynamic>? pred;
    final uid = supabase.auth.currentUser!.id;
    pred = await supabase
        .from('predictions')
        .select()
        .eq('fixture_id', widget.id)
        .eq('user_id', uid)
        .maybeSingle();
    setState(() {
      _fixture = fixture;
      _homeCtrl.text = pred?['home_pred']?.toString() ?? '';
      _awayCtrl.text = pred?['away_pred']?.toString() ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final supabase = ref.read(supabaseProvider);
    try {
      await supabase.from('predictions').upsert({
        'fixture_id': widget.id,
        'user_id': supabase.auth.currentUser!.id,
        'home_pred': int.parse(_homeCtrl.text),
        'away_pred': int.parse(_awayCtrl.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final teams = ref
        .watch(teamsProvider)
        .maybeWhen(data: (m) => m, orElse: () => <int, String>{});
    final homeName = teams[_fixture!['home_team_id']] ?? 'Home';
    final awayName = teams[_fixture!['away_team_id']] ?? 'Away';
    final kickoff = DateTime.parse(_fixture!['kickoff_at'] as String);
    final now = DateTime.now().toUtc();
    final locked = now.isAfter(kickoff) || _fixture!['status'] != 'scheduled';
    return Scaffold(
      appBar: AppBar(title: Text('$homeName vs $awayName')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _homeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: homeName),
              enabled: !locked,
            ),
            TextField(
              controller: _awayCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: awayName),
              enabled: !locked,
            ),
            const SizedBox(height: 16),
            if (locked)
              const Text('Locked')
            else
              ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
