import 'dart:io';

import 'package:audiocutter_example/player.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:audiocutter/audiocutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stereo/stereo.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stereo _player = new Stereo();
  final audioFileStartController = TextEditingController();
  final audioFileEndController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load song from assets folder.
    _copyAssetAudioToLocalDir().then((path) {
      _loadPathToPlayer(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Audiocutter example'),
        ),
        body: Center(
          child: audioCutter(context),
        ),
      ),
    );
  }

  Widget audioCutter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Start time in seconds'),
          controller: audioFileStartController,
        ),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'End time in seconds'),
          controller: audioFileEndController,
        ),
        SizedBox(
          height: 10.0,
        ),
        OutlineButton(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
            onPressed: _cutSong,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.content_cut),
                SizedBox(
                  width: 5.0,
                ),
                Text('Cut Song'),
              ],
            ),
            textColor: Theme.of(context).primaryColor,
            color: Theme.of(context).primaryColor),
        MediaPlayerWidget(),
        MaterialButton(
            onPressed: () {
              _copyAssetAudioToLocalDir().then((path) {
                _loadPathToPlayer(path);
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.refresh),
                SizedBox(
                  width: 5.0,
                ),
                Text('Reload Full Song'),
              ],
            ),
            textColor: Colors.white,
            color: Theme.of(context).primaryColor),
      ]),
    );
  }

  /// Your reason for viewing this example!!!
  ///
  /// Takes the asset audio and passes the start and end times entered in the
  /// app to be chopped up and saved to the app directory.
  ///
  /// Also loads the cut song so you can listen to your new creation!
  ///
  /// Happy cutting!
  Future _cutSong() async {
    var start = audioFileStartController.text;
    var end = audioFileEndController.text;
    String path = await _copyAssetAudioToLocalDir();

    // Get bytes of audio.
    // So this is the part where one actually uses the AudioCutter. In the
    // future I will hopefully use the metadata directly from the audio. I just
    // haven't figured that out yet :D.
    final cutBytes = await AudioCutter.cutAudio(
        path, double.parse(start), double.parse(end), _player.duration);

    // Save to local dir.
    final Directory dir = await getApplicationDocumentsDirectory();
    final newPath = '${dir.path}/cut-hey.mp3';
    final File cutAudio = new File(newPath);

    await cutAudio.writeAsBytes(cutBytes, flush: true);

    // Load the cut audio.
    _loadPathToPlayer(newPath);
  }

  /// Loads the audio from [path] to the player to be available for playback.
  Future _loadPathToPlayer(String path) async {
    try {
      await _player.load(path);
    } on StereoFileNotPlayableException {
      var alert = new AlertDialog(
          title: new Text('File not playable'),
          content: new Text('The file you specified is not playable.'));

      showDialog(context: context, child: alert);
    }
  }

  /// Copies the asset audio to the local app dir to be used elsewhere.
  Future _copyAssetAudioToLocalDir() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/bensound-hey.mp3';
    final File song = new File(path);

    if (!(await song.exists())) {
      final data = await rootBundle.load('assets/bensound-hey.mp3');
      final bytes = data.buffer.asUint8List();
      await song.writeAsBytes(bytes, flush: true);
    }

    return path;
  }
}
