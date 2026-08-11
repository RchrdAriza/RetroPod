import 'package:classipod/core/constants/assets.dart';
import 'package:flutter/cupertino.dart';

enum DeviceSkin {
  classic,
  clearTech,
  clearTechCase,
  clearTechPurpleCase;

  static DeviceSkin fromName(String raw) {
    try {
      return DeviceSkin.values.byName(raw);
    } catch (_) {
      return DeviceSkin.classic;
    }
  }

  String title(BuildContext context) {
    switch (this) {
      case classic:
        return 'Classic';
      case clearTech:
        return 'Clear Tech';
      case clearTechCase:
        return 'Clear Tech Case';
      case clearTechPurpleCase:
        return 'Clear Tech Purple';
    }
  }

  /// Asset path of the skin image. Null means use the default gradient.
  String? get assetPath {
    switch (this) {
      case classic:
        return null;
      case clearTech:
        return Assets.clearTechSkin;
      case clearTechCase:
        return Assets.clearTechCaseSkin;
      case clearTechPurpleCase:
        return Assets.clearTechPurpleCaseSkin;
    }
  }

  /// How to fit the image. Cases with a built-in device body use [BoxFit.fill]
  /// so they stretch to the full screen. The bare circuit board uses
  /// [BoxFit.cover] so it tiles without empty strips.
  BoxFit get fit {
    switch (this) {
      case clearTechCase:
      case clearTechPurpleCase:
        return BoxFit.fill;
      default:
        return BoxFit.cover;
    }
  }
}
