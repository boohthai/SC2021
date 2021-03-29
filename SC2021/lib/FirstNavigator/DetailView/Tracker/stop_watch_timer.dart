import 'dart:async';

import 'package:rxdart/rxdart.dart';

class StopWatchRecord {
  StopWatchRecord({
    this.rawValue,
    this.minute,
    this.second,
    this.displayTime,
  });
  int rawValue;
  int minute;
  int second;
  String displayTime;
}

/// StopWatch ExecuteType
enum StopWatchExecute { start, stop, reset, lap }

/// StopWatchTimer
class StopWatchTimer {
  StopWatchTimer({
    this.onChange,
    this.onChangeSecond,
    this.onChangeMinute,
    this.duration,
  }) {
    _configure();
  }

  final Function(int) onChange;
  final Function(int) onChangeSecond;
  final Function(int) onChangeMinute;
  int duration;

  final PublishSubject<int> _elapsedTime = PublishSubject<int>();

  final BehaviorSubject<int> _rawTimeController =
  BehaviorSubject<int>.seeded(0);
  ValueStream<int> get rawTime => _rawTimeController;

  final BehaviorSubject<int> _secondTimeController =
  BehaviorSubject<int>.seeded(0);
  ValueStream<int> get secondTime => _secondTimeController;

  final BehaviorSubject<int> _minuteTimeController =
  BehaviorSubject<int>.seeded(0);
  ValueStream<int> get minuteTime => _minuteTimeController;

  final BehaviorSubject<List<StopWatchRecord>> _recordsController =
  BehaviorSubject<List<StopWatchRecord>>.seeded([]);
  ValueStream<List<StopWatchRecord>> get records => _recordsController;

  final PublishSubject<StopWatchExecute> _executeController =
  PublishSubject<StopWatchExecute>();
  Stream<StopWatchExecute> get execute => _executeController;
  Sink<StopWatchExecute> get onExecute => _executeController.sink;

  Timer _timer;
  int _startTime = 0;
  int _stopTime = 0;
  int _second;
  int _minute;
  List<StopWatchRecord> _records = [];

  /// Get display time.
  static String getDisplayTime(
      int value, {
        bool minute = true,
        bool second = true,
        bool milliSecond = true,
        String minuteRightBreak = ':',
        String secondRightBreak = '.',
      }) {
    final mStr = getDisplayTimeMinute(value);
    final sStr = getDisplayTimeSecond(value);
    final msStr = getDisplayTimeMilliSecond(value);
    var result = '';
    if (minute) {
      result += '$mStr';
    }
    if (second) {
      if (minute) {
        result += minuteRightBreak;
      }
      result += '$sStr';
    }
    if (milliSecond) {
      if (second) {
        result += secondRightBreak;
      }
      result += '$msStr';
    }
    return result;
  }

  /// Get display minute time.
  static String getDisplayTimeMinute(int value) {
    final m = (value / 60000).floor();
    return m.toString().padLeft(2, '0');
  }

  /// Get display second time.
  static String getDisplayTimeSecond(int value) {
    final s = (value % 60000 / 1000).floor();
    return s.toString().padLeft(2, '0');
  }

  /// Get display millisecond time.
  static String getDisplayTimeMilliSecond(int value) {
    final ms = (value % 1000 / 10).floor();
    return ms.toString().padLeft(2, '0');
  }

  /// When finish running timer, it need to dispose.
  Future dispose() async {
    await _elapsedTime.close();
    await _rawTimeController.close();
    await _secondTimeController.close();
    await _minuteTimeController.close();
    await _recordsController.close();
    await _executeController.close();
  }

  /// Get display millisecond time.
  bool isRunning() => _timer != null ? _timer.isActive : false;

  Future _configure() async {
    _elapsedTime.listen((value) {
      _rawTimeController.add(value);
      if (onChange != null) {
        onChange(value);
      }
      final latestSecond = _getSecond(value);
      if (_second != latestSecond) {
        _secondTimeController.add(latestSecond);
        _second = latestSecond;
        if (onChangeSecond != null) {
          onChangeSecond(latestSecond);
        }
      }
      final latestMinute = _getMinute(value);
      if (_minute != latestMinute) {
        _minuteTimeController.add(latestMinute);
        _minute = latestMinute;
        if (onChangeMinute != null) {
          onChangeMinute(latestMinute);
        }
      }
    });

    _executeController.where((value) => value != null).listen((value) {
      switch (value) {
        case StopWatchExecute.start:
          _start();
          break;
        case StopWatchExecute.stop:
          _stop();
          break;
        case StopWatchExecute.reset:
          _reset();
          break;
        case StopWatchExecute.lap:
          _lap();
          break;
      }
    });
  }

  int _getMinute(int value) => (value / 60000).floor();

  int _getSecond(int value) => (value / 1000).floor();

  void _handle(Timer timer) => _elapsedTime
      .add(DateTime.now().millisecondsSinceEpoch - _startTime + _stopTime);

  void _start() {
    if (_timer == null || !_timer.isActive) {
      print(duration);
      _startTime = DateTime.now().millisecondsSinceEpoch - (1000 * duration);
      _timer = Timer.periodic(const Duration(milliseconds: 1), _handle);
    }
  }

  void _stop() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
      _stopTime += DateTime.now().millisecondsSinceEpoch - _startTime;
    }
  }

  void _reset() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
    _startTime = 0;
    _stopTime = 0;
    _second = null;
    _minute = null;
    _records = [];
    _recordsController.add(_records);
    _elapsedTime.add(0);
  }

  void _lap() {
    if (_timer != null && _timer.isActive) {
      final rawValue = _rawTimeController.value;
      _records.add(StopWatchRecord(
        rawValue: rawValue,
        minute: _getMinute(rawValue),
        second: _getSecond(rawValue),
        displayTime: getDisplayTime(rawValue),
      ));
      _recordsController.add(_records);
    }
  }
}
