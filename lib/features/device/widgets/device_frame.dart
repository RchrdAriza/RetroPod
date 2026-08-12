import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retropod/core/constants/assets.dart';
import 'package:retropod/core/constants/keys.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/features/device/widgets/device_controls.dart';
import 'package:retropod/features/device/widgets/device_screen.dart';
import 'package:retropod/features/settings/controller/settings_preferences_controller.dart';
import 'package:retropod/features/settings/models/device_color.dart';

class DeviceFrame extends ConsumerWidget {
  final Widget child;

  const DeviceFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(
      settingsPreferencesControllerProvider.select((e) => e.deviceSkin),
    );

    final Widget background;
    if (skin.assetPath == null) {
      // Use the classic solid or gradient design based on active DeviceColor
      final DeviceColor deviceColor = ref.watch(
        settingsPreferencesControllerProvider.select((e) => e.deviceColor),
      );
      final deviceColorStyle = deviceColor.style;
      final solidFrameColor = deviceColorStyle.solidFrameColor;

      background = DecoratedBox(
        decoration: BoxDecoration(
          color: solidFrameColor,
          image: solidFrameColor == null
              ? DecorationImage(
                  image: const AssetImage(Assets.noiseImage),
                  fit: BoxFit.cover,
                  opacity: deviceColorStyle.noiseOpacity,
                )
              : null,
          gradient: solidFrameColor == null
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: deviceColorStyle.frameGradientColors,
                )
              : null,
        ),
        child: const SizedBox.expand(),
      );
    } else {
      // Use the image skin (stretched to fit using BoxFit.fill or specified fit)
      background = Image.asset(
        skin.assetPath!,
        fit: skin.fit,
      );
    }

    return ColoredBox(
      color: context.appBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background layout (Classic gradient or active tech skin) ──────
          background,

          // ── UI content centred over the skin ──────────────────────────────
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 960,
                  maxWidth: 450,
                ),
                child: Column(
                  children: [
                    DeviceScreen(key: deviceScreenGlobalKey, child: child),
                    const Spacer(flex: 2),
                    DeviceControls(key: deviceControlsGlobalKey),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
