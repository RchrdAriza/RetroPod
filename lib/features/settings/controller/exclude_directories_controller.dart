import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:retropod/core/constants/constants.dart';
import 'package:retropod/core/services/audio_files_service.dart';
import 'package:retropod/features/settings/models/exclude_directory_model.dart';

final excludedDirectoriesProvider =
    NotifierProvider<ExcludeDirectoryNotifier, List<ExcludeDirectoryModel>>(
      ExcludeDirectoryNotifier.new,
    );

class ExcludeDirectoryNotifier extends Notifier<List<ExcludeDirectoryModel>> {
  /// System folders that contain notification-like sounds and are excluded
  /// from the library by default (e.g. Android's Ringtones folder).
  static const Set<String> _autoExcludedDirectoryNames = {
    'alarms',
    'notifications',
    'ringtones',
  };

  final Box<ExcludeDirectoryModel> _excludeDirectoryBox =
      Hive.box<ExcludeDirectoryModel>(Constants.excludedDirectoriesBoxName);

  @override
  List<ExcludeDirectoryModel> build() {
    return _excludeDirectoryBox.values.toList();
  }

  List<String> get _parentDirectoryPaths {
    return _excludeDirectoryBox.values
        .map((excludeDirectoryModel) => excludeDirectoryModel.directoryPath)
        .toList();
  }

  Future<void> createDefaultDirectories() async {
    final audioFiles = ref.read(audioFilesServiceProvider).requireValue;
    bool didChange = false;
    for (final musicMetadata in audioFiles) {
      final String? directoryPath = musicMetadata.parentDirectoryPath;
      if (directoryPath == null ||
          _parentDirectoryPaths.contains(directoryPath)) {
        continue;
      }
      final bool isAutoExcluded = _autoExcludedDirectoryNames.contains(
        p.basename(directoryPath).toLowerCase(),
      );
      await _excludeDirectoryBox.add(
        ExcludeDirectoryModel(
          directoryPath: directoryPath,
          isExcluded: isAutoExcluded,
        ),
      );
      didChange = true;
    }
    if (didChange) {
      state = _excludeDirectoryBox.values.toList();
    }
  }

  Future<void> toggleExcludeDirectory({
    required dynamic excludeDirectoryModelKey,
  }) async {
    if (excludeDirectoryModelKey == null) {
      return;
    } else {
      final excludeDirectory = _excludeDirectoryBox.get(
        excludeDirectoryModelKey,
      );
      if (excludeDirectory != null) {
        await _excludeDirectoryBox.put(
          excludeDirectoryModelKey,
          excludeDirectory.copyWith(isExcluded: !excludeDirectory.isExcluded),
        );
        state = _excludeDirectoryBox.values.toList();
      }
    }
  }
}
