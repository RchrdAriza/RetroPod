import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retropod/core/providers/filtered_audio_files_provider.dart';

final artistNamesProvider = Provider<List<String>>((ref) {
  final artistNamesSet = <String>{};
  ref.watch(filteredAudioFilesProvider).requireValue.forEach((audioFile) {
    artistNamesSet.add(audioFile.getMainArtistName);
  });

  final artistNames = artistNamesSet.toList();
  artistNames.sort();

  return artistNames;
});
