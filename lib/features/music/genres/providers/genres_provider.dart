import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retropod/core/providers/filtered_audio_files_provider.dart';

final genresProvider = Provider<List<String>>((ref) {
  final genreNamesSet = <String>{};
  ref.watch(filteredAudioFilesProvider).requireValue.forEach((audioFile) {
    genreNamesSet.addAll(audioFile.genres);
  });

  final genreNames = genreNamesSet.toList();
  genreNames.sort();

  return genreNames;
});
