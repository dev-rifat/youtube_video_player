import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeController extends GetxController {
  late YoutubePlayerController youtubeController;

  // Playlist
  final playlist = <Map<String, String>>[
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

  // Current index
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initPlayer(playlist[currentIndex.value]["url"]!);
  }

  void _initPlayer(String url) {
    String videoId = YoutubePlayer.convertUrlToId(url) ?? url;

    youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: true,
      ),
    );

    youtubeController.addListener(() {
      if (youtubeController.value.playerState == PlayerState.ended) {
        playNext();
      }
    });
  }

  void playVideo(int index) {
    if (index != currentIndex.value) {
      currentIndex.value = index;
      youtubeController.load(
        YoutubePlayer.convertUrlToId(playlist[index]["url"]!)!,
      );
    }
  }

  void playNext() {
    if (currentIndex.value < playlist.length - 1) {
      playVideo(currentIndex.value + 1);
    }
  }

  void playPrevious() {
    if (currentIndex.value > 0) {
      playVideo(currentIndex.value - 1);
    }
  }

  @override
  void onClose() {
    youtubeController.dispose();
    super.onClose();
  }
}
