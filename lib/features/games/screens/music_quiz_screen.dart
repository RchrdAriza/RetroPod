import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/extensions/go_router_extensions.dart';
import 'package:retropod/core/models/music_metadata.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/core/services/audio_files_service.dart';
import 'package:retropod/core/services/audio_player_service.dart';
import 'package:retropod/features/device/models/device_action.dart';
import 'package:retropod/features/device/services/device_buttons_service_provider.dart';
import 'package:retropod/features/status_bar/widgets/status_bar.dart';

const int _kTotalQuestions = 10;
const int _kSnippetSeconds = 15;
const int _kChoicesCount = 4;

enum _QuizState { playing, answered, finished, notEnoughSongs }

class MusicQuizScreen extends ConsumerStatefulWidget {
  const MusicQuizScreen({super.key});

  @override
  ConsumerState<MusicQuizScreen> createState() => _MusicQuizScreenState();
}

class _MusicQuizScreenState extends ConsumerState<MusicQuizScreen> {
  String get routeName => Routes.musicQuiz.name;

  final Random _random = Random();
  List<MusicMetadata> _allSongs = [];
  late MusicMetadata _correctSong;
  late List<MusicMetadata> _choices;

  int _questionNumber = 0;
  int _score = 0;
  int _selectedChoice = 0;
  bool? _wasCorrect; // null = not answered yet
  _QuizState _quizState = _QuizState.playing;

  Timer? _snippetTimer;
  int _timeLeft = _kSnippetSeconds;

