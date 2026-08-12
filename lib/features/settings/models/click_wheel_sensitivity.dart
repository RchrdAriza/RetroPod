import 'package:flutter/cupertino.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';

enum ClickWheelSensitivity {
  veryLow,
  low,
  medium,
  high;

  String title(BuildContext context) {
    switch (this) {
      case veryLow:
        return context.localization.veryLow;
      case low:
        return context.localization.low;
      case medium:
        return context.localization.medium;
      case high:
        return context.localization.high;
    }
  }
}
