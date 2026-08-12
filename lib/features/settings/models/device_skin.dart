import 'package:classipod/core/constants/assets.dart';
import 'package:flutter/cupertino.dart';

enum DeviceSkin {
  classic,
  clearTech,
  clearTechCase,
  clearTechPurpleCase,
  glassCase,
  sticker1Case,
  sticker2Case;

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
      case glassCase:
        return 'Glass Case';
      case sticker1Case:
        return 'Stickers 1';
      case sticker2Case:
        return 'Stickers 2';
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
      case glassCase:
        return Assets.glassCaseSkin;
      case sticker1Case:
        return Assets.sticker1Skin;
      case sticker2Case:
        return Assets.sticker2Skin;
    }
  }

  /// How to fit the image. Cases with a built-in device body use [BoxFit.fill]
  /// so they stretch to the full screen. The bare circuit board uses
  /// [BoxFit.cover] so it tiles without empty strips.
  BoxFit get fit {
    switch (this) {
      case clearTechCase:
      case clearTechPurpleCase:
      case sticker1Case:
      case sticker2Case:
      case glassCase:
        return BoxFit.fill;
      default:
        return BoxFit.cover;
    }
  }
}
