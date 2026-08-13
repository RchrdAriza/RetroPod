import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retropod/core/models/music_metadata.dart';
import 'package:retropod/core/services/audio_files_service.dart';
import 'package:retropod/features/settings/controller/exclude_directories_controller.dart';

final filteredAudioFilesProvider =
    FutureProvider<UnmodifiableListView<MusicMetadata>>((ref) async {
      // Load the audio files metadata
      final audioFilesMetadata = await ref.watch(
        audioFilesServiceProvider.future,
      );

      final excludedParentDirectories = ref
          .watch(excludedDirectoriesProvider)
          .where((excludeDirectoryModel) => excludeDirectoryModel.isExcluded)
          .map((excludedDirectoryModel) => excludedDirectoryModel.directoryPath)
          .toSet();
      final List<MusicMetadata> filteredList = [];
      for (final audioFileMetadata in audioFilesMetadata) {
        if (!excludedParentDirectories.contains(
          audioFileMetadata.parentDirectoryPath,
        )) {
          filteredList.add(audioFileMetadata);
        }
      }

      return UnmodifiableListView(filteredList);
    });
