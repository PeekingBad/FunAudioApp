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
          padding: const EdgeInsets.only(bottom: 50.0),
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
              const SizedBox(height: 20),
              Divider(
                thickness: 2.0,
                indent: 20.0,
                endIndent: 20.0,
                color: Colors.grey[400],
              ),
              SizedBox(height: 20),
              const Padding(
                padding:
                    EdgeInsets.all(16.0), // De gewenste horizontale padding.
                child: Text(
                  """Er waren eens een koning en een koningin. Zij hadden een grote wens. Ze wilden heel graag een kindje. 

Op een mooie dag, toen alle rozen van het paleis bloeiden, ging de wens in vervulling. Er werd een prachtig prinsesje geboren. In het hele land was het feest en iedereen mocht naar het paleis komen. Ook alle goede feeën. Helaas was de koningin één fee vergeten uit te nodigen. Toen het feest in volle gang was, net op het moment dat de feeën hun wensen uitspraken voor het prinsesje, sloegen met een klap de paleisdeuren open. Daar was de vergeten fee. “Ik heb ook nog een wens voor het prinsesje. Op de dag dat ze achttien jaar wordt, zal ze zich prikken aan een spinnewiel en sterven.” “Nee! Dat mag niet gebeuren”, sprak een kleine fee. “Ik heb mijn wens nog niet uitgesproken. De prinses zal niet sterven, maar honderd jaar slapen.” En zo gebeurde het. 

Op de dag van haar achttiende verjaardag zwierf de prinses rond in het paleis. In een ver kamertje, hoog in de toren vond zij een spinnewiel. Ze prikte zich... en viel in een diepe slaap. Als door een wonder viel iedereen in het paleis samen met haar in slaap en groeide er een dikke rozenhaag rond het kasteel. Alle mensen in het land vergaten het kasteel en de koninklijke familie. Tot op een dag - het was precies honderd jaar later - er een mooie prins voorbij de enorme rozenstruik kwam…""",
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.left,
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
