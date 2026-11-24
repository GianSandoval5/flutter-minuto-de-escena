import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../domain/practice_clock.dart';
import '../domain/talk.dart';
import 'notebook.dart';
import 'shared.dart';

class RehearsalPage extends StatefulWidget {
  final Notebook book;
  final Talk talk;
  const RehearsalPage({super.key, required this.book, required this.talk});
  @override
  State<RehearsalPage> createState() => _RehearsalPageState();
}

class _RehearsalPageState extends State<RehearsalPage> {
  final source = Stopwatch()..start();
  late final clock = PracticeClock(
    widget.talk.blocks.length,
    () => source.elapsed,
  );
  Timer? ticker;
  Talk? result;
  bool saving = false;
  String? error;
  @override
  void dispose() {
    ticker?.cancel();
    source.stop();
    super.dispose();
  }

  void toggle() {
    setState(() {
      if (clock.running) {
        clock.pause();
        ticker?.cancel();
      } else {
        clock.start();
        ticker?.cancel();
        ticker = Timer.periodic(
          const Duration(milliseconds: 250),
          (_) => setState(() {}),
        );
      }
    });
  }

  void next() {
    setState(() {
      clock.advance();
      if (clock.done) {
        ticker?.cancel();
        result = widget.talk.record(clock.laps, DateTime.now());
      }
    });
  }

  Future<void> save() async {
    if (saving) {
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final ok = await widget.book.save(result!);
    if (!mounted) {
      return;
    }
    if (ok) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      saving = false;
      error = widget.book.error ?? 'Vuelve a intentar el guardado.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final talk = widget.talk;
    final cue = clock.done ? null : talk.blocks[clock.index];
    return PopScope(
      canPop:
          !saving &&
          result == null &&
          !clock.running &&
          clock.index == 0 &&
          clock.elapsed == Duration.zero,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || saving) {
          return;
        }
        final exit = await confirm(
          context,
          '¿Salir del ensayo?',
          'Se descartarán los tiempos de esta práctica.',
          'Salir',
        );
        if (exit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Sala de ensayo')),
        body: Sheet(
          children: [
            if (cue != null) ...[
              Cover(
                'BLOQUE ${clock.index + 1} DE ${talk.blocks.length}',
                cue.name,
                'Objetivo · ${cue.minutes} min',
              ),
              Center(
                child: Semantics(
                  label: 'Tiempo del bloque',
                  child: Text(
                    clockText(clock.elapsed.inSeconds),
                    style: const TextStyle(
                      color: ink,
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Center(child: Text(clock.running ? 'En curso' : 'En pausa')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: toggle,
                child: Text(clock.running ? 'Pausar' : 'Iniciar o reanudar'),
              ),
              OutlinedButton(
                onPressed: clock.running ? next : null,
                child: Text(
                  clock.index + 1 == talk.blocks.length
                      ? 'Finalizar ensayo'
                      : 'Siguiente bloque',
                ),
              ),
            ] else ...[
              Cover(
                'ENSAYO COMPLETO',
                clockText(result!.runs.first.total),
                difference(result!.runs.first.total - talk.minutes * 60),
              ),
              for (final lap in result!.runs.first.laps)
                ListTile(
                  title: Text(lap.cue.name),
                  subtitle: Text(
                    '${clockText(lap.seconds)} · Objetivo ${lap.cue.minutes} min',
                  ),
                ),
              FeedbackLine(error),
              FilledButton(
                onPressed: saving ? null : save,
                child: Text(saving ? 'Guardando…' : 'Guardar ensayo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
