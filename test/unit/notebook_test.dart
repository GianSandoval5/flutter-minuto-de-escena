import 'package:flutter_test/flutter_test.dart';
import 'package:minuto_de_escena/features/talks/domain/talk.dart';
import 'package:minuto_de_escena/features/talks/presentation/notebook.dart';

import '../support/memory_repository.dart';

void main() {
  test(
    'Carga, error recuperable y guardado sin alterar la copia confirmada',
    () async {
      final old = Talk('x', 'Inicial', 5, [Cue('Tema', 5)]);
      final repo = MemoryRepository([old]);
      final book = Notebook(repo);
      final events = <bool>[];
      book.addListener(() => events.add(book.busy));
      await book.refresh();
      expect(events, [true, false]);
      repo.fail = true;
      final changed = Talk('x', 'Editada', 8, old.blocks);
      expect(await book.save(changed), isFalse);
      expect(book.byId('x').title, 'Inicial');
      expect(book.error, isNotNull);
      expect(await book.remove('x'), isFalse);
      expect(book.talks, hasLength(1));
      repo.fail = false;
      expect(await book.save(changed), isTrue);
      expect(book.error, isNull);
      expect(book.byId('x').minutes, 8);
      expect(await book.remove('x'), isTrue);
      expect(book.talks, isEmpty);
    },
  );
  test(
    'Ignora acciones superpuestas mientras hay una petición pendiente',
    () async {
      final book = Notebook(MemoryRepository());
      final first = book.refresh();
      expect(book.busy, isTrue);
      expect(await book.remove('x'), isFalse);
      await first;
      expect(book.busy, isFalse);
    },
  );
}
