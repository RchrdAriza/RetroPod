import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter;

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
    _currentIndex = widget.photos.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.photos.length - 1);
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
    if (widget.photos.isEmpty) {
      return const CupertinoPageScaffold(
        child: Column(
          children: [
            StatusBar(title: ''),
            Expanded(
              child: Center(
                child: Icon(
                  CupertinoIcons.photo,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final photo = widget.photos[_currentIndex];
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: '${_currentIndex + 1} / ${widget.photos.length}'),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return _ZoomablePhoto(photo: widget.photos[index]);
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

class _ZoomablePhoto extends StatefulWidget {
  final MediaFileModel photo;

  const _ZoomablePhoto({required this.photo});

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  AnimationController? _zoomAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.001;
    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
  }

  void _handleDoubleTap() {
    final scale = _controller.value.getMaxScaleOnAxis();
    _animateZoom(scale > 1.2 ? 1.0 : 3.0);
  }

  void _animateZoom(double targetScale) {
    final size = context.size;
    if (size == null) return;
    final center = Offset(size.width / 2, size.height / 2);
    final end = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(targetScale, targetScale, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    _zoomAnimation?.dispose();
    final animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _zoomAnimation = animation;
    final tween = Matrix4Tween(
      begin: _controller.value,
      end: end,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    animation.addListener(() => _controller.value = tween.value);
    unawaited(animation.forward());
  }

  @override
  void dispose() {
    _zoomAnimation?.dispose();
    _controller.removeListener(_onTransformationChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider image = widget.photo.isRemote
        ? NetworkImage(widget.photo.path)
        : FileImage(File(widget.photo.path));
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Image(
            image: image,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: CupertinoColors.black),
          ),
        ),
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 1.0,
            maxScale: 5.0,
            panEnabled: _isZoomed,
            child: Image(
              image: image,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  CupertinoIcons.photo,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
