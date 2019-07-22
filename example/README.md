# audiocutter_example

Demonstrates how to use the audiocutter plugin.

## Getting Started

1. Import and cut!

```
    import 'package:audiocutter/audiocutter.dart';

    {...}

    var start = 15.0;
    var end = 25.5;
    var path = 'path/to/audio/file.mp3';

    // Get path to cut file and do whatever you want with it.
    var outputFilePath = await AudioCutter.cutAudio(path, start, end);

```
