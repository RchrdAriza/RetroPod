import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retropod/features/media/models/media_file_model.dart';
import 'package:retropod/features/media/screens/videos_screen.dart';
import 'package:retropod/features/media/services/media_files_service.dart';
import 'package:retropod/features/media/services/video_thumbnail_service.dart';
import 'package:retropod/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final videos = [
    const MediaFileModel(
      path: '/storage/emulated/0/Movies/first.mp4',
      type: MediaFileType.video,
      name: 'First Video',
    ),
    const MediaFileModel(
      path: '/storage/emulated/0/Movies/second.mp4',
      type: MediaFileType.video,
      name: 'Second Video',
    ),
  ];

  Future<Widget> buildVideosScreen({
    required List<MediaFileModel> files,
    required Future<String> Function(String videoPath) thumbnailLoader,
  }) async {
    final container = ProviderContainer(
      overrides: [
        mediaFilesServiceProvider.overrideWith(
          () => _FakeMediaFilesNotifier(files),
        ),
        videoThumbnailPathProvider.overrideWith(
          (ref, videoPath) => thumbnailLoader(videoPath),
        ),
      ],
    );
    return UncontrolledProviderScope(
      container: container,
      child: const CupertinoApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: VideosScreen(),
      ),
    );
  }

  testWidgets('shows video thumbnails in the list', (tester) async {
    final thumbnailPath =
        '${Directory.current.path}/test/test_files/RetroPod/thumbnails/'
        'FadedbyAlanWalker.jpg';
    await tester.pumpWidget(
      await buildVideosScreen(
        files: videos,
        thumbnailLoader: (_) async => thumbnailPath,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First Video'), findsOneWidget);
    expect(find.text('Second Video'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
  });

  testWidgets('shows film placeholder when thumbnail generation fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      await buildVideosScreen(
        files: videos,
        thumbnailLoader: (_) async => throw StateError('failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First Video'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.film), findsNWidgets(2));
    expect(find.byType(Image), findsNothing);
  });
}

class _FakeMediaFilesNotifier extends MediaFilesServiceNotifier {
  final List<MediaFileModel> files;

  _FakeMediaFilesNotifier(this.files);

  @override
  Future<List<MediaFileModel>> build() async => files;
}
