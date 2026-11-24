import '../domain/talk.dart';

typedef Json = Map<String, dynamic>;

class TalkDto {
  static Json cue(Cue cue) => {'name': cue.name, 'minutes': cue.minutes};
  static Cue readCue(Json json) =>
      Cue(json['name'] as String, json['minutes'] as int);
  static Map<String, dynamic> encode(Talk talk) => {
    'id': talk.id,
    'title': talk.title,
    'minutes': talk.minutes,
    'blocks': talk.blocks.map(cue).toList(),
    'runs': [
      for (final run in talk.runs)
        {
          'at': run.at.toUtc().toIso8601String(),
          'budget': run.budget,
          'laps': [
            for (final lap in run.laps)
              {...cue(lap.cue), 'seconds': lap.seconds},
          ],
        },
    ],
  };
  static Talk decode(Json json) {
    try {
      return Talk(
        json['id'] as String,
        json['title'] as String,
        json['minutes'] as int,
        (json['blocks'] as List).cast<Json>().map(readCue),
        ((json['runs'] ?? []) as List).cast<Json>().map(
          (run) => Rehearsal(
            DateTime.parse(run['at'] as String),
            run['budget'] as int,
            (run['laps'] as List).cast<Json>().map(
              (lap) => Lap(readCue(lap), lap['seconds'] as int),
            ),
          ),
        ),
      );
    } on TypeError {
      throw const FormatException('Documento de charla incompatible.');
    }
  }
}
