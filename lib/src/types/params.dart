import 'package:flutter/foundation.dart';

final class OrioleParams {
  final Map<String, ParamValue> _params;

  OrioleParams({Map<String, ParamValue>? params})
      : _params = params ?? <String, ParamValue>{};

  OrioleParams copyWith() => OrioleParams(params: Map.from(_params));

  ParamValue? operator [](String key) => _params[key];

  void operator []=(String key, Object value) =>
      _params[key] = ParamValue(value);

  Map<String, ParamValue> get asMap => _params;

  Map<String, dynamic> get asValueMap {
    final result = <String, dynamic>{};
    for (var item in _params.entries) {
      result[item.key] = item.value.value;
    }
    return result;
  }

  Map<String, String> asStringMap() {
    final result = <String, String>{};
    for (var item in _params.entries) {
      result[item.key] = item.value.toString();
    }
    return result;
  }

  int get length => _params.length;

  bool get isEmpty => _params.isEmpty;

  bool get isNotEmpty => _params.isNotEmpty;

  void clear() => _params.clear();

  List<String> get keys => _params.keys.toList();

  void addAll(Map<String, dynamic> other) => _params
      .addAll(other.map((key, value) => MapEntry(key, ParamValue(value))));

  void ensureExist(
    String name, {
    Object? initValue,
    int? cleanupAfter,
    bool keepAlive = false,
    ParamChanged? onChange,
    Function()? onDelete,
  }) {
    if (_params[name] != null) {
      return;
    }
    _params[name] = ParamValue(
      initValue,
      keepAlive: keepAlive || cleanupAfter != null,
      cleanupAfter: cleanupAfter,
      onChange: onChange,
      onDelete: onDelete,
    );
  }

  void addAsHidden(String key, Object value, {int cleanUpAfter = 1}) {
    _params[key] = ParamValue(
      value,
      cleanupAfter: cleanUpAfter,
      keepAlive: true,
    );
  }

  void updateParam(
    String name,
    Object value, {
    int? cleanupAfter,
    bool keepAlive = false,
    ParamChanged? onChange,
    Function()? onDelete,
  }) {
    final newParam = _params[name]!.copyWith(
      value: value,
      cleanupAfter: cleanupAfter,
      keepAlive: keepAlive,
      onChange: onChange,
      onDelete: onDelete,
    );
    final params = Map<String, ParamValue>.from(_params);
    params[name] = newParam;
    updateParams(OrioleParams(params: params));
  }

  void updateParams(OrioleParams newParams) {
    final newKeys = newParams.keys;
    for (var key in keys) {
      if (!newKeys.contains(key)) {
        if (_params[key]?.onDelete != null) {
          _params[key]!.onDelete!();
        }
        if (!_params[key]!.keepAlive) {
          _params.remove(key);
        } else if (_params[key]!.cleanupAfter != null) {
          if (_params[key]!.cleanupAfter! <= 0) {
            _params.remove(key);
          } else {
            _params[key]!.cleanupAfter = _params[key]!.cleanupAfter! - 1;
          }
        }
      }
    }
    for (var key in newKeys) {
      if (keys.contains(key)) {
        if (!_params[key]!.isSame(newParams[key]!)) {
          if (_params[key]?.onChange != null) {
            _params[key]!.onChange!(
                _params[key]!._value, newParams[key]!._value);
          }
          _params[key] = _params[key]!.copyWith(value: newParams[key]!._value);
        }
      } else {
        _params[key] = newParams[key]!;
      }
    }
  }

  bool isSame(OrioleParams other) =>
      length == other.length && mapEquals(asValueMap, other.asValueMap);
}

final class ParamValue {
  final Object? _value;
  bool keepAlive;
  int? cleanupAfter;
  ParamChanged? onChange;
  Function()? onDelete;

  ParamValue(
    this._value, {
    this.keepAlive = false,
    this.cleanupAfter,
    this.onChange,
    this.onDelete,
  });

  ParamValue copyWith({
    Object? value,
    bool? keepAlive,
    int? cleanupAfter,
    ParamChanged? onChange,
    Function()? onDelete,
  }) {
    return ParamValue(
      value ?? _value,
      keepAlive: keepAlive ?? this.keepAlive,
      cleanupAfter: cleanupAfter ?? this.cleanupAfter,
      onChange: onChange ?? this.onChange,
      onDelete: onDelete ?? this.onDelete,
    );
  }

  bool isSame(ParamValue other) => _value == other.value;

  bool get hasValue => _value != null;

  Object? get value => _value;

  T? valueAs<T>() => value as T;

  int? get asInt => hasValue ? int.parse(toString()) : null;

  double? get asDouble => hasValue ? double.parse(toString()) : null;

  String get asString => hasValue ? value.toString() : '';

  @override
  String toString() => hasValue ? value.toString() : 'null';
}

typedef ParamChanged = Function(Object?, Object?);
