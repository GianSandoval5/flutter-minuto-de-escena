import 'package:material_ui/material_ui.dart';

import '../domain/talk.dart';
import 'editor_page.dart';
import 'history_page.dart';
import 'notebook.dart';
import 'rehearsal_page.dart';
import 'shared.dart';

class DetailPage extends StatelessWidget {
  final Notebook book;
  final String id;
  const DetailPage({super.key, required this.book, required this.id});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: book,
    builder: (context, _) {
      if (!book.talks.any((t) => t.id == id)) {
        return const Scaffold();
      }
      final talk = book.byId(id);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Guion'),
          actions: [
            IconButton(
              tooltip: 'Editar charla',
              onPressed: book.busy
                  ? null
                  : () => page(context, EditorPage(book: book, existing: talk)),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: Sheet(
          children: [
            Cover(
              'GUION DE LA CHARLA',
              talk.title,
              '${talk.minutes} min disponibles · ${talk.planned} min previstos',
            ),
            Text(
              'Balance del guion · ${difference((talk.planned - talk.minutes) * 60)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < talk.blocks.length; i++)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(talk.blocks[i].name),
                  subtitle: Text('Objetivo · ${talk.blocks[i].minutes} min'),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: book.busy
                  ? null
                  : () => page(context, RehearsalPage(book: book, talk: talk)),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Ensayar'),
            ),
            OutlinedButton(
              onPressed: () => page(context, HistoryPage(talk: talk)),
              child: Text('Historial (${talk.runs.length})'),
            ),
            FeedbackLine(book.error),
            TextButton(
              onPressed: book.busy
                  ? null
                  : () async {
                      final agree = await confirm(
                        context,
                        '¿Eliminar esta charla?',
                        'Se borrarán el guion y sus ensayos guardados.',
                        'Eliminar',
                      );
                      if (!agree || !context.mounted) {
                        return;
                      }
                      final ok = await book.remove(id);
                      if (ok && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: const Text('Eliminar charla'),
            ),
          ],
        ),
      );
    },
  );
}
