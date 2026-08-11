import 'package:classipod/core/constants/app_palette.dart';
import 'package:classipod/core/extensions/build_context_extensions.dart';
import 'package:classipod/core/navigation/routes.dart';
import 'package:classipod/features/custom_screen_elements/custom_screen.dart';
import 'package:classipod/features/settings/controller/settings_preferences_controller.dart';
import 'package:classipod/features/settings/models/device_skin.dart';
import 'package:classipod/features/status_bar/widgets/status_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SkinSelectionScreen extends ConsumerStatefulWidget {
  const SkinSelectionScreen({super.key});

  @override
  ConsumerState<SkinSelectionScreen> createState() =>
      _SkinSelectionScreenState();
}

class _SkinSelectionScreenState extends ConsumerState<SkinSelectionScreen>
    with CustomScreen {
  @override
  String get routeName => Routes.deviceSkin.name;

  @override
  List<DeviceSkin> get displayItems => DeviceSkin.values;

  @override
  Future<void> onSelectPressed() => _selectSkin(selectedDisplayItem);

  Future<void> _selectSkin(int index) async {
    setState(() => selectedDisplayItem = index);
    await ref
        .read(settingsPreferencesControllerProvider.notifier)
        .setSkin(displayItems[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentSkin = ref.watch(
      settingsPreferencesControllerProvider.select((e) => e.deviceSkin),
    );

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.deviceSkin.title(context)),
          Flexible(
            child: CupertinoScrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: displayItems.length,
                prototypeItem: _SkinOptionTile(
                  skin: displayItems.first,
                  isSelected: false,
                  isCurrent: false,
                  onTap: () {},
                ),
                itemBuilder: (context, index) {
                  final skin = displayItems[index];
                  final isSelected = selectedDisplayItem == index;
                  final isCurrent = currentSkin == skin;
                  return _SkinOptionTile(
                    skin: skin,
                    isSelected: isSelected,
                    isCurrent: isCurrent,
                    onTap: () async => _selectSkin(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkinOptionTile extends StatelessWidget {
  final DeviceSkin skin;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _SkinOptionTile({
    required this.skin,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 30,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    top: BorderSide(
                      color: AppPalette.selectedTileTopBorderColor,
                    ),
                    bottom: BorderSide(
                      color: AppPalette.selectedTileBottomBorderColor,
                    ),
                  )
                : null,
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppPalette.selectedTileGradientColor1,
                      AppPalette.selectedTileGradientColor2,
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                // Mini skin preview thumbnail
                _SkinThumbnail(skin: skin),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    skin.title(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? CupertinoColors.white
                          : context.appPrimaryTextColor,
                    ),
                    maxLines: 1,
                  ),
                ),
                if (isCurrent)
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 16,
                    color: isSelected
                        ? CupertinoColors.white
                        : context.appPrimaryTextColor,
                  ),
                if (isSelected)
                  const Icon(
                    CupertinoIcons.right_chevron,
                    color: CupertinoColors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkinThumbnail extends StatelessWidget {
  final DeviceSkin skin;

  const _SkinThumbnail({required this.skin});

  @override
  Widget build(BuildContext context) {
    final assetPath = skin.assetPath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 18,
        height: 18,
        child: assetPath != null
            ? Image.asset(
                assetPath,
                fit: BoxFit.cover,
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppPalette.lightDeviceFrameGradientColor1,
                      AppPalette.lightDeviceFrameGradientColor2,
                    ],
                  ),
                  border: Border.all(
                    color: AppPalette.lightDeviceControlBorderColor,
                  ),
                ),
              ),
      ),
    );
  }
}
