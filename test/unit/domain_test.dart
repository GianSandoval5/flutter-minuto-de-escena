import 'package:flutter_test/flutter_test.dart';
import 'package:minuto_de_escena/features/talks/domain/talk.dart';
import 'package:minuto_de_escena/features/talks/domain/practice_clock.dart';

void main() {
  test('El presupuesto de la charla y el guion pueden diferir', () {
    final talk = Talk('t', '  Apertura  ', 5, [
      Cue('Por qué', 4),
      Cue('Cómo', 3),
    ]);
    expect(talk.title, 'Apertura');
    expect(talk.planned, 7);
    expect(difference(120), '2:00 por encima');
    expect(difference(-71), '1:11 de margen');
    expect(difference(0), 'Justo a tiempo');
  });
  test('Los ensayos conservan los objetivos originales al editar el guion', () {
    final original = Talk('t', 'Demo', 10, [Cue('Ejemplo', 8)]);
    final saved = original.record([525], DateTime.utc(2026, 11, 23));
    final edited = Talk('t', 'Otra versión', 5, [
      Cue('Conclusión', 5),
    ], saved.runs);
    expect(original.runs, isEmpty);
    expect(edited.runs.single.laps.single.cue.name, 'Ejemplo');
    expect(edited.runs.single.budget, 10);
    expect(edited.runs.single.total, 525);
  });
  test('Rechaza planes y ensayos incompletos o tiempos negativos', () {
    expect(() => Cue('', 1), throwsFormatException);
    expect(() => Cue('Uno', 0), throwsFormatException);
    expect(() => Talk('t', 'T', 181, [Cue('Uno', 1)]), throwsFormatException);
    expect(() => Talk('t', 'T', 1, []), throwsFormatException);
    final talk = Talk('t', 'T', 1, [Cue('Uno', 1)]);
    expect(() => talk.record([], DateTime.utc(2026)), throwsFormatException);
    expect(() => talk.record([-1], DateTime.utc(2026)), throwsFormatException);
  });
  test('La pausa excluye su duración y el último bloque cierra el reloj', () {
    var ms = 0;
    final timer = PracticeClock(2, () => Duration(milliseconds: ms));
    timer.advance();
    expect(timer.laps, isEmpty);
    timer.start();
    ms = 1000;
    timer.start();
    ms = 1500;
    timer.pause();
    ms = 6000;
    expect(timer.elapsed.inMilliseconds, 1500);
    timer.advance();
    expect(timer.index, 0);
    timer.start();
    ms = 7550;
    timer.advance();
    expect(timer.laps, [3]);
    ms = 10050;
    timer.advance();
    timer.start();
    timer.advance();
    expect(timer.done, isTrue);
    expect(timer.running, isFalse);
    expect(timer.laps, [3, 3]);
  });
}
