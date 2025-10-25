import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controller/offline_video_controller.dart';
import '../controller/video_player_controller.dart';
import 'offline_video_list.dart';

class YouTubePlaylistScreen extends StatelessWidget {
  YouTubePlaylistScreen({super.key});

  final YouTubeController controller = Get.put(YouTubeController());
  final OfflineVideoController offlineController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("YouTube Playlist"),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
               onTap: ()=>Get.to(() => OfflineVideoListScreen()),

                child: Text("Offline videos")),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoutubePlayerBuilder(
            onEnterFullScreen: () {},
            player: YoutubePlayer(
              controller: controller.youtubeController,
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

          Obx(
            () => offlineController.isDownloading.isTrue
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        print("called");
                        offlineController.downloadYouTubeVideo(
                          controller.playlist[controller
                              .currentIndex
                              .value]["title"]!,
                          controller.playlist[controller
                              .currentIndex
                              .value]["url"]!,
                        );
                      },
                      child: Column(
                        children: [
                          Icon(Icons.arrow_downward_rounded),
                          Text("Downloading... ${(offlineController.downloadProgress.value * 100).toStringAsFixed(0)}%"),
                        ],
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 10),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton(
          //       onPressed: controller.playPrevious,
          //       child: const Icon(Icons.skip_prev          const SizedBox(height: 10),ious),
          //     ),
          //     ElevatedButton(
          //       onPressed: controller.playNext,
          //       child: const Icon(Icons.skip_next),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 10),
          // const Padding(
          //   padding: EdgeInsets.all(12.0),
          //   child: Text(
          //     "Up Next",
          //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //   ),
          // ),
          _buildPlaylist(context),
        ],
      ),
    );
  }

  Widget _buildPlaylist(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,

        itemCount: controller.playlist.length,
        itemBuilder: (context, index) {
          final video = controller.playlist[index];
          final videoId = YoutubePlayer.convertUrlToId(video["url"]!) ?? "";

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: GestureDetector(
              onTap: () => controller.playVideo(index),
              child: Obx(
                () => Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: controller.currentIndex.value == index
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                        child: Image.network(
                          YoutubePlayer.getThumbnail(videoId: videoId),
                          height: 90,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          video["title"]!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
