import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayerWidget extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final String title;
  final String coverUrl;
  final VoidCallback onExpand;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  MiniPlayerWidget({
    required this.audioPlayer,
    required this.title,
    required this.coverUrl,
    required this.onExpand,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExpand,
      child: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Row(
          children: [
            Image.network(
              coverUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.skip_previous, color: Colors.white),
              onPressed: onPrevious,
            ),
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final isPlaying = playerState?.playing ?? false;
                final processingState = playerState?.processingState;

                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 32.0,
                    height: 32.0,
                    child: const CircularProgressIndicator(),
                  );
                } else if (isPlaying != true) {
                  return IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: audioPlayer.play,
                  );
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    onPressed: audioPlayer.pause,
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.replay, color: Colors.white),
                    onPressed: () => audioPlayer.seek(Duration.zero, index: audioPlayer.effectiveIndices!.first),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.white),
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
