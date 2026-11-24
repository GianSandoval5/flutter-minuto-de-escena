class PracticeClock {
  final int count;
  final Duration Function() now;
  final List<int> _laps = [];
  Duration _carried = Duration.zero;
  Duration? _started;
  PracticeClock(this.count, this.now);
  bool get running => _started != null;
  bool get done => _laps.length == count;
  int get index => _laps.length;
  List<int> get laps => List.unmodifiable(_laps);
  Duration get elapsed =>
      _started == null ? _carried : _carried + now() - _started!;
  void start() {
    if (!running && !done) {
      _started = now();
    }
  }

  void pause() {
    _carried = elapsed;
    _started = null;
  }

  void advance() {
    if (!running || done) {
      return;
    }
    pause();
    _laps.add((_carried.inMilliseconds / 1000).round());
    _carried = Duration.zero;
    if (!done) {
      start();
    }
  }
}
