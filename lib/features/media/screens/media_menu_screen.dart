import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/core/widgets/display_list_tile.dart';
import 'package:retropod/features/custom_screen_elements/custom_screen.dart';
import 'package:retropod/features/status_bar/widgets/status_bar.dart';

enum _MediaListDisplayItems {
  photos,
  videos;

  String title(BuildContext context) {
    switch (this) {
      case photos:
        return context.localization.photosMenuTitle;
      case videos:
        return context.localization.videosMenuTitle;
    }
  }
}

class MediaMenuScreen extends ConsumerStatefulWidget {
  const MediaMenuScreen({super.key});

  @override
  ConsumerState<MediaMenuScreen> createState() => _MediaMenuScreenState();
}

class _MediaMenuScreenState extends ConsumerState<MediaMenuScreen>
    with CustomScreen {
  @override
  String get routeName => Routes.media.name;

  @override
  List<_MediaListDisplayItems> get displayItems => _MediaListDisplayItems.values;

  @override
  Future<void> onSelectPressed() =>
      _navigateToScreen(_MediaListDisplayItems.values[selectedDisplayItem]);

  Future<void> _navigateToScreen(_MediaListDisplayItems item) async {
    setState(() => selectedDisplayItem = displayItems.indexOf(item));
    switch (item) {
      case _MediaListDisplayItems.photos:
        await context.pushNamed(Routes.photos.name);
        break;
      case _MediaListDisplayItems.videos:
        await context.pushNamed(Routes.videos.name);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.media.title(context)),
          Flexible(
            child: CupertinoScrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: displayItems.length,
                prototypeItem: const DisplayListTile(
                  text: '',
                  isSelected: false,
                ),
                itemBuilder: (context, index) => DisplayListTile(
                  text: displayItems[index].title(context),
                  isSelected: selectedDisplayItem == index,
                  onTap: () async => _navigateToScreen(displayItems[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
