import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audiocutter/audiocutter.dart';
import 'package:path_provider/path_provider.dart';

import 'player.dart';

typedef void OnError(Exception exception);

void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  Future<String> _url;
  String _cutFilePath;
  final audioFileStartController = TextEditingController();
  final audioFileEndController = TextEditingController();

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

  @override
  void initState() {
    super.initState();

    // Load song from assets folder.
    _url = _copyAssetAudioToLocalDir();
  }

  Widget audioCutter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        FutureBuilder<String>(
          future: _url,
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return MediaPlayerWidget(url: snapshot.data, isLocal: true);
            }
            return Container();
          },
        ),
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
            BorderSide(color: Theme
                .of(context)
                .primaryColor, width: 2.0),
            onPressed: () async {
              var path = await _cutSong();
              setState(() {
                _cutFilePath = path;
              });
            },
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
            textColor: Theme
                .of(context)
                .primaryColor,
            color: Theme
                .of(context)
                .primaryColor),
        _cutFilePath == null
            ? Container()
            : MediaPlayerWidget(url: _cutFilePath, isLocal: true),
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
  Future<String> _cutSong() async {
    var start = audioFileStartController.text;
    var end = audioFileEndController.text;
    String path = await _copyAssetAudioToLocalDir();

    // Close the keyboard.
    FocusScope.of(context).requestFocus(FocusNode());

    return await AudioCutter.cutAudio(
        path, double.parse(start), double.parse(end));
  }

  /// Copies the asset audio to the local app dir to be used elsewhere.
  Future<String> _copyAssetAudioToLocalDir() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/bensound-sunny.mp3';
    final File song = new File(path);

    if (!(await song.exists())) {
      final data = await rootBundle.load('assets/bensound-sunny.mp3');
      final bytes = data.buffer.asUint8List();
      await song.writeAsBytes(bytes, flush: true);
    }

    return path;
  }
}
