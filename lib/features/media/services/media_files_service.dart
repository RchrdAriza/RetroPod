import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:retropod/features/media/models/media_file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kCustomMediaDirsKey = 'custom_media_directories';

const List<String> _kPhotoExtensions = [
  '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.heic', '.heif',
];

const List<String> _kVideoExtensions = [
  '.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.3gp', '.webm', '.m4v',
];

List<String> _defaultMediaDirs() {
  if (Platform.isAndroid) {
    return [
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/Download',
    ];
  } else if (Platform.isIOS) {
    return [];
  } else if (Platform.isLinux) {
    final home = Platform.environment['HOME'] ?? '/';
    return [
      p.join(home, 'Pictures'),
      p.join(home, 'Videos'),
      p.join(home, 'Downloads'),
      p.join(home, 'Desktop'),
    ];
  } else if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'] ?? 'C:\\Users\\User';
    return [
      p.join(userProfile, 'Pictures'),
      p.join(userProfile, 'Videos'),
      p.join(userProfile, 'Downloads'),
    ];
  } else if (Platform.isMacOS) {
    final home = Platform.environment['HOME'] ?? '/';
    return [
      p.join(home, 'Pictures'),
      p.join(home, 'Movies'),
      p.join(home, 'Downloads'),
    ];
  }
  return [];
}

Future<List<MediaFileModel>> _scanDirectories(List<String> dirs) async {
  final List<MediaFileModel> files = [];
  for (final dirPath in dirs) {
    final dir = Directory(dirPath);
    if (!await dir.exists()) continue;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final ext = p.extension(entity.path).toLowerCase();
        MediaFileType? type;
        if (_kPhotoExtensions.contains(ext)) {
          type = MediaFileType.photo;
        } else if (_kVideoExtensions.contains(ext)) {
          type = MediaFileType.video;
        }
        if (type == null) continue;
        final stat = await entity.stat();
        files.add(MediaFileModel(
          path: entity.path,
          type: type,
          name: p.basename(entity.path),
          dateModified: stat.modified,
        ));
      }
    } catch (_) {
      // Skip inaccessible directories
    }
  }
  files.sort((a, b) =>
      (b.dateModified ?? DateTime(0)).compareTo(a.dateModified ?? DateTime(0)));
  return files;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final mediaFilesServiceProvider = AsyncNotifierProvider<
    MediaFilesServiceNotifier, List<MediaFileModel>>(
  MediaFilesServiceNotifier.new,
);

class MediaFilesServiceNotifier
    extends AsyncNotifier<List<MediaFileModel>> {
  @override
  Future<List<MediaFileModel>> build() async {
    return _loadFiles();
  }

  Future<List<MediaFileModel>> _loadFiles() async {
    final allDirs = [..._defaultMediaDirs(), ...await _getCustomDirs()];
    return compute(_scanDirectories, allDirs);
  }

  Future<List<String>> _getCustomDirs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kCustomMediaDirsKey) ?? [];
  }

  Future<void> addDirectory(String dirPath) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_kCustomMediaDirsKey) ?? [];
    if (!current.contains(dirPath)) {
      current.add(dirPath);
      await prefs.setStringList(_kCustomMediaDirsKey, current);
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFiles);
  }

  Future<void> rescan() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFiles);
  }
}