  @override
  void initState() {
    super.initState();
    ref.listenManual(deviceButtonsServiceProvider, _onDeviceAction);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSongs());
  }

  Future<void> _loadSongs() async {
    final songs = ref.read(audioFilesServiceProvider).asData?.value ?? [];
    if (songs.length < _kChoicesCount) {
      setState(() => _quizState = _QuizState.notEnoughSongs);
      return;
    }
    _allSongs = List.from(songs);
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_questionNumber >= _kTotalQuestions) {
      setState(() => _quizState = _QuizState.finished);
      return;
    }
    _snippetTimer?.cancel();

    // Pick correct song
    _correctSong = _allSongs[_random.nextInt(_allSongs.length)];

    // Build choices: correct + 3 random different ones
    final Set<String?> usedPaths = {_correctSong.filePath};
    final List<MusicMetadata> wrongChoices = [];
    final shuffled = List<MusicMetadata>.from(_allSongs)..shuffle(_random);
    for (final s in shuffled) {
      if (wrongChoices.length >= _kChoicesCount - 1) break;
      if (!usedPaths.contains(s.filePath)) {
        wrongChoices.add(s);
        usedPaths.add(s.filePath);
      }
    }

    _choices = [_correctSong, ...wrongChoices]..shuffle(_random);

    setState(() {
      _quizState = _QuizState.playing;
      _selectedChoice = 0;
      _wasCorrect = null;
      _timeLeft = _kSnippetSeconds;
    });

    // Play snippet
    unawaited(_playSnippet());

    // Start countdown
    _snippetTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _confirmAnswer();
      }
    });
  }

  Future<void> _playSnippet() async {
    final player = ref.read(audioPlayerServiceProvider.notifier);
    final audioPlayer = ref.read(audioPlayerProvider);
    try {
      // Load source first so we can read the total duration.
      final totalDuration = await audioPlayer.setAudioSource(
        _correctSong.toAudioSource(),
      );

      Duration startAt = Duration.zero;
      if (totalDuration != null) {
        final maxStartSeconds =
            totalDuration.inSeconds - _kSnippetSeconds;
        if (maxStartSeconds > 0) {
          final randomSeconds = _random.nextInt(maxStartSeconds);
          startAt = Duration(seconds: randomSeconds);
        }
      }

      await player.playSingleSong(_correctSong, startAt: startAt);
    } catch (_) {}
  }

  void _confirmAnswer() {
    if (_quizState != _QuizState.playing) return;
    _snippetTimer?.cancel();

    final bool correct =
        _choices[_selectedChoice].filePath == _correctSong.filePath;
    if (correct) _score++;

    setState(() {
      _wasCorrect = correct;
      _quizState = _QuizState.answered;
      _questionNumber++;
    });

    // Auto-advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextQuestion();
    });
  }

  Future<void> _onDeviceAction(_, DeviceAction? action) async {
    if (action == null) return;
    if (GoRouter.of(context).locationNamed != routeName) return;

    switch (action) {
      case DeviceAction.menu:
        _snippetTimer?.cancel();
        if (mounted) context.pop();
        break;
      case DeviceAction.rotateForward:
        if (_quizState == _QuizState.playing) {
          setState(() {
            _selectedChoice = (_selectedChoice + 1) % _choices.length;
          });
        }
        break;
      case DeviceAction.rotateBackward:
        if (_quizState == _QuizState.playing) {
          setState(() {
            _selectedChoice =
                (_selectedChoice - 1 + _choices.length) % _choices.length;
          });
        }
        break;
      case DeviceAction.select:
        if (_quizState == _QuizState.playing) {
          _confirmAnswer();
        } else if (_quizState == _QuizState.finished) {
          if (mounted) context.pop();
        }
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _snippetTimer?.cancel();
    super.dispose();
  }

  Widget _buildNotEnoughSongs(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          context.localization.musicQuizNoSongs,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: CupertinoColors.label),
        ),
      ),
    );
  }

  Widget _buildFinished(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.localization.musicQuizFinished,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.localization.musicQuizFinalScore(_score, _kTotalQuestions),
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SELECT or MENU to exit',
            style: TextStyle(
              fontSize: 9,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // Header row: question count + timer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.localization.musicQuizQuestion(
                    _questionNumber + 1,
                    _kTotalQuestions,
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                Text(
                  '${_timeLeft}s',
                  style: TextStyle(
                    fontSize: 10,
                    color: _timeLeft <= 5
                        ? CupertinoColors.systemRed
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Text(
            context.localization.musicQuizScore(_score),
            style: const TextStyle(fontSize: 11, color: CupertinoColors.label),
          ),
          const SizedBox(height: 6),
          // "Now Playing" hint
          const Text(
            '♫ Guess the song...',
            style: TextStyle(
              fontSize: 10,
              color: CupertinoColors.secondaryLabel,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          // Answer choices
          ...List.generate(_choices.length, (i) {
            final bool isSelected = _selectedChoice == i;
            final bool isCorrect =
                _choices[i].filePath == _correctSong.filePath;
            Color bg = CupertinoColors.systemGrey6.resolveFrom(context);
            Color textColor = CupertinoColors.label.resolveFrom(context);

            if (_quizState == _QuizState.answered) {
              if (isCorrect) {
                bg = CupertinoColors.systemGreen;
                textColor = CupertinoColors.white;
              } else if (isSelected && !isCorrect) {
                bg = CupertinoColors.systemRed;
                textColor = CupertinoColors.white;
              }
            } else if (isSelected) {
              bg = CupertinoColors.systemBlue;
              textColor = CupertinoColors.white;
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
                border: isSelected && _quizState == _QuizState.playing
                    ? Border.all(color: CupertinoColors.systemBlue, width: 1.5)
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Text(
                _choices[i].trackName ??
                    _choices[i].filePath?.split('/').last ??
                    'Unknown',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          if (_quizState == _QuizState.answered)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                _wasCorrect == true
                    ? context.localization.musicQuizCorrect
                    : context.localization.musicQuizWrong,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _wasCorrect == true
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.musicQuiz.title(context)),
          Expanded(
            child: switch (_quizState) {
              _QuizState.notEnoughSongs => _buildNotEnoughSongs(context),
              _QuizState.finished => _buildFinished(context),
              _ => _buildQuestion(context),
            },
          ),
        ],
      ),
    );
  }
}
