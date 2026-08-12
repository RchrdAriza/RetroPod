import 'package:flutter/cupertino.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';

enum VolumeMode {
  app,
  system;

  String title(BuildContext context) {
    switch (this) {
      case app:
        return context.localization.appVolumeMode;
      case system:
        return context.localization.systemVolumeMode;
    }
  }
}
