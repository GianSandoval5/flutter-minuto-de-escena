import 'package:material_ui/material_ui.dart';

import '../domain/talk.dart';
import 'shared.dart';

class HistoryPage extends StatelessWidget {
  final Talk talk;
  const HistoryPage({super.key, required this.talk});
  String stamp(DateTime time) {
    final local = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} · ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Historial')),
    body: Sheet(
      children: [
        Cover(
          'ARCHIVO DE ENSAYOS',
          talk.title,
          '${talk.runs.length} ensayos guardados',
        ),
        if (talk.runs.isEmpty)
          const ListTile(
            title: Text('Aún no hay ensayos'),
            subtitle: Text(
              'Completa un ensayo y guárdalo para comparar los tiempos por bloque.',
            ),
          ),
        for (var i = 0; i < talk.runs.length; i++)
          Card(
            child: ExpansionTile(
              initiallyExpanded: i == 0,
              title: Text(stamp(talk.runs[i].at)),
              subtitle: Text(
                '${clockText(talk.runs[i].total)} en total · ${difference(talk.runs[i].total - talk.runs[i].budget * 60)}',
              ),
              children: [
                for (final lap in talk.runs[i].laps)
                  ListTile(
                    title: Text(lap.cue.name),
                    subtitle: Text(
                      'Objetivo ${lap.cue.minutes} min · Real ${clockText(lap.seconds)} · ${difference(lap.seconds - lap.cue.minutes * 60)}',
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}
