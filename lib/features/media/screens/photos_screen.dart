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
import 'package:retropod/features/status_bar/widgets/status_bar.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  List<MediaFileModel> get _photos => ref
      .watch(mediaFilesServiceProvider)
      .value
      ?.where((f) => f.type == MediaFileType.photo)
      .toList() ??
      [];

  @override
  void initState() {
    super.initState();
    ref.listenManual(deviceButtonsServiceProvider, _onDeviceAction);
  }

  Future<void> _onDeviceAction(_, DeviceAction? action) async {
    if (action == null) return;
    if (GoRouter.of(context).locationNamed != Routes.photos.name) return;
    final photos = _photos;
    switch (action) {
      case DeviceAction.menu:
        if (mounted) context.pop();
        break;
      case DeviceAction.rotateForward:
        if (_selectedIndex < photos.length) {
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
        if (_selectedIndex < photos.length) {
          await context.pushNamed(
            Routes.photoViewer.name,
            extra: {'photos': photos, 'index': _selectedIndex},
          );
        } else {
          // "Add Folder" selected
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
      dialogTitle: 'Select Photo/Video Folder',
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
    final photosAsync = ref.watch(mediaFilesServiceProvider);
    final photos = photosAsync.value
            ?.where((f) => f.type == MediaFileType.photo)
            .toList() ??
        [];

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.photos.title(context)),
          Expanded(
            child: photosAsync.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (_, _) => EmptyStateWidget(
                emptyDescription: context.localization.noPhotosFound,
              ),
              data: (_) {
                if (photos.isEmpty) {
                  return Column(
                    children: [
                      Expanded(
                        child: EmptyStateWidget(
                          emptyDescription: context.localization.noPhotosFound,
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
                          itemCount: photos.length,
                          itemExtent: 50,
                          itemBuilder: (context, index) {
                            final photo = photos[index];
                            final bool isSelected = _selectedIndex == index;
                            return GestureDetector(
                              onTap: () async {
                                setState(() => _selectedIndex = index);
                                await context.pushNamed(
                                  Routes.photoViewer.name,
                                  extra: {'photos': photos, 'index': index},
                                );
                              },
                              child: Container(
                                color: isSelected
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemBackground
                                        .resolveFrom(context),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: photo.isRemote
                                          ? Image.network(
                                              photo.path,
                                              width: 38,
                                              height: 38,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                CupertinoIcons.photo,
                                                size: 38,
                                              ),
                                            )
                                          : Image.file(
                                              File(photo.path),
                                              width: 38,
                                              height: 38,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                CupertinoIcons.photo,
                                                size: 38,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        photo.name,
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
                      isSelected: _selectedIndex == photos.length,
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
