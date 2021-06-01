import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';

const _verbosePrefix = '[V]';
const _debugPrefix = '[D]';
const _infoPrefix = '[I]';
const _warningPrefix = '[W]';
const _errorPrefix = '[E]';

final _verbosePen = AnsiPen()..gray();
final _debugPen = AnsiPen()..blue();
final _infoPen = AnsiPen()..green();
final _warningPen = AnsiPen()..yellow();
final _errorPen = AnsiPen()..red();

String colorize(String message) {
  if (!kDebugMode) {
    return message;
  }
  if (message.length < 3) {
    return _debugPen(message);
  }
  final prefix = message.substring(0, 3);
  switch (prefix) {
    case _verbosePrefix:
      return _verbosePen(message);
    case _debugPrefix:
      return _debugPen(message);
    case _infoPrefix:
      return _infoPen(message);
    case _warningPrefix:
      return _warningPen(message);
    case _errorPrefix:
      return _errorPen(message);
    default:
      return _debugPen(message);
  }
}

void v(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('$_verbosePrefix $message');
  }
}

void d(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('$_debugPrefix $message');
  }
}

void i(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('$_infoPrefix $message');
  }
}

void w(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('$_warningPrefix $message');
  }
}

void e(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('$_errorPrefix $message');
  }
}
