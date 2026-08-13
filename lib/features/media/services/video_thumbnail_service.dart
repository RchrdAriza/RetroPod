import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const int _kThumbnailMaxDimension = 120;
const Duration _kThumbnailTimePosition = Duration(seconds: 1);
const int _kThumbnailQuality = 70;

final videoThumbnailCacheDirectoryProvider = FutureProvider<Directory>((
  ref,
) async {
  final supportDir = await getApplicationSupportDirectory();
  return Directory(p.join(supportDir.path, 'video_thumbnails'));
});

final videoThumbnailPathProvider = FutureProvider.family<String, String>((
  ref,
  videoPath,
) async {
  final Directory cacheDir = await ref.read(
    videoThumbnailCacheDirectoryProvider.future,
  );
  return generateVideoThumbnail(videoPath, cacheDir);
});

Future<String> generateVideoThumbnail(
  String videoPath,
  Directory cacheDir,
) async {
  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }
  final outputFile = _thumbnailFileFor(cacheDir, videoPath);
  if (await outputFile.exists()) {
    return outputFile.path;
  }

  final String? generated = await _generateWithPlugin(videoPath, outputFile);
  if (generated != null) return generated;

  final String? ffmpegGenerated = await _generateWithFfmpeg(
    videoPath,
    outputFile,
  );
  if (ffmpegGenerated != null) return ffmpegGenerated;

  throw StateError('Could not generate a thumbnail for "$videoPath".');
}

Future<String?> _generateWithPlugin(String videoPath, File outputFile) async {
  try {
    return await FlutterVideoThumbnailPlus.thumbnailFile(
      video: videoPath,
      thumbnailPath: outputFile.path,
      imageFormat: ImageFormat.jpeg,
      maxWidth: _kThumbnailMaxDimension,
      maxHeight: _kThumbnailMaxDimension,
      timeMs: _kThumbnailTimePosition.inMilliseconds,
      quality: _kThumbnailQuality,
    );
  } on MissingPluginException {
    return null;
  } catch (_) {
    return null;
  }
}

Future<String?> _generateWithFfmpeg(String videoPath, File outputFile) async {
  final platform = Platform.operatingSystem;
  if (platform != 'linux' && platform != 'windows' && platform != 'macos') {
    return null;
  }
  try {
    const filter =
        'scale=$_kThumbnailMaxDimension:$_kThumbnailMaxDimension:'
        'force_original_aspect_ratio=decrease,pad=$_kThumbnailMaxDimension:'
        '$_kThumbnailMaxDimension:(ow-iw)/2:(oh-ih)/2:black';
    final result = await Process.run('ffmpeg', [
      '-i',
      videoPath,
      '-ss',
      _kThumbnailTimePosition.inSeconds.toString(),
      '-vframes',
      '1',
      '-vf',
      filter,
      '-q:v',
      '5',
      '-f',
      'image2',
      '-y',
      outputFile.path,
    ]);
    if (result.exitCode != 0) return null;
    return await outputFile.exists() ? outputFile.path : null;
  } catch (_) {
    return null;
  }
}

File _thumbnailFileFor(Directory cacheDir, String videoPath) {
  final sanitized = videoPath.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  final name = sanitized.length > 120
      ? sanitized.substring(sanitized.length - 120)
      : sanitized;
  return File(p.join(cacheDir.path, '$name.jpg'));
}
