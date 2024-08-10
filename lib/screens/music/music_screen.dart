import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:last_dep/screens/music/mini_player_wiegt.dart';
import 'player_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, String>> songs = [
    {
      "name": "Big Baby Tape, kizaru – Bandana.mp3",
      "url": "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/music%2FBig%20Baby%20Tape%2C%20kizaru%20%E2%80%93%20Bandana.mp3?alt=media&token=7cbc021b-fcdb-4dcb-8912-6a3f3692d251",
      "image": "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/images%2F%D0%91%D0%B5%D0%B7%20%D0%BD%D0%B0%D0%B7%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F%20(1).jpeg?alt=media&token=d9786f57-3a97-4020-99eb-a645e563fb7b"
    },
    {
      "name": "kizaru – Money long.mp3",
      "url": "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/music%2Fkizaru%20%E2%80%93%20Money%20long.mp3?alt=media&token=6ebcb6e6-acae-42bd-9184-059767fba2f2",
      "image": "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/images%2F%D0%91%D0%B5%D0%B7%20%D0%BD%D0%B0%D0%B7%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F.jpeg?alt=media&token=5010cd76-6741-4677-ad4f-82a214ff089d"
    },
    // Add more songs here...
  ];

  Map<String, String>? currentSong;
  int currentIndex = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playMusic(Map<String, String> song) {
    setState(() {
      currentSong = song;
    });
    _audioPlayer.setUrl(song['url']!);
    _audioPlayer.play();
  }

  void _playNextSong() {
    if (currentIndex + 1 < songs.length) {
      setState(() {
        currentIndex++;
        currentSong = songs[currentIndex];
      });
      _audioPlayer.setUrl(songs[currentIndex]['url']!);
      _audioPlayer.play();
    }
  }

  void _playPreviousSong() {
    if (currentIndex - 1 >= 0) {
      setState(() {
        currentIndex--;
        currentSong = songs[currentIndex];
      });
      _audioPlayer.setUrl(songs[currentIndex]['url']!);
      _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.musicScreenTitle),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.search,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      songs = songs
                          .where((song) =>
                              song['name']!.toLowerCase().contains(text.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        width: 50.0,
                        height: 50.0,
                        child: Image.network(songs[index]['image']!, fit: BoxFit.cover),
                      ),
                      title: Text(songs[index]['name']!),
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                        _playMusic(songs[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (currentSong != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayerWidget(
                audioPlayer: _audioPlayer,
                title: currentSong!['name']!,
                coverUrl: currentSong!['image']!,
                onExpand: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => PlayerWidget(
                      audioPlayer: _audioPlayer,
                      title: currentSong!['name']!,
                      coverUrl: currentSong!['image']!,
                      onNext: _playNextSong,
                      onPrevious: _playPreviousSong,
                    ),
                  );
                },
                onNext: _playNextSong,
                onPrevious: _playPreviousSong,
              ),
            ),
        ],
      ),
    );
  }
}
