import 'package:oriole/src/types/params.dart';
import 'package:oriole/src/routes/route_internal.dart';
import 'oriole_key.dart';

final class OrioleHistory {
  final _history = <OrioleHistoryEntry>[];
  bool allowDuplications = false;

  List<OrioleHistoryEntry> get entries => List.unmodifiable(_history);

  OrioleHistoryEntry get current => _history.last;

  OrioleHistoryEntry get last => _history[_history.length - 2];

  OrioleHistoryEntry get beforeLast => _history[_history.length - 3];

  bool get hasLast => _history.length > 1;

  bool get isEmpty => _history.isEmpty;

  int get length => _history.length;

  void removeLast({int count = 1}) {
    for (var i = 0; i < count; i++) {
      if (_history.isNotEmpty) {
        _history.removeLast();
      }
    }
  }

  OrioleHistoryEntry? findLastForNavigator(String navigator) {
    for (var i = _history.length - 1; i >= 0; i--) {
      if (_history[i].navigator == navigator) {
        return _history[i];
      }
    }
    return null;
  }

  void removeWithNavigator(String navi) {
    _history.removeWhere((element) => element.navigator == navi);
  }

  void remove(OrioleRouteInternal route) {
    final entry = _history.lastIndexWhere((element) => element.key == route.key);
    if (entry == -1) return;
    _history.removeAt(entry);
  }

  void add(OrioleHistoryEntry entry) {
    if (hasLast && !allowDuplications) {
      if (current.isSame(entry)) {
        removeLast();
      }
      if (hasLast && last.isSame(entry)) {
        _history.removeAt(_history.length - 2);
      }
    }
    _history.add(entry);
  }

  void clear() => _history.clear();
}

final class OrioleHistoryEntry {
  final OrioleKey key;
  final String path;
  final String navigator;
  final bool isSkipped;
  final OrioleParams params;

  OrioleHistoryEntry(
    this.key,
    this.path,
    this.params,
    this.navigator,
    this.isSkipped,
  );

  bool isSame(OrioleHistoryEntry other) {
    return path == other.path && navigator == other.navigator;
  }

  @override
  String toString() {
    return 'key:$key, path:$path, navigator:$navigator';
  }
}
