import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final sessionProvider = StreamProvider<Session?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session,
  );
});

final teamsProvider = FutureProvider<Map<int, String>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final res = await supabase.from('teams').select('id, name');
  return {for (final item in res) item['id'] as int: item['name'] as String};
});

final fixturesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final supabase = ref.read(supabaseProvider);
  return supabase
      .from('fixtures')
      .stream(primaryKey: ['id'])
      .eq('status', 'scheduled')
      .order('kickoff_at');
});
