import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'app/screen/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: YouTubePlaylistScreen(),
    );
  }
}

class YouTubePlaylistUI extends StatefulWidget {
  const YouTubePlaylistUI({super.key});

  @override
  _YouTubePlaylistUIState createState() => _YouTubePlaylistUIState();
}

class _YouTubePlaylistUIState extends State<YouTubePlaylistUI> {
  late YoutubePlayerController _controller;

  final List<Map<String, String>> _playlist = [
    {
      "url": "https://www.youtube.com/watch?v=bxDFCGGhX8E",
      "title": "Flutter Tutorial 1",
      "channel": "Flutter Channel",
    },
    {
      "url": "https://www.youtube.com/watch?v=aqz-KE-bpKQ",
      "title": "Flutter Tutorial 2",
      "channel": "Flutter Channel",
    },
    {
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "title": "Flutter Tutorial 3",
      "channel": "Flutter Channel",
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer(_playlist[_currentIndex]["url"]!);
  }

  void _initializePlayer(String url) {
    String videoId = YoutubePlayer.convertUrlToId(url) ?? url;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: true,
      ),
    );

    _controller.addListener(() {
      if (_controller.value.playerState == PlayerState.ended) {
        _playNext();
      }
    });
  }

  void _playNext() {
    if (_currentIndex < _playlist.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.load(
          YoutubePlayer.convertUrlToId(_playlist[_currentIndex]["url"]!)!,
        );
      });
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _controller.load(
          YoutubePlayer.convertUrlToId(_playlist[_currentIndex]["url"]!)!,
        );
      });
    }
  }

  Widget _buildHorizontalPlaylist() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _playlist.length,
        itemBuilder: (context, index) {
          String videoId =
              YoutubePlayer.convertUrlToId(_playlist[index]["url"]!) ?? "";
          bool isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
                _controller.load(videoId);
              });
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.red, width: 3)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      YoutubePlayer.getThumbnail(videoId: videoId),
                      height: 90,
                      width: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _playlist[index]["title"]!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("YouTube Playlist UI"),
            backgroundColor: Colors.red,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                player,
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    _playlist[_currentIndex]["title"]!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _playlist[_currentIndex]["channel"]!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _playPrevious,
                      child: const Icon(Icons.skip_previous),
                    ),
                    ElevatedButton(
                      onPressed: _playNext,
                      child: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Up Next",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildHorizontalPlaylist(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
