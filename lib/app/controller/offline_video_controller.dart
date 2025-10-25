import 'dart:io';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class OfflineVideoController extends GetxController {
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  RxList<Map<String, String>> offlineVideos = <Map<String, String>>[].obs;

  VideoPlayerController? videoController;
  final Box box = Hive.box('offlineVideos');

  @override
  void onInit() {
    super.onInit();
    loadOfflineVideos();
  }

  void loadOfflineVideos() {
    offlineVideos.value = box.values
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
  }

  Future<String> _getFilePath(String title) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    String path = "${dir.path}/$safeTitle.mp4";
    if (await File(path).exists()) {
      path = "${dir.path}/${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.mp4";
    }
    return path;
  }

  Future<void> downloadYouTubeVideo(String title, String url) async {
    try {
      if (isDownloading.value) return;

      isDownloading.value = true;
      downloadProgress.value = 0.0;

      final yt = YoutubeExplode();

      final videoId = VideoId(url); // <-- এখানে
      final video = await yt.videos.get(videoId);
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.withHighestBitrate();
      final stream = yt.videos.streamsClient.get(streamInfo);

      final filePath = await _getFilePath(title);
      final file = File(filePath);
      final output = file.openWrite();

      int totalBytes = streamInfo.size.totalBytes;
      int received = 0;

      await for (final data in stream) {
        output.add(data);
        received += data.length;
        downloadProgress.value = received / totalBytes;
      }

      await output.close();
      yt.close();

      await box.add({
        'title': title,
        'path': filePath,
        'downloadedAt': DateTime.now().toIso8601String(),
      });

      loadOfflineVideos();
      Get.snackbar('Downloaded', '"$title" saved offline');
    } catch (e) {
      Get.snackbar('Download Error', e.toString());
      print("Download Error: $e");
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }


  Future<void> playOfflineVideo(String filePath) async {
    if (videoController != null) {
      await videoController!.pause();
      await videoController!.dispose();
    }

    final file = File(filePath);
    if (!await file.exists()) {
      Get.snackbar('Error', 'File not found');
      return;
    }

    videoController = VideoPlayerController.file(file);
    await videoController!.initialize();
    videoController!.setLooping(false);
    await videoController!.play();
    update(); // notify GetBuilder listeners
  }

  Future<void> deleteOfflineVideo(int index) async {
    try {
      final item = offlineVideos[index];
      final path = item['path']!;
      final file = File(path);
      if (await file.exists()) await file.delete();

      final keys = box.keys.toList();
      for (final key in keys) {
        final v = box.get(key);
        if (v is Map && v['path'] == path) {
          await box.delete(key);
          break;
        }
      }

      loadOfflineVideos();
      Get.snackbar('Deleted', 'Video removed');
    } catch (e) {
      Get.snackbar('Delete Error', e.toString());
    }
  }

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }
}
