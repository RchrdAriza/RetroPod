import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/constants/keys.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/models/music_metadata.dart';
import 'package:retropod/core/navigation/page_not_found_screen.dart';
import 'package:retropod/features/app_startup/screens/splash_screen.dart';
import 'package:retropod/features/custom_screen_elements/custom_scroll_behavior.dart';
import 'package:retropod/features/custom_screen_elements/options_modal_page.dart';
import 'package:retropod/features/device/widgets/device_frame.dart';
import 'package:retropod/features/games/screens/brick_game_screen.dart';
import 'package:retropod/features/games/screens/games_menu_screen.dart';
import 'package:retropod/features/games/screens/music_quiz_screen.dart';
import 'package:retropod/features/media/models/media_file_model.dart';
import 'package:retropod/features/media/screens/media_menu_screen.dart';
import 'package:retropod/features/media/screens/photo_viewer_screen.dart';
import 'package:retropod/features/media/screens/photos_screen.dart';
import 'package:retropod/features/media/screens/video_player_screen.dart';
import 'package:retropod/features/media/screens/videos_screen.dart';
import 'package:retropod/features/menu/screens/main_menu_screen.dart';
import 'package:retropod/features/menu/screens/music_menu_screen.dart';
import 'package:retropod/features/menu/screens/split_screen_placeholder.dart';
import 'package:retropod/features/music/album/models/album_model.dart';
import 'package:retropod/features/music/album/screens/album_more_options_modal.dart';
import 'package:retropod/features/music/album/screens/album_selection_screen.dart';
import 'package:retropod/features/music/album/screens/album_songs_screen.dart';
import 'package:retropod/features/music/artists/screens/artist_albums_screen.dart';
import 'package:retropod/features/music/artists/screens/artists_selection_screen.dart';
import 'package:retropod/features/music/cover_flow/screens/cover_flow_album_selection_screen.dart';
import 'package:retropod/features/music/cover_flow/screens/cover_flow_screen.dart';
import 'package:retropod/features/music/genres/screens/genre_songs_screen.dart';
import 'package:retropod/features/music/genres/screens/genres_screen.dart';
import 'package:retropod/features/music/playlist/screens/playlist_rename_screen.dart';
import 'package:retropod/features/music/playlist/screens/playlist_songs_more_options_modal.dart';
import 'package:retropod/features/music/playlist/screens/playlist_songs_screen.dart';
import 'package:retropod/features/music/playlist/screens/playlists_screen.dart';
import 'package:retropod/features/music/search/screens/search_more_options_modal.dart';
import 'package:retropod/features/music/search/screens/search_screen.dart';
import 'package:retropod/features/music/songs/screens/songs_more_options_modal.dart';
import 'package:retropod/features/music/songs/screens/songs_screen.dart';
import 'package:retropod/features/now_playing/screen/now_playing_more_options_modal.dart';
import 'package:retropod/features/now_playing/screen/now_playing_screen.dart';
import 'package:retropod/features/settings/controller/settings_preferences_controller.dart';
import 'package:retropod/features/settings/screens/about_screen.dart';
import 'package:retropod/features/settings/screens/device_color_selection_screen.dart';
import 'package:retropod/features/settings/screens/exclude_directories_screen.dart';
import 'package:retropod/features/settings/screens/language_selection_screen.dart';
import 'package:retropod/features/settings/screens/settings_preferences_screen.dart';
import 'package:retropod/features/settings/screens/skin_selection_screen.dart';
import 'package:retropod/features/sleep_timer/screens/sleep_timer_screen.dart';

enum Routes {
  splash,
  menu,
  settings,
  about,
  language,
  deviceColor,
  deviceSkin,
  excludeDirectories,
  nowPlaying,
  nowPlayingMoreOptions,
  sleepTimer,
  musicMenu,
  coverFlow,
  coverFlowSelection,
  artists,
  artistAlbums,
  artistAlbumsMoreOptions,
  albums,
  albumMoreOptions,
  albumSongs,
  albumSongsMoreOptions,
  playlists,
  playlistSongs,
  playlistRename,
  playlistSongsMoreOptions,
  songs,
  songsMoreOptions,
  genres,
  genreSongs,
  genresSongsMoreOptions,
  search,
  searchMoreOptions,
  // New features
  extras,
  brick,
  musicQuiz,
  media,
  photos,
  photoViewer,
  videos,
  videoPlayer;

  @override
  String toString() {
    return "/$name";
  }

  String title(BuildContext context) {
    switch (this) {
      case splash:
        return "";
      case menu:
        return context.localization.menuScreenTitle;
      case settings:
        return context.localization.settingsScreenTitle;
      case about:
        return context.localization.aboutScreenTitle;
      case language:
        return context.localization.languageScreenTitle;
      case deviceColor:
        return context.localization.deviceColorSettingTitle;
      case deviceSkin:
        return 'Skins';
      case excludeDirectories:
        return context.localization.excludeDirectoriesScreenTitle;
      case nowPlaying:
        return context.localization.nowPlayingScreenTitle;
      case nowPlayingMoreOptions:
        return context.localization.nowPlayingScreenTitle;
      case sleepTimer:
        return context.localization.sleepTimerTitle;
      case musicMenu:
        return context.localization.musicMenuScreenTitle;
      case coverFlow:
        return context.localization.coverFlowScreenTitle;
      case coverFlowSelection:
        return context.localization.coverFlowScreenTitle;
      case artists:
        return context.localization.artistsScreenTitle;
      case artistAlbums:
        return context.localization.artistsScreenTitle;
      case artistAlbumsMoreOptions:
        return context.localization.artistsScreenTitle;
      case albums:
        return context.localization.albumsScreenTitle;
      case albumMoreOptions:
        return context.localization.albumsScreenTitle;
      case albumSongs:
        return context.localization.albumsScreenTitle;
      case albumSongsMoreOptions:
        return context.localization.albumsScreenTitle;
      case playlists:
        return context.localization.playlistsScreenTitle;
      case playlistSongs:
        return context.localization.playlistsScreenTitle;
      case playlistRename:
        return context.localization.playlistsScreenTitle;
      case playlistSongsMoreOptions:
        return context.localization.playlistsScreenTitle;
      case songs:
        return context.localization.songsScreenTitle;
      case songsMoreOptions:
        return context.localization.songsScreenTitle;
      case genres:
        return context.localization.genresScreenTitle;
      case genreSongs:
        return context.localization.genreSongsScreenTitle;
      case genresSongsMoreOptions:
        return context.localization.genreSongsScreenTitle;
      case search:
        return context.localization.searchScreenTitle;
      case searchMoreOptions:
        return context.localization.searchScreenTitle;
      case extras:
        return context.localization.extrasMenuTitle;
      case brick:
        return context.localization.brickGameTitle;
      case musicQuiz:
        return context.localization.musicQuizGameTitle;
      case media:
        return context.localization.mediaMenuTitle;
      case photos:
        return context.localization.photosMenuTitle;
      case photoViewer:
        return context.localization.photosMenuTitle;
      case videos:
        return context.localization.videosMenuTitle;
      case videoPlayer:
        return context.localization.videosMenuTitle;
    }
  }
}

final splitScreenViewControllerProvider = Provider<SplitScreenViewController>((
  ref,
) {
  return SplitScreenViewController();
});

