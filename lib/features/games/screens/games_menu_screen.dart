import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/core/widgets/display_list_tile.dart';
import 'package:retropod/features/custom_screen_elements/custom_screen.dart';
import 'package:retropod/features/status_bar/widgets/status_bar.dart';

enum _GamesListDisplayItems {
  brick,
  musicQuiz;

  String title(BuildContext context) {
    switch (this) {
      case brick:
        return context.localization.brickGameTitle;
      case musicQuiz:
        return context.localization.musicQuizGameTitle;
    }
  }
}

class GamesMenuScreen extends ConsumerStatefulWidget {
  const GamesMenuScreen({super.key});

  @override
  ConsumerState<GamesMenuScreen> createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends ConsumerState<GamesMenuScreen>
    with CustomScreen {
  @override
  String get routeName => Routes.extras.name;

  @override
  List<_GamesListDisplayItems> get displayItems => _GamesListDisplayItems.values;

  @override
  Future<void> onSelectPressed() =>
      _navigateToGame(_GamesListDisplayItems.values[selectedDisplayItem]);

  Future<void> _navigateToGame(_GamesListDisplayItems game) async {
    setState(() => selectedDisplayItem = displayItems.indexOf(game));
    switch (game) {
      case _GamesListDisplayItems.brick:
        await context.pushNamed(Routes.brick.name);
        break;
      case _GamesListDisplayItems.musicQuiz:
        await context.pushNamed(Routes.musicQuiz.name);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.extras.title(context)),
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
                  onTap: () async => _navigateToGame(displayItems[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
