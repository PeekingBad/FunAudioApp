import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioPlayerPage(),
    );
  }
}

class AudioPlayerPage extends StatefulWidget {
  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.STOP);

    final player = AudioCache(prefix: 'assets/');
    final url = await player.load('doornroosje.mp3');
    audioPlayer.setUrl(url.path, isLocal: true);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Doornroosje'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0), // Voegt horizontale padding toe
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/doornroosje.jpg',
                      width: double
                          .infinity, // Behoudt de breedte aan de randen na padding
                      height: 200, // Hoogte zoals voorheen
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Luister naar Doornroosje',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final newPosition = Duration(seconds: value.toInt());
                  await audioPlayer.seek(newPosition);
                  if (!isPlaying) {
                    await audioPlayer.resume();
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position)),
                    Text(formatTime(duration - position)),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 25,
                  onPressed: togglePlayPause,
                ),
              ),
              const SizedBox(
                  height: 20), // Ruimte toevoegen onder de afspeelknop
              const Text(
                'Geniet van het verhaal!', // Tekst toegevoegd onder de knop
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );

  void togglePlayPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
  }
}
