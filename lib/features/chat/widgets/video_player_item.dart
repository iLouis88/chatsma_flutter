import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isPlay = false;
  bool initialized = false;
  double aspectRatioValue = 1/1;

  void toggleAspectRatio() {
    setState(() {
      aspectRatioValue = aspectRatioValue == 1/1 ? 9/16 : 16/9 ;
    });
  }

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        videoPlayerController.setVolume(1);
        setState(() {
          initialized = true;
        });
      });
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: true,
      showControls: true,
      fullScreenByDefault: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialized ?
      AspectRatio(
      aspectRatio: aspectRatioValue,
      child: Stack(
        children: [
          Chewie(controller: chewieController),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => toggleAspectRatio(),
              icon: const Icon(Icons.change_circle),
            ),

          ),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () {
                if(isPlay) {
                  videoPlayerController.pause();
                } else {
                  videoPlayerController.play();
                }
                setState(() {
                  isPlay = !isPlay;
                });
              },
              icon: Icon(
                isPlay ? Icons.pause_circle : Icons.play_circle,
              ),
              color: Colors.white24,
            ),
          ),
        ],
      ),
    )  : const Center(
      child: CircularProgressIndicator(),
    );
  }
}