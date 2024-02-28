import 'package:oriole/oriole.dart';

class OrioleKey {
  int key;
  String name;

  OrioleKey(this.name) : key = Oriole.to.treeInfo.routeIndexer++;

  bool hasName(String name) => this.name == name;

  bool hasKey(int key) => this.key == key;

  bool isSame(OrioleKey other) => hasKey(other.key);

  @override
  String toString() => 'Key: [$key]($name)';
}
