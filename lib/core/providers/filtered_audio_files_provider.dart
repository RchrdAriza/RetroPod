import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retropod/core/models/music_metadata.dart';
import 'package:retropod/core/services/audio_files_service.dart';
import 'package:retropod/features/settings/controller/exclude_directories_controller.dart';

final filteredAudioFilesProvider =
    FutureProvider<UnmodifiableListView<MusicMetadata>>((ref) async {
      // Load the audio files metadata
      final audioFilesMetadata = await ref.refresh(
        audioFilesServiceProvider.future,
      );

      // Create Excluded Directories if they don't exist
      await ref
          .read(excludedDirectoriesProvider.notifier)
          .createDefaultDirectories();

      final excludedParentDirectories = ref
          .watch(excludedDirectoriesProvider)
          .where((excludeDirectoryModel) => excludeDirectoryModel.isExcluded)
          .map((excludedDirectoryModel) => excludedDirectoryModel.directoryPath)
          .toList();
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
