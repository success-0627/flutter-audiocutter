import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// An audio cutting class that will clip audio files into specified chunks.
class AudioCutter {
  /// The most common bitrates I found on the internet.
  static final _validBitrates = const [
    32000,
    56000,
    96000,
    128000,
    160000,
    196000
  ];

  static const MethodChannel _channel = const MethodChannel('audiocutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Cuts the audio from [path].
  ///
  /// Returns a [List<int>] of bytes, specified by the [start] and [end] in
  /// seconds, cut from the original audio source. At this time, unfortunately,
  /// one must pass in the audio [duration], since I currently don't know how to
  /// get this info using Dart's audio libraries.
  ///
  /// Throws an [ArgumentError] if the [end] time is after the [start] time.
  /// Throws an [ArgumentError] if the [start] or [end] are negative.
  static Future<List<int>> cutAudio(
      String path, double start, double end, Duration duration) async {
    if (start < 0.0 || end < 0.0) {
      throw ArgumentError('Cannot pass negative values.');
    }

    if (start > end) {
      throw ArgumentError('Cannot have start time after end.');
    }

    final File file = File(path);
    final bytesList = await file.readAsBytes();
    final bytes = Uint8List.fromList(bytesList);

    // This is probably not a very accurate way to get the exact bytes. But I
    // couldn't figure out how to extract all of the audio metadata in Dart, and
    // I didn't want to have to write custom stuff for each platform. This will
    // be the area I want to fix the most. I also highly doubt it will work out
    // of the box for anything but mp3 files. At the end of the day, I made this
    // plugin so I could have similar functionality used in
    // [Ringdroid](https://github.com/google/ringdroid). So if I can get feature
    // parity (regarding audio files types and accurate cutting), that would be
    // great.
    final bitrate = _roundBitrate(bytes.lengthInBytes * 8 / duration.inSeconds);
    int startingByte = (bitrate * start / 8).round();
    int endingByte = (bitrate * end / 8).round();
    return Uint8List.fromList(
        bytes.getRange(startingByte, endingByte).toList());
  }

  /// Round the [rawBits] to the closest valid bitrate.
  ///
  /// This is just an assumption. Hopefully when I have fleshed out the plugin
  /// a little more, I will have access to the actual bitrate.
  static int _roundBitrate(double rawBits) {
    List<int> bitrates = List.from(_validBitrates);
    return bitrates.reduce((prev, curr) =>
        (curr - rawBits).abs() < (prev - rawBits).abs() ? curr : prev);
  }
}
