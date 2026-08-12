import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/extensions/go_router_extensions.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/features/device/models/device_action.dart';
import 'package:retropod/features/device/services/device_buttons_service_provider.dart';
import 'package:retropod/features/media/models/media_file_model.dart';
import 'package:retropod/features/status_bar/widgets/status_bar.dart';

class PhotoViewerScreen extends ConsumerStatefulWidget {
  final List<MediaFileModel> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    ref.listenManual(deviceButtonsServiceProvider, _onDeviceAction);
  }

  Future<void> _onDeviceAction(_, DeviceAction? action) async {
    if (action == null) return;
    if (GoRouter.of(context).locationNamed != Routes.photoViewer.name) return;
    switch (action) {
      case DeviceAction.menu:
        if (mounted) context.pop();
        break;
      case DeviceAction.rotateForward:
      case DeviceAction.seekForward:
        _next();
        break;
      case DeviceAction.rotateBackward:
      case DeviceAction.seekBackward:
        _prev();
        break;
      default:
        break;
    }
  }

  void _next() {
    if (_currentIndex < widget.photos.length - 1) {
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(
            title:
                '${_currentIndex + 1} / ${widget.photos.length}',
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return Image.file(
                  File(widget.photos[index].path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 48,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                );
              },
            ),
          ),
          // Filename bar
          Container(
            width: double.infinity,
            color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              photo.name,
              style: const TextStyle(
                fontSize: 9,
                color: CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
