String clockText(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

String difference(int seconds) {
  if (seconds == 0) {
    return 'Justo a tiempo';
  }
  final amount = clockText(seconds.abs());
  return seconds > 0 ? '$amount por encima' : '$amount de margen';
}

class Cue {
  final String name;
  final int minutes;
  Cue(String text, this.minutes) : name = text.trim() {
    if (name.isEmpty || name.length > 80 || minutes < 1 || minutes > 180) {
      throw const FormatException(
        'Cada bloque requiere un nombre y de 1 a 180 minutos.',
      );
    }
  }
}

class Lap {
  final Cue cue;
  final int seconds;
  Lap(this.cue, this.seconds) {
    if (seconds < 0) {
      throw const FormatException('Tiempo negativo.');
    }
  }
}

class Rehearsal {
  final DateTime at;
  final int budget;
  final List<Lap> laps;
  Rehearsal(this.at, this.budget, Iterable<Lap> entries)
    : laps = List.unmodifiable(entries) {
    if (laps.isEmpty || budget < 1 || budget > 180) {
      throw const FormatException('Ensayo incompleto.');
    }
  }
  int get total => laps.fold(0, (sum, lap) => sum + lap.seconds);
}

class Talk {
  final String id;
  final String title;
  final int minutes;
  final List<Cue> blocks;
  final List<Rehearsal> runs;
  Talk(
    this.id,
    String text,
    this.minutes,
    Iterable<Cue> cues, [
    Iterable<Rehearsal> history = const [],
  ]) : title = text.trim(),
       blocks = List.unmodifiable(cues),
       runs = List.unmodifiable(history) {
    if (id.trim().isEmpty ||
        title.isEmpty ||
        title.length > 80 ||
        minutes < 1 ||
        minutes > 180 ||
        blocks.isEmpty ||
        blocks.length > 20) {
      throw const FormatException(
        'Revisa el título, la duración y los bloques.',
      );
    }
  }
  int get planned => blocks.fold(0, (sum, cue) => sum + cue.minutes);
  Talk record(List<int> seconds, DateTime now) {
    if (seconds.length != blocks.length) {
      throw const FormatException('Faltan bloques por medir.');
    }
    final run = Rehearsal(now.toUtc(), minutes, [
      for (var i = 0; i < blocks.length; i++) Lap(blocks[i], seconds[i]),
    ]);
    return Talk(id, title, minutes, blocks, [run, ...runs]);
  }
}

abstract interface class TalkRepository {
  Future<List<Talk>> list();
  Future<void> save(Talk talk);
  Future<void> remove(String id);
}
