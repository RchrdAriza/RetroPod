import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:retropod/core/constants/constants.dart';
import 'package:retropod/core/models/music_metadata.dart';
import 'package:retropod/core/providers/device_directory_provider.dart';
import 'package:retropod/core/providers/shared_preferences_with_cache_provider.dart';
import 'package:retropod/features/music/playlist/models/playlist_model.dart';
import 'package:retropod/features/settings/controller/settings_preferences_controller.dart';
import 'package:retropod/features/settings/models/exclude_directory_model.dart';
import 'package:retropod/hive/hive_registrar.g.dart';

final appStartupControllerProvider = FutureProvider<void>((ref) async {
  await Future.wait([
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...[
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
      JustAudioBackground.init(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
        androidNotificationChannelName: 'RetroPod Audio playback',
        androidNotificationChannelDescription:
            'Notification to control the currently playing music files',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'drawable/ic_stat_name',
      ),
    ],
    if (!kIsWeb) ref.watch(deviceDirectoryProvider.future),
    ref.watch(sharedPreferencesWithCacheProvider.future),
    Hive.initFlutter("RetroPod"),
  ]);
  Hive.registerAdapters();
  await Hive.openBox<MusicMetadata>(Constants.metadataBoxName);
  await Hive.openBox<PlaylistModel>(Constants.playlistBoxName);
  await Hive.openBox<ExcludeDirectoryModel>(
    Constants.excludedDirectoriesBoxName,
  );
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    JustAudioMediaKit.ensureInitialized();
    JustAudioMediaKit.title = 'RetroPod';
  }
  ref
      .read(settingsPreferencesControllerProvider.notifier)
      .setAudioSource(isOnlineAudioSource: kIsWeb);
  unawaited(
    ref.read(settingsPreferencesControllerProvider.notifier).setSystemUiMode(),
  );
});
