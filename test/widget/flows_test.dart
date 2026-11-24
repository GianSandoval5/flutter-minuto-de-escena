import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:minuto_de_escena/main.dart';
import 'package:minuto_de_escena/features/talks/domain/talk.dart';

import '../support/memory_repository.dart';

Future<void> tapText(WidgetTester t, String text) async {
  final finder = find.text(text).last;
  await t.ensureVisible(finder);
  await t.tap(finder);
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'La biblioteca permite recuperar un fallo y crear una charla válida',
    (t) async {
      final repo = MemoryRepository()..fail = true;
      await t.pumpWidget(EscenaApp(repository: repo));
      await t.pumpAndSettle();
      expect(find.textContaining('Error simulado'), findsOneWidget);
      repo.fail = false;
      await tapText(t, 'Reintentar');
      expect(find.text('Tu primera charla empieza aquí'), findsOneWidget);
      await tapText(t, 'Nueva charla');
      await tapText(t, 'Guardar charla');
      expect(find.text('Escribe entre 1 y 80 caracteres.'), findsOneWidget);
      await t.ensureVisible(find.byType(TextFormField).first);
      await t.enterText(find.byType(TextFormField).first, 'Una historia');
      await tapText(t, 'Guardar charla');
      expect(find.text('Una historia'), findsOneWidget);
      expect(repo.rows.values.single.blocks.single.name, 'Apertura');
    },
  );
  testWidgets(
    'Ensayar, pausar, reintentar el guardado y consultar el historial',
    (t) async {
      final repo = MemoryRepository([
        Talk('x', 'Luz', 3, [Cue('Inicio', 1), Cue('Demo', 2)]),
      ]);
      await t.pumpWidget(EscenaApp(repository: repo));
      await t.pumpAndSettle();
      await tapText(t, 'Luz');
      await tapText(t, 'Ensayar');
      await tapText(t, 'Iniciar o reanudar');
      await tapText(t, 'Pausar');
      expect(find.text('En pausa'), findsOneWidget);
      await tapText(t, 'Iniciar o reanudar');
      await tapText(t, 'Siguiente bloque');
      expect(find.text('Demo'), findsOneWidget);
      await tapText(t, 'Finalizar ensayo');
      repo.fail = true;
      await tapText(t, 'Guardar ensayo');
      expect(find.textContaining('Error simulado'), findsOneWidget);
      repo.fail = false;
      await tapText(t, 'Guardar ensayo');
      await tapText(t, 'Historial (1)');
      expect(find.text('ARCHIVO DE ENSAYOS'), findsOneWidget);
      expect(repo.rows['x']!.runs.single.laps, hasLength(2));
    },
  );
  testWidgets('La eliminación requiere confirmación y respeta cancelar', (
    t,
  ) async {
    final repo = MemoryRepository([
      Talk('x', 'Luz', 3, [Cue('Inicio', 3)]),
    ]);
    await t.pumpWidget(EscenaApp(repository: repo));
    await t.pumpAndSettle();
    await tapText(t, 'Luz');
    await tapText(t, 'Eliminar charla');
    await tapText(t, 'Cancelar');
    expect(repo.rows, hasLength(1));
    await tapText(t, 'Eliminar charla');
    await tapText(t, 'Eliminar');
    expect(repo.rows, isEmpty);
    expect(find.text('Tu primera charla empieza aquí'), findsOneWidget);
  });
  testWidgets(
    'Editar y reordenar un guion conserva los objetivos del historial',
    (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = const Size(500, 1050);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final source = Talk('x', 'Primera versión', 5, [
        Cue('Contexto', 2),
        Cue('Ejercicio', 3),
      ]).record([100, 201], DateTime.utc(2026, 11, 23));
      final repo = MemoryRepository([source]);
      await t.pumpWidget(EscenaApp(repository: repo));
      await t.pumpAndSettle();
      await tapText(t, 'Primera versión');
      await t.tap(find.byTooltip('Editar charla'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Subir bloque 2'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField).first, 'Segunda versión');
      await tapText(t, 'Guardar charla');
      expect(find.text('Segunda versión'), findsOneWidget);
      expect(repo.rows['x']!.blocks.first.name, 'Ejercicio');
      await tapText(t, 'Historial (1)');
      expect(find.textContaining('1:40'), findsOneWidget);
      expect(repo.rows['x']!.runs.single.laps.first.cue.name, 'Contexto');
    },
  );
}
