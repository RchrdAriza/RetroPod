import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retropod/features/media/services/video_thumbnail_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory cacheDir;

  setUp(() {
    cacheDir = Directory.systemTemp.createTempSync('retropod_thumbnails_test');
  });

  tearDown(() {
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  });

  String expectedCachePath(String videoPath) {
    final sanitized = videoPath.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final name = sanitized.length > 120
        ? sanitized.substring(sanitized.length - 120)
        : sanitized;
    return '${cacheDir.path}/$name.jpg';
  }

  test('throws when no thumbnail can be generated', () async {
    final missingVideo = File('${cacheDir.path}/missing.mp4');
    await expectLater(
      generateVideoThumbnail(missingVideo.path, cacheDir),
      throwsStateError,
    );
  });

  test('returns the cached thumbnail without regenerating', () async {
    final video = File('${cacheDir.path}/sample.mov');
    final cachedFile = File(expectedCachePath(video.path));
    cachedFile.createSync(recursive: true);
    await cachedFile.writeAsString('fake thumbnail');

    final result = await generateVideoThumbnail(video.path, cacheDir);

    expect(result, cachedFile.path);
    expect(cachedFile.readAsStringSync(), 'fake thumbnail');
  });

  test('generates a thumbnail via ffmpeg when available', () async {
    final bool ffmpegAvailable = await _canRunFfmpeg();
    if (!ffmpegAvailable) {
      markTestSkipped('ffmpeg is not available on this machine');
      return;
    }

    final video = File('${cacheDir.path}/sample.mp4');
    final bool videoCreated = await _createSampleVideo(video.path);
    if (!videoCreated) {
      markTestSkipped('could not generate a sample video');
      return;
    }

    final result = await generateVideoThumbnail(video.path, cacheDir);

    expect(result, expectedCachePath(video.path));
    expect(File(result).existsSync(), isTrue);
    expect(File(result).lengthSync(), greaterThan(0));
  });
}

Future<bool> _canRunFfmpeg() async {
  try {
    final result = await Process.run('ffmpeg', ['-version']);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<bool> _createSampleVideo(String path) async {
  try {
    final result = await Process.run('ffmpeg', [
      '-f',
      'lavfi',
      '-i',
      'testsrc=size=160x90:rate=10',
      '-t',
      '2',
      '-pix_fmt',
      'yuv420p',
      '-y',
      path,
    ]);
    return result.exitCode == 0 && File(path).existsSync();
  } catch (_) {
    return false;
  }
}
