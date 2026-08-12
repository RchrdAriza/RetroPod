import 'package:flutter/cupertino.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';

enum ClickWheelSize {
  small,
  medium,
  large;

  String title(BuildContext context) {
    switch (this) {
      case small:
        return context.localization.small;
      case medium:
        return context.localization.medium;
      case large:
        return context.localization.large;
    }
  }
}
