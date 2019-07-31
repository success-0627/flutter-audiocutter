import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

/// An audio cutting class that will clip audio files into specified chunks.
class AudioCutter {
  static const MethodChannel _channel = const MethodChannel('audiocutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Cuts the audio from [path].
  ///
  /// Returns a the path of the cut audio, specified by the [start] and [end] in
  /// seconds, cut from the original audio source.
  ///
  /// Throws an [ArgumentError] if the [end] time is after the [start] time.
  /// Throws an [ArgumentError] if the [start] or [end] are negative.
  static Future<String> cutAudio(String path, double start, double end) async {
    if (start < 0.0 || end < 0.0) {
      throw ArgumentError('Cannot pass negative values.');
    }

    if (start > end) {
      throw ArgumentError('Cannot have start time after end.');
    }

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

    final Directory dir = await getTemporaryDirectory();
    final outPath = "${dir.path}/output.mp3";
    var cmd =
        "-y -i \"$path\" -vn -ss $start -to $end -ar 16k -ac 2 -b:a 96k -acodec libmp3lame $outPath";
    int rc = await _flutterFFmpeg.execute(cmd);

    if (rc != 0) {
      throw ("[FFmpeg] process exited with rc $rc");
    }

    return outPath;
  }
}
