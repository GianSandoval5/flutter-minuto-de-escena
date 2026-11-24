import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:minuto_de_escena/features/talks/data/mobilelab_repository.dart';
import 'package:minuto_de_escena/features/talks/domain/talk.dart';

void main() {
  const url = String.fromEnvironment('MOBILELAB_TEST_URL');
  const phase = String.fromEnvironment('MOBILELAB_TEST_PHASE');
  final client = http.Client();
  final repo = MobileLabRepository(Uri.parse(url), client);
  tearDownAll(client.close);
  test(
    'El adaptador real conserva en SQLite el guion y el historial · $phase',
    () async {
      const id = 'integracion-ensayo';
      Future<Talk> read() async =>
          (await repo.list()).singleWhere((t) => t.id == id);
      if (phase == 'create') {
        expect((await repo.list()).any((t) => t.id == 'demo-taller'), isTrue);
        final talk = Talk(id, 'Guion de prueba', 4, [
          Cue('Apertura', 1),
          Cue('Demo', 3),
        ]);
        await repo.save(talk);
        expect((await read()).runs, isEmpty);
        await repo.save(talk.record([71, 179], DateTime.utc(2026, 11, 23)));
        expect((await read()).runs.single.total, 250);
      } else {
        expect(phase, 'restart');
        final talk = await read();
        expect(talk.title, 'Guion de prueba');
        expect(talk.runs.single.laps.last.cue.name, 'Demo');
        expect(talk.runs.single.laps.map((l) => l.seconds), [71, 179]);
        await repo.remove(id);
        expect((await repo.list()).any((t) => t.id == id), isFalse);
        expect((await repo.list()).any((t) => t.id == 'demo-taller'), isTrue);
      }
    },
  );
}
