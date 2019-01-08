import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';

import 'package:stereo/stereo.dart';

class MediaPlayerWidget extends StatefulWidget {
  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayerWidget> {
  /// Pause icon.
  static const Icon _pauseIcon = const Icon(FontAwesomeIcons.pause);

  /// Play icon.
  static const Icon _playIcon = const Icon(FontAwesomeIcons.play);

  /// Used to format duration.
  static NumberFormat _twoDigits = NumberFormat('00', 'en_GB');

  Stereo _player = Stereo();

  /// Returns the duration as a formatted string.
  String _formatDuration(Duration duration) {
    return '${_twoDigits.format(duration.inSeconds ~/ 60)}:${_twoDigits.format(duration.inSeconds % 60)}';
  }

  /// Returns the slider value.
  double _getSliderValue() {
    int position = _player.position.inSeconds;
    if (position <= 0) {
      return 0.0;
    } else if (position >= _player.duration.inSeconds) {
      return _player.duration.inSeconds.toDouble();
    } else {
      return position.toDouble();
    }
  }

  @override
  void initState() {
    super.initState();

    _player.durationNotifier.addListener(() => setState(() {}));
    _player.isPlayingNotifier.addListener(() => setState(() {}));
    _player.positionNotifier.addListener(() => setState(() {}));

    _player.completionHandler = () => _player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(
        height: 20.0,
      ),
      Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12.0,
        runSpacing: 8.0,
        children: <Widget>[
          IconButton(
              icon: _player.isPlaying ? _pauseIcon : _playIcon,
              iconSize: 30.0,
              color: Theme.of(context).primaryColor,
              onPressed: () =>
                  _player.isPlaying ? _player.pause() : _player.play()),
        ],
      ),
      Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Container(
            width: 50.0,
            child: Text(_formatDuration(_player.position),
                textAlign: TextAlign.left)),
        Expanded(
            child: Slider(
                value: _getSliderValue(),
                max: _player.duration.inSeconds.toDouble(),
                onChanged: (double newValue) =>
                    _player.seek(Duration(seconds: newValue.ceil())))),
        Container(
            width: 50.0,
            child: Text('-' + _formatDuration(_player.remaining),
                textAlign: TextAlign.right))
      ])
    ]);
  }
}
