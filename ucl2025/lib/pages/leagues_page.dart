import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class LeaguesPage extends ConsumerStatefulWidget {
  const LeaguesPage({super.key});

  @override
  ConsumerState<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends ConsumerState<LeaguesPage> {
  final _codeCtrl = TextEditingController();
  List<dynamic>? _leagues;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supabase = ref.read(supabaseProvider);
    final res = await supabase
        .from('league_members')
        .select('leagues(id,name)');
    setState(() {
      _leagues = res;
      _loading = false;
    });
  }

  Future<void> _join() async {
    final code = _codeCtrl.text;
    final supabase = ref.read(supabaseProvider);
    try {
      final league = await supabase
          .from('leagues')
          .select('id')
          .eq('invite_code', code)
          .maybeSingle();
      if (league == null) {
        throw 'Invalid code';
      }
      await supabase.from('league_members').upsert({
        'league_id': league['id'],
        'user_id': supabase.auth.currentUser!.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Joined')));
      }
      _codeCtrl.clear();
      _load();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Leagues')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(labelText: 'Invite code'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _join, child: const Text('Join')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _leagues?.length ?? 0,
                      itemBuilder: (context, index) {
                        final l = _leagues![index]['leagues'];
                        return ListTile(title: Text(l['name'] as String));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
