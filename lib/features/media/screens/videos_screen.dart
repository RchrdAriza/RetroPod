import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/extensions/go_router_extensions.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/core/widgets/empty_state_widget.dart';
import 'package:retropod/features/device/models/device_action.dart';
import 'package:retropod/features/device/services/device_buttons_service_provider.dart';
import 'package:retropod/features/media/models/media_file_model.dart';
import 'package:retropod/features/media/services/media_files_service.dart';
import 'package:retropod/features/media/services/video_thumbnail_service.dart';
import 'package:retropod/features/status_bar/widgets/status_bar.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  List<MediaFileModel> get _videos =>
      ref
          .watch(mediaFilesServiceProvider)
          .value
          ?.where((f) => f.type == MediaFileType.video)
          .toList() ??
      [];

  @override
  void initState() {
    super.initState();
    ref.listenManual(deviceButtonsServiceProvider, _onDeviceAction);
  }

  Future<void> _onDeviceAction(_, DeviceAction? action) async {
    if (action == null) return;
    if (GoRouter.of(context).locationNamed != Routes.videos.name) return;
    final videos = _videos;
    switch (action) {
      case DeviceAction.menu:
        if (mounted) context.pop();
        break;
      case DeviceAction.rotateForward:
        if (_selectedIndex < videos.length) {
          setState(() => _selectedIndex++);
          _scrollToSelected();
        }
        break;
      case DeviceAction.rotateBackward:
        if (_selectedIndex > 0) {
          setState(() => _selectedIndex--);
          _scrollToSelected();
        }
        break;
      case DeviceAction.select:
        if (_selectedIndex < videos.length) {
          await context.pushNamed(
            Routes.videoPlayer.name,
            extra: videos[_selectedIndex],
          );
        } else {
          await _addFolder();
        }
        break;
      default:
        break;
    }
  }

  void _scrollToSelected() {
    const double tileH = 50.0;
    final double targetOffset = _selectedIndex * tileH;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  Future<void> _addFolder() async {
    final dir = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select Video Folder',
    );
    if (dir != null) {
      await ref.read(mediaFilesServiceProvider.notifier).addDirectory(dir);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(mediaFilesServiceProvider);
    final videos =
        videosAsync.value
            ?.where((f) => f.type == MediaFileType.video)
            .toList() ??
        [];

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.videos.title(context)),
          Expanded(
            child: videosAsync.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (_, _) => EmptyStateWidget(
                emptyDescription: context.localization.noVideosFound,
              ),
              data: (_) {
                if (videos.isEmpty) {
                  return Column(
                    children: [
                      Expanded(
                        child: EmptyStateWidget(
                          emptyDescription: context.localization.noVideosFound,
                        ),
                      ),
                      _buildAddFolderTile(isSelected: _selectedIndex == 0),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: CupertinoScrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: videos.length,
                          itemExtent: 50,
                          itemBuilder: (context, index) {
                            final video = videos[index];
                            final bool isSelected = _selectedIndex == index;
                            return GestureDetector(
                              onTap: () async {
                                setState(() => _selectedIndex = index);
                                await context.pushNamed(
                                  Routes.videoPlayer.name,
                                  extra: video,
                                );
                              },
                              child: Container(
                                color: isSelected
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemBackground
                                          .resolveFrom(context),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    _buildVideoThumbnail(video.path),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        video.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? CupertinoColors.white
                                              : CupertinoColors.label
                                                    .resolveFrom(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 12,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    _buildAddFolderTile(
                      isSelected: _selectedIndex == videos.length,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoPath) {
    final thumbnailAsync = ref.watch(videoThumbnailPathProvider(videoPath));
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: thumbnailAsync.when(
        data: (thumbnailPath) => Image.file(
          File(thumbnailPath),
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _FilmThumbnailPlaceholder(),
        ),
        loading: () => const _FilmThumbnailPlaceholder(),
        error: (_, _) => const _FilmThumbnailPlaceholder(),
      ),
    );
  }

  Widget _buildAddFolderTile({required bool isSelected}) {
    return GestureDetector(
      onTap: _addFolder,
      child: Container(
        height: 30,
        color: isSelected
            ? CupertinoColors.systemBlue
            : CupertinoColors.systemGroupedBackground.resolveFrom(context),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const Icon(CupertinoIcons.add, size: 14),
            const SizedBox(width: 6),
            Text(
              context.localization.addFolderButton,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilmThumbnailPlaceholder extends StatelessWidget {
  const _FilmThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      color: CupertinoColors.systemGrey5.resolveFrom(context),
      child: const Icon(
        CupertinoIcons.film,
        size: 18,
        color: CupertinoColors.systemGrey,
      ),
    );
  }
}
