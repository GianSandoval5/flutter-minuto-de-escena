import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:minuto_de_escena/main.dart';
import 'package:minuto_de_escena/features/talks/data/talk_dto.dart';

import '../../test/support/memory_repository.dart';

void main() {
  testWidgets(
    'Capturas del cuaderno y del guion con las semillas del proyecto',
    (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = const Size(420, 860);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final file = File(
        Platform.environment['CAPTURE_FONT'] ??
            '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
      );
      final data = ByteData.sublistView(file.readAsBytesSync());
      final loader = FontLoader('Roboto')..addFont(Future.value(data));
      await t.runAsync(loader.load);
      final docs = (jsonDecode(
        File('mobilelab/seeds/talks.json').readAsStringSync(),
      ) as List).cast<Json>();
      final repo = MemoryRepository(docs.map(TalkDto.decode));
      const key = ValueKey('capture');
      await t.pumpWidget(
        RepaintBoundary(
          key: key,
          child: EscenaApp(repository: repo),
        ),
      );
      await t.pumpAndSettle();
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('../../docs/capturas/cuaderno.png'),
      );
      await t.tap(find.text('Del boceto al prototipo'));
      await t.pumpAndSettle();
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('../../docs/capturas/guion.png'),
      );
    },
  );
}
