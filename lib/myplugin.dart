import 'dart:async';

import 'package:flutter/services.dart';

class Myplugin {
  static const MethodChannel _channel = const MethodChannel('myplugin');
  static Future<String> streamurl(String embedUrl) async {
    final String result = await _channel.invokeMethod('getStreamurl', embedUrl);
    return result;
  }
}
