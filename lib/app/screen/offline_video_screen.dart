import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/offline_video_controller.dart';
import 'offline_video_player.dart';

class OfflineVideoListScreen extends StatelessWidget {
  const OfflineVideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OfflineVideoController>();
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Videos")),
      body: Obx(() {
        final list = controller.offlineVideos;
        if (list.isEmpty) return const Center(child: Text("No Offline Videos"));

        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final video = list[index];
            return ListTile(
              title: Text(video['title']!),
              subtitle: Text(video['path']!),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      await controller.playOfflineVideo(video['path']!);
                      Get.to(() => OfflineVideoPlayerScreen());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.deleteOfflineVideo(index),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
