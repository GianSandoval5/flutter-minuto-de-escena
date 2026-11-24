import 'package:flutter/foundation.dart';

import '../domain/talk.dart';

class Notebook extends ChangeNotifier {
  final TalkRepository repository;
  Notebook(this.repository);
  List<Talk> talks = const [];
  String? error;
  bool busy = false;
  Talk byId(String id) => talks.firstWhere((t) => t.id == id);
  Future<bool> _act(Future<void> Function() action) async {
    if (busy) {
      return false;
    }
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> refresh() => _act(() async {
    talks = List.unmodifiable(await repository.list());
  });
  Future<bool> save(Talk talk) => _act(() async {
    await repository.save(talk);
    talks = List.unmodifiable([talk, ...talks.where((t) => t.id != talk.id)]);
  });
  Future<bool> remove(String id) => _act(() async {
    await repository.remove(id);
    talks = List.unmodifiable(talks.where((t) => t.id != id));
  });
}
