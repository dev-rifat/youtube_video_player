import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../controller/offline_video_controller.dart';


class OfflineVideoPlayerScreen extends StatelessWidget {
  const OfflineVideoPlayerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final OfflineVideoController controller = Get.find();
    // Use GetBuilder because we call update() after initializing player
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Player')),
      body: GetBuilder<OfflineVideoController>(
        builder: (_) {
          final vc = controller.videoController;
          if (vc == null) {
            return const Center(child: Text('No video loaded'));
          }
          if (!vc.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              AspectRatio(
                aspectRatio: vc.value.aspectRatio,
                child: VideoPlayer(vc),
              ),
              const SizedBox(height: 8),
              VideoProgressIndicator(vc, allowScrubbing: true),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(vc.value.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (vc.value.isPlaying) {
                        vc.pause();
                      } else {
                        vc.play();
                      }
                      // update UI
                      controller.update();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      vc.pause();
                      vc.seekTo(Duration.zero);
                      controller.update();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

