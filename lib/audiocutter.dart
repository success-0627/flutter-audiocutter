import 'dart:async';

import 'package:flutter/services.dart';

class Audiocutter {
  static const MethodChannel _channel =
      const MethodChannel('audiocutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
