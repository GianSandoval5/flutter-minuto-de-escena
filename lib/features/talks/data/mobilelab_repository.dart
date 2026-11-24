import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/talk.dart';
import 'talk_dto.dart';

class DataFailure implements Exception {
  final String message;
  const DataFailure(this.message);
  @override
  String toString() => message;
}

class MobileLabRepository implements TalkRepository {
  final Uri base;
  final http.Client client;
  final Duration timeout;
  MobileLabRepository(
    this.base,
    this.client, {
    this.timeout = const Duration(seconds: 8),
  });
  Uri _url([String? id]) => base.replace(
    pathSegments: [
      ...base.pathSegments.where((s) => s.isNotEmpty),
      'api',
      'talks',
      ?id,
    ],
  );
  Future<http.Response> _request(Future<http.Response> Function() send) async {
    try {
      final response = await send().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DataFailure('MobileLab respondió HTTP ${response.statusCode}.');
      }
      return response;
    } on TimeoutException {
      throw const DataFailure('MobileLab tardó demasiado. Inténtalo otra vez.');
    } on http.ClientException {
      throw const DataFailure(
        'No se pudo conectar. Comprueba la URL y el proceso de MobileLab.',
      );
    }
  }

  @override
  Future<List<Talk>> list() async {
    final response = await _request(() => client.get(_url()));
    try {
      final rows = jsonDecode(utf8.decode(response.bodyBytes));
      if (rows is! List) {
        throw const FormatException();
      }
      return [for (final row in rows) TalkDto.decode(row as Json)];
    } on FormatException {
      throw const DataFailure('MobileLab devolvió una charla ilegible.');
    } on TypeError {
      throw const DataFailure('La colección tiene un formato inesperado.');
    }
  }

  @override
  Future<void> save(Talk talk) async {
    await _request(
      () => client.put(
        _url(talk.id),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode(TalkDto.encode(talk))),
      ),
    );
  }

  @override
  Future<void> remove(String id) async {
    await _request(() => client.delete(_url(id)));
  }
}
