import 'package:material_ui/material_ui.dart';

import '../domain/talk.dart';
import 'notebook.dart';
import 'shared.dart';

class _Fields {
  final String key;
  final TextEditingController name, minutes;
  _Fields(this.key, String title, int time)
    : name = TextEditingController(text: title),
      minutes = TextEditingController(text: time.toString());
  void dispose() {
    name.dispose();
    minutes.dispose();
  }
}

class EditorPage extends StatefulWidget {
  final Talk? existing;
  final Notebook book;
  const EditorPage({super.key, this.existing, required this.book});
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.existing?.title);
  late final limit = TextEditingController(
    text: (widget.existing?.minutes ?? 15).toString(),
  );
  int serial = 0;
  late final rows = [
    for (final cue in widget.existing?.blocks ?? [Cue('Apertura', 3)])
      _Fields((serial++).toString(), cue.name, cue.minutes),
  ];
  late final id =
      widget.existing?.id ?? 'charla-${DateTime.now().microsecondsSinceEpoch}';
  bool saving = false;
  String? error;
  @override
  void dispose() {
    title.dispose();
    limit.dispose();
    for (final row in rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (saving) {
      return;
    }
    final visibleValid = form.currentState!.validate();
    bool validName(String value) =>
        value.trim().isNotEmpty && value.trim().length <= 80;
    bool validMinutes(String value) {
      final n = int.tryParse(value.trim());
      return n != null && n >= 1 && n <= 180;
    }

    final invalid = rows.indexWhere(
      (r) => !validName(r.name.text) || !validMinutes(r.minutes.text),
    );
    if (!visibleValid ||
        !validName(title.text) ||
        !validMinutes(limit.text) ||
        invalid >= 0) {
      setState(
        () => error = invalid >= 0
            ? 'Revisa el nombre y la duración del bloque ${invalid + 1}.'
            : 'Revisa el título y el tiempo disponible de la charla.',
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final talk = Talk(id, title.text, int.parse(limit.text.trim()), [
      for (final row in rows)
        Cue(row.name.text, int.parse(row.minutes.text.trim())),
    ], widget.existing?.runs ?? []);
    final ok = await widget.book.save(talk);
    if (!mounted) {
      return;
    }
    if (ok) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      saving = false;
      error = widget.book.error ?? 'Hay una operación en curso.';
    });
  }

  Widget field(
    String label,
    TextEditingController control, {
    bool number = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: control,
      enabled: !saving,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (raw) {
        final s = raw?.trim() ?? '';
        if (number) {
          final n = int.tryParse(s);
          if (n == null || n < 1 || n > 180) {
            return 'Escribe de 1 a 180 minutos.';
          }
        } else if (s.isEmpty || s.length > 80) {
          return 'Escribe entre 1 y 80 caracteres.';
        }
        return null;
      },
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.existing == null ? 'Nueva charla' : 'Editar charla'),
    ),
    body: Form(
      key: form,
      child: Sheet(
        children: [
          field('Título de la charla', title),
          field('Tiempo disponible (min)', limit, number: true),
          for (var i = 0; i < rows.length; i++)
            Card(
              key: ValueKey(rows[i].key),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Bloque ${i + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          tooltip: 'Subir bloque ${i + 1}',
                          onPressed: i == 0 || saving
                              ? null
                              : () => setState(() {
                                  final moved = rows.removeAt(i);
                                  rows.insert(i - 1, moved);
                                }),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                        IconButton(
                          tooltip: 'Quitar bloque ${i + 1}',
                          onPressed: rows.length == 1 || saving
                              ? null
                              : () => setState(() {
                                  final removed = rows.removeAt(i);
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    removed.dispose();
                                  });
                                }),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ],
                    ),
                    field('Nombre del bloque', rows[i].name),
                    field('Minutos del bloque', rows[i].minutes, number: true),
                  ],
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: saving || rows.length >= 20
                ? null
                : () => setState(
                    () => rows.add(_Fields((serial++).toString(), '', 1)),
                  ),
            icon: const Icon(Icons.add),
            label: const Text('Añadir bloque'),
          ),
          FeedbackLine(error),
          FilledButton(
            onPressed: saving ? null : submit,
            child: Text(saving ? 'Guardando…' : 'Guardar charla'),
          ),
        ],
      ),
    ),
  );
}
