import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/extensions/go_router_extensions.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/features/device/models/device_action.dart';
import 'package:retropod/features/device/services/device_buttons_service_provider.dart';
import 'package:retropod/features/media/models/media_file_model.dart';
import 'package:retropod/features/status_bar/widgets/status_bar.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final MediaFileModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    ref.listenManual(deviceButtonsServiceProvider, _onDeviceAction);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final controller = VideoPlayerController.file(File(widget.video.path));
    _controller = controller;
    await controller.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
      await controller.play();
    }
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  Future<void> _onDeviceAction(_, DeviceAction? action) async {
    if (action == null) return;
    if (GoRouter.of(context).locationNamed != Routes.videoPlayer.name) return;
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    switch (action) {
      case DeviceAction.menu:
        await c.pause();
        if (mounted) context.pop();
        break;
      case DeviceAction.playPause:
      case DeviceAction.select:
        _showControlsTemporarily();
        if (c.value.isPlaying) {
          await c.pause();
        } else {
          await c.play();
        }
        break;
      case DeviceAction.rotateForward:
        _showControlsTemporarily();
        final newPos = c.value.position + const Duration(seconds: 5);
        await c.seekTo(newPos < c.value.duration ? newPos : c.value.duration);
        break;
      case DeviceAction.rotateBackward:
        _showControlsTemporarily();
        final newPos = c.value.position - const Duration(seconds: 5);
        await c.seekTo(newPos > Duration.zero ? newPos : Duration.zero);
        break;
      default:
        break;
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: widget.video.name),
          Expanded(
            child: _isInitialized && _controller != null
                ? GestureDetector(
                    onTap: () {
                      final c = _controller!;
                      _showControlsTemporarily();
                      if (c.value.isPlaying) {
                        c.pause();
                      } else {
                        c.play();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Video
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                        // Controls overlay
                        if (_showControls)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: _controller!,
                              builder: (_, value, _) {
                                final position = value.position;
                                final duration = value.duration;
                                final progress = duration.inMilliseconds > 0
                                    ? position.inMilliseconds /
                                        duration.inMilliseconds
                                    : 0.0;
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xCC000000),
                                        Color(0x00000000),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Play/pause icon
                                      Icon(
                                        value.isPlaying
                                            ? CupertinoIcons.pause_fill
                                            : CupertinoIcons.play_fill,
                                        color: CupertinoColors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      // Progress bar
                                      LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        backgroundColor:
                                            CupertinoColors.systemGrey4,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                          CupertinoColors.white,
                                        ),
                                        minHeight: 2,
                                      ),
                                      const SizedBox(height: 2),
                                      // Time
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(position),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(duration),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  )
                : const Center(child: CupertinoActivityIndicator()),
          ),
        ],
      ),
    );
  }
}
