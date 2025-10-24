import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controller/video_player_controller.dart';

class YouTubePlaylistScreen extends StatelessWidget {
  YouTubePlaylistScreen({super.key});

  final YouTubeController controller = Get.put(YouTubeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YouTube Playlist"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoutubePlayerBuilder(
            player: YoutubePlayer(controller: controller.youtubeController,
              showVideoProgressIndicator: true,
              //
            ),

            builder: (context, player) {
              return player;
            },
          ),
          const SizedBox(height: 10),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                controller.playlist[controller.currentIndex.value]["title"]!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                controller.playlist[controller.currentIndex.value]["channel"]!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: controller.playPrevious,
                child: const Icon(Icons.skip_previous),
              ),
              ElevatedButton(
                onPressed: controller.playNext,
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
          _buildPlaylist(),
        ],
      ),
    );
  }

  Widget _buildPlaylist() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.playlist.length,
        itemBuilder: (context, index) {
          final video = controller.playlist[index];
          final videoId = YoutubePlayer.convertUrlToId(video["url"]!) ?? "";

          return GestureDetector(
            onTap: () => controller.playVideo(index),
            child: Obx(
              () => Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: controller.currentIndex.value == index
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
                      video["title"]!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
