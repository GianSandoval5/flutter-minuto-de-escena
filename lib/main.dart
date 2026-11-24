import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'features/talks/data/mobilelab_repository.dart';
import 'features/talks/domain/talk.dart';
import 'features/talks/presentation/library_page.dart';
import 'features/talks/presentation/notebook.dart';

void main() {
  const configured = String.fromEnvironment('MOBILELAB_URL');
  final local = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : '127.0.0.1';
  final base = Uri.parse(
    configured.isEmpty ? 'http://$local:4566' : configured,
  );
  runApp(EscenaApp(repository: MobileLabRepository(base, http.Client())));
}

class EscenaApp extends StatefulWidget {
  final TalkRepository repository;
  const EscenaApp({super.key, required this.repository});
  @override
  State<EscenaApp> createState() => _EscenaAppState();
}

class _EscenaAppState extends State<EscenaApp> {
  late final book = Notebook(widget.repository)..refresh();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Minuto de Escena',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF245D51)),
      scaffoldBackgroundColor: const Color(0xFFFAF7EF),
      useMaterial3: true,
    ),
    home: LibraryPage(book: book),
  );
  @override
  void dispose() {
    book.dispose();
    super.dispose();
  }
}
