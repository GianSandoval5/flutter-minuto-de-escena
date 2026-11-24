import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:minuto_de_escena/features/talks/data/mobilelab_repository.dart';
import 'package:minuto_de_escena/features/talks/data/talk_dto.dart';
import 'package:minuto_de_escena/features/talks/domain/talk.dart';

void main() {
  final base = Uri.parse('http://localhost:4566');
  final talk = Talk('una vez', 'Señal', 8, [
    Cue('Práctica', 5),
  ]).record([238], DateTime.utc(2026, 11, 23));
  test('El DTO conserva acentos, fecha UTC, objetivos y segundos', () {
    expect(
      TalkDto.encode(TalkDto.decode(TalkDto.encode(talk))),
      TalkDto.encode(talk),
    );
    final legacy = TalkDto.encode(talk)..remove('runs');
    expect(TalkDto.decode(legacy).runs, isEmpty);
    expect(() => TalkDto.decode({'id': 2}), throwsFormatException);
  });
  test('GET lee JSON UTF-8 y PUT y DELETE usan el ID en la ruta', () async {
    final calls = <String>[];
    final repo = MobileLabRepository(
      base,
      MockClient((request) async {
        calls.add(request.method);
        if (request.method == 'GET') {
          expect(request.url.path, '/api/talks');
          return http.Response.bytes(
            utf8.encode(jsonEncode([TalkDto.encode(talk)])),
            200,
          );
        }
        expect(request.url.pathSegments.last, 'una vez');
        if (request.method == 'PUT') {
          expect(
            jsonDecode(utf8.decode(request.bodyBytes)),
            TalkDto.encode(talk),
          );
          expect(request.headers['content-type'], contains('application/json'));
        }
        return http.Response('', request.method == 'PUT' ? 201 : 204);
      }),
    );
    expect((await repo.list()).single.title, 'Señal');
    await repo.save(talk);
    await repo.remove(talk.id);
    expect(calls, ['GET', 'PUT', 'DELETE']);
  });
  test(
    'Los errores HTTP retienen el código y se propagan al guardar',
    () async {
      final repo = MobileLabRepository(
        base,
        MockClient((_) async => http.Response('{}', 503)),
      );
      await expectLater(
        repo.save(talk),
        throwsA(
          isA<DataFailure>().having((e) => e.message, 'HTTP', contains('503')),
        ),
      );
    },
  );
  test(
    'Rechaza payload malformado, colección incompatible y fila incompleta',
    () async {
      for (final body in ['{', '{}', '[null]', '[{"id":"x"}]']) {
        final repo = MobileLabRepository(
          base,
          MockClient((_) async => http.Response(body, 200)),
        );
        await expectLater(repo.list(), throwsA(isA<DataFailure>()));
      }
    },
  );
  test('Distingue desconexión y timeout', () async {
    final offline = MobileLabRepository(
      base,
      MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(
      offline.list(),
      throwsA(
        isA<DataFailure>().having(
          (e) => e.message,
          'red',
          contains('conectar'),
        ),
      ),
    );
    final hung = MobileLabRepository(
      base,
      MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 5),
    );
    await expectLater(
      hung.list(),
      throwsA(
        isA<DataFailure>().having(
          (e) => e.message,
          'timeout',
          contains('demasiado'),
        ),
      ),
    );
  });
}
