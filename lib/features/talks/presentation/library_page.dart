import 'package:material_ui/material_ui.dart';

import 'detail_page.dart';
import 'editor_page.dart';
import 'notebook.dart';
import 'shared.dart';

class LibraryPage extends StatelessWidget {
  final Notebook book;
  const LibraryPage({super.key, required this.book});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: book,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Minuto de Escena'),
        actions: [
          IconButton(
            tooltip: 'Actualizar charlas',
            onPressed: book.busy ? null : book.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Sheet(
        children: [
          Cover(
            'CUADERNO DE ENSAYO',
            'Mis charlas',
            'Charlas: ${book.talks.length} · Sandbox local con datos de demostración',
          ),
          FilledButton.icon(
            onPressed: book.busy
                ? null
                : () => page(context, EditorPage(book: book)),
            icon: const Icon(Icons.add),
            label: const Text('Nueva charla'),
          ),
          const SizedBox(height: 12),
          if (book.busy)
            const LinearProgressIndicator(semanticsLabel: 'Cargando charlas'),
          FeedbackLine(book.error),
          if (book.error != null)
            TextButton(
              onPressed: book.busy ? null : book.refresh,
              child: const Text('Reintentar'),
            ),
          if (!book.busy && book.talks.isEmpty && book.error == null)
            const ListTile(
              title: Text('Tu primera charla empieza aquí'),
              subtitle: Text(
                'Añade el título, la duración disponible y los bloques que quieres ensayar.',
              ),
            ),
          for (final talk in book.talks)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                title: Text(talk.title),
                subtitle: Text(
                  '${talk.minutes} min · Bloques: ${talk.blocks.length} · Ensayos: ${talk.runs.length}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: book.busy
                    ? null
                    : () => page(context, DetailPage(book: book, id: talk.id)),
              ),
            ),
        ],
      ),
    ),
  );
}
