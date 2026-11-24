import 'package:minuto_de_escena/features/talks/domain/talk.dart';

class MemoryRepository implements TalkRepository {
  final Map<String, Talk> rows;
  bool fail = false;
  MemoryRepository([Iterable<Talk> talks = const []])
    : rows = {for (final t in talks) t.id: t};
  void check() {
    if (fail) {
      throw const FormatException('Error simulado');
    }
  }

  @override
  Future<List<Talk>> list() async {
    check();
    return rows.values.toList();
  }

  @override
  Future<void> save(Talk talk) async {
    check();
    rows[talk.id] = talk;
  }

  @override
  Future<void> remove(String id) async {
    check();
    rows.remove(id);
  }
}