// GoRouter configuration
final routerProvider = Provider(
  (ref) => GoRouter(
    initialLocation: Routes.splash.toString(),
    errorPageBuilder: (context, state) =>
        const CupertinoPage(child: PageNotFoundScreen()),
    routes: [
      ShellRoute(
        navigatorKey: rootNavigatorKey,
        pageBuilder: (context, state, child) {
          return CupertinoPage(
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: CupertinoPageScaffold(
                resizeToAvoidBottomInset: false,
                child: DeviceFrame(key: deviceFrameGlobalKey, child: child),
              ),
            ),
          );
        },
        routes: [
          GoRoute(
            path: Routes.splash.toString(),
            name: Routes.splash.name,
            pageBuilder: (context, state) =>
                const CupertinoPage(child: SplashScreen()),
          ),
          ShellRoute(
            parentNavigatorKey: rootNavigatorKey,
            navigatorKey: menuNavigatorKey,
            pageBuilder: (context, state, child) => CustomTransitionPage(
              child: SplitScreenPlaceholder(
                splitScreenController: ref.read(
                  splitScreenViewControllerProvider,
                ),
                child: child,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
            routes: [
              GoRoute(
                path: Routes.menu.toString(),
                name: Routes.menu.name,
                parentNavigatorKey: menuNavigatorKey,
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: MainMenuScreen()),
                routes: [
                  GoRoute(
                    path: Routes.settings.name,
                    name: Routes.settings.name,
                    parentNavigatorKey: menuNavigatorKey,
                    pageBuilder: (context, state) =>
                        const CupertinoPage(child: SettingsScreen()),
                    routes: [
                      GoRoute(
                        path: Routes.about.name,
                        name: Routes.about.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            const CupertinoPage(child: AboutScreen()),
                      ),
                      GoRoute(
                        path: Routes.language.name,
                        name: Routes.language.name,
                        parentNavigatorKey: menuNavigatorKey,
                        pageBuilder: (context, state) => const CupertinoPage(
                          child: LanguageSelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: Routes.deviceColor.name,
                        name: Routes.deviceColor.name,
                        parentNavigatorKey: menuNavigatorKey,
                        pageBuilder: (context, state) => const CupertinoPage(
                          child: DeviceColorSelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: Routes.deviceSkin.name,
                        name: Routes.deviceSkin.name,
                        parentNavigatorKey: menuNavigatorKey,
                        pageBuilder: (context, state) => const CupertinoPage(
                          child: SkinSelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: Routes.excludeDirectories.name,
                        name: Routes.excludeDirectories.name,
                        parentNavigatorKey: rootNavigatorKey,
                        onExit: (context, state) async {
                          await ref
                              .read(
                                settingsPreferencesControllerProvider.notifier,
                              )
                              .rescanMusicFiles();
                          return true;
                        },
                        pageBuilder: (context, state) => const CupertinoPage(
                          child: ExcludeDirectoriesScreen(),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.nowPlaying.toString(),
                    name: Routes.nowPlaying.name,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      if (state.extra == Routes.menu.name &&
                          ref
                              .read(settingsPreferencesControllerProvider)
                              .splitScreenEnabled) {
                        return CustomTransitionPage(
                          child: const NowPlayingScreen(),
                          transitionsBuilder:
                              (context, animation, reversedAnimation, child) {
                                return FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInQuint,
                                    reverseCurve: Curves.easeOutQuint,
                                  ),
                                  child: child,
                                );
                              },
                        );
                      }

                      return const CupertinoPage(child: NowPlayingScreen());
                    },
                    routes: [
                      GoRoute(
                        path: Routes.nowPlayingMoreOptions.name,
                        name: Routes.nowPlayingMoreOptions.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => OptionsModalPage(
                          context: context,
                          title: Routes.nowPlayingMoreOptions.title(context),
                          builder: (context) =>
                              const NowPlayingMoreOptionsModal(),
                        ),
                      ),
                      GoRoute(
                        path: Routes.sleepTimer.name,
                        name: Routes.sleepTimer.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => CupertinoPage(
                          child: SplitScreenPlaceholder(
                            splitScreenController: SplitScreenViewController(),
                            child: const SleepTimerScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.musicMenu.toString(),
                    name: Routes.musicMenu.name,
                    parentNavigatorKey: menuNavigatorKey,
                    pageBuilder: (context, state) =>
                        const CupertinoPage(child: MusicMenuScreen()),
                    routes: [
                      GoRoute(
                        path: Routes.coverFlow.name,
                        name: Routes.coverFlow.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          if (state.extra == Routes.musicMenu.name &&
                              ref
                                  .read(settingsPreferencesControllerProvider)
                                  .splitScreenEnabled) {
                            return CustomTransitionPage(
                              child: const CoverFlowScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    reversedAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInQuint,
                                        reverseCurve: Curves.easeOutQuint,
                                      ),
                                      child: child,
                                    );
                                  },
                            );
                          }
                          return const CupertinoPage(child: CoverFlowScreen());
                        },
                        routes: [
                          GoRoute(
                            path: Routes.coverFlowSelection.name,
                            name: Routes.coverFlowSelection.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) =>
                                CustomTransitionPage(
                                  opaque: false,
                                  barrierColor: kCupertinoModalBarrierColor,
                                  transitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  reverseTransitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  transitionsBuilder: (context, _, _, child) =>
                                      child,
                                  child: CoverFlowAlbumSelectionScreen(
                                    albumDetail: state.extra as AlbumModel,
                                  ),
                                ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.artists.name,
                        name: Routes.artists.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => const CupertinoPage(
                          child: ArtistsSelectionScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: ":artistName",
                            name: Routes.artistAlbums.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => CupertinoPage(
                              child: ArtistAlbumsScreen(
                                artistName:
                                    state.pathParameters["artistName"] ?? "",
                              ),
                            ),
                            routes: [
                              GoRoute(
                                path: Routes.artistAlbumsMoreOptions.name,
                                name: Routes.artistAlbumsMoreOptions.name,
                                parentNavigatorKey: rootNavigatorKey,
                                pageBuilder: (context, state) =>
                                    OptionsModalPage(
                                      context: context,
                                      title: Routes.artistAlbumsMoreOptions
                                          .title(context),
                                      builder: (context) =>
                                          AlbumMoreOptionsModal(
                                            routeName: Routes
                                                .artistAlbumsMoreOptions
                                                .name,
                                            albumDetail:
                                                state.extra as AlbumModel,
                                            showBrowseArtist: false,
                                          ),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.albums.name,
                        name: Routes.albums.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            const CupertinoPage(child: AlbumsSelectionScreen()),
                        routes: [
                          GoRoute(
                            path: Routes.albumSongs.name,
                            name: Routes.albumSongs.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => CupertinoPage(
                              child: AlbumSongsScreen(
                                albumDetail: state.extra as AlbumModel,
                              ),
                            ),
                            routes: [
                              GoRoute(
                                path: Routes.albumSongsMoreOptions.name,
                                name: Routes.albumSongsMoreOptions.name,
                                parentNavigatorKey: rootNavigatorKey,
                                pageBuilder: (context, state) =>
                                    OptionsModalPage(
                                      context: context,
                                      title: Routes.albumSongsMoreOptions.title(
                                        context,
                                      ),
                                      builder: (context) =>
                                          SongsMoreOptionsModal(
                                            routeName: Routes
                                                .albumSongsMoreOptions
                                                .name,
                                            currentSongMetadata:
                                                state.extra as MusicMetadata,
                                            showAdditionalOptions: false,
                                          ),
                                    ),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: Routes.albumMoreOptions.name,
                            name: Routes.albumMoreOptions.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => OptionsModalPage(
                              context: context,
                              title: Routes.albumMoreOptions.title(context),
                              builder: (context) => AlbumMoreOptionsModal(
                                routeName: Routes.albumMoreOptions.name,
                                albumDetail: state.extra as AlbumModel,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.playlists.name,
                        name: Routes.playlists.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => const CupertinoPage(
                          maintainState: false,
                          child: PlaylistsScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: Routes.playlistSongs.name,
                            name: Routes.playlistSongs.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => CupertinoPage(
                              child: PlaylistSongsScreen(
                                playlistKey: int.tryParse(
                                  state.extra as String,
                                ),
                              ),
                            ),
                            routes: [
                              GoRoute(
                                path: Routes.playlistSongsMoreOptions.name,
                                name: Routes.playlistSongsMoreOptions.name,
                                parentNavigatorKey: rootNavigatorKey,
                                pageBuilder: (context, state) =>
                                    OptionsModalPage(
                                      context: context,
                                      title: Routes.playlistSongsMoreOptions
                                          .title(context),
                                      builder: (context) =>
                                          const PlaylistSongsMoreOptionsModal(),
                                    ),
                              ),
                              GoRoute(
                                path: Routes.playlistRename.name,
                                name: Routes.playlistRename.name,
                                parentNavigatorKey: rootNavigatorKey,
                                pageBuilder: (context, state) => CupertinoPage(
                                  child: PlaylistRenameScreen(
                                    oldPlaylistName: state.extra as String,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.songs.name,
                        name: Routes.songs.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            const CupertinoPage(child: SongsScreen()),
                        routes: [
                          GoRoute(
                            path: Routes.songsMoreOptions.name,
                            name: Routes.songsMoreOptions.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => OptionsModalPage(
                              context: context,
                              title: Routes.songsMoreOptions.title(context),
                              builder: (context) => SongsMoreOptionsModal(
                                routeName: Routes.songsMoreOptions.name,
                                currentSongMetadata:
                                    state.extra as MusicMetadata,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.genres.toString(),
                        name: Routes.genres.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            const CupertinoPage(child: GenresScreen()),
                        routes: [
                          GoRoute(
                            path: ":genreName",
                            name: Routes.genreSongs.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => CupertinoPage(
                              child: GenreSongsScreen(
                                genreName:
                                    state.pathParameters["genreName"] ?? '',
                              ),
                            ),
                            routes: [
                              GoRoute(
                                path: Routes.genresSongsMoreOptions.name,
                                name: Routes.genresSongsMoreOptions.name,
                                parentNavigatorKey: rootNavigatorKey,
                                pageBuilder: (context, state) =>
                                    OptionsModalPage(
                                      context: context,
                                      title: Routes.genresSongsMoreOptions
                                          .title(context),
                                      builder: (context) =>
                                          SongsMoreOptionsModal(
                                            routeName: Routes
                                                .genresSongsMoreOptions
                                                .name,
                                            currentSongMetadata:
                                                state.extra as MusicMetadata,
                                          ),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GoRoute(
                        path: Routes.search.name,
                        name: Routes.search.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            const CupertinoPage(child: SearchScreen()),
                        routes: [
                          GoRoute(
                            path: Routes.searchMoreOptions.name,
                            name: Routes.searchMoreOptions.name,
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => OptionsModalPage(
                              context: context,
                              title: Routes.searchMoreOptions.title(context),
                              builder: (context) => SearchMoreOptionsModal(
                                songMetadata: (state.extra is MusicMetadata)
                                    ? state.extra as MusicMetadata
                                    : null,
                                albumDetail: (state.extra is AlbumModel)
                                    ? state.extra as AlbumModel
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // ── Extras (Games) ────────────────────────────────────────
              GoRoute(
                path: Routes.extras.toString(),
                name: Routes.extras.name,
                parentNavigatorKey: menuNavigatorKey,
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: GamesMenuScreen()),
                routes: [
                  GoRoute(
                    path: Routes.brick.name,
                    name: Routes.brick.name,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        const CupertinoPage(child: BrickGameScreen()),
                  ),
                  GoRoute(
                    path: Routes.musicQuiz.name,
                    name: Routes.musicQuiz.name,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        const CupertinoPage(child: MusicQuizScreen()),
                  ),
                ],
              ),
              // ── Media (Photos & Videos) ───────────────────────────────
              GoRoute(
                path: Routes.media.toString(),
                name: Routes.media.name,
                parentNavigatorKey: menuNavigatorKey,
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: MediaMenuScreen()),
                routes: [
                  GoRoute(
                    path: Routes.photos.name,
                    name: Routes.photos.name,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        const CupertinoPage(child: PhotosScreen()),
                    routes: [
                      GoRoute(
                        path: Routes.photoViewer.name,
                        name: Routes.photoViewer.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final extra =
                              state.extra as Map<String, dynamic>? ?? {};
                          final photos = (extra['photos'] as List?)
                                  ?.cast<MediaFileModel>() ??
                              [];
                          final index = (extra['index'] as int?) ?? 0;
                          return CupertinoPage(
                            child: PhotoViewerScreen(
                              photos: photos,
                              initialIndex: index,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.videos.name,
                    name: Routes.videos.name,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        const CupertinoPage(child: VideosScreen()),
                    routes: [
                      GoRoute(
                        path: Routes.videoPlayer.name,
                        name: Routes.videoPlayer.name,
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => CupertinoPage(
                          child: VideoPlayerScreen(
                            video: state.extra as MediaFileModel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
);
