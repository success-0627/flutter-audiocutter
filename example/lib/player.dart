import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }

class MediaPlayerWidget extends StatefulWidget {
  final String url;
  final bool isLocal;
  final PlayerMode mode;

  MediaPlayerWidget(
      {@required this.url,
      this.isLocal = false,
      this.mode = PlayerMode.MEDIA_PLAYER});

  @override
  State<StatefulWidget> createState() {
    return _MediaPlayerState(url, isLocal, mode);
  }
}

class _MediaPlayerState extends State<MediaPlayerWidget> {
  String url;
  bool isLocal;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';

  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _MediaPlayerState(this.url, this.isLocal, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  /// Returns the slider value.
  double _getSliderValue() {
    if (_position == null || _position.inSeconds <= 0) {
      return 0.0;
    }

    return (_position >= _duration ? _duration.inSeconds : _position.inSeconds).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      IconButton(
          icon: _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
          iconSize: 55.0,
          color: Theme.of(context).primaryColor,
          onPressed: () => _isPlaying ? _pause() : _play()),
      Container(
          child: Text(
              _position != null
                  ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                  : _duration != null ? _durationText : '0:00:00/0:00:00',
              textAlign: TextAlign.left)),
      Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Expanded(
            child: Slider(
                value: _getSliderValue(),
                max: _duration != null ? _duration.inSeconds.toDouble() : 0.0,
                onChanged: (double newValue) =>
                    _seek(Duration(seconds: newValue.ceil())))),
      ]),
    ]);
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen((duration) => setState(() {
              _duration = duration;
            }));

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;

    // Close the keyboard.
    FocusScope.of(context).requestFocus(FocusNode());

    final result =
        await _audioPlayer.play(url, isLocal: isLocal, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _seek(Duration position) async {
    return await _audioPlayer.seek(position);
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
