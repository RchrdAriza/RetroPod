import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/models/lrc_lyrics.dart';
import 'package:retropod/core/services/audio_player_service.dart';

class LyricsView extends ConsumerStatefulWidget {
  final String? lyrics;
  final ScrollController scrollController;

  const LyricsView({
    super.key,
    required this.lyrics,
    required this.scrollController,
  });

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  LrcLyrics? _lrcLyrics;
  bool _hasSyncedLyrics = false;
  int _activeLineIndex = 0;
  StreamSubscription<Duration>? _positionSubscription;
  final List<GlobalKey> _lineKeys = [];

  @override
  void initState() {
    super.initState();
    _parseLyrics();
  }

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyrics != widget.lyrics) {
      _parseLyrics();
    }
  }

  void _parseLyrics() {
    _lrcLyrics = parseLrcLyrics(widget.lyrics);
    _hasSyncedLyrics = _lrcLyrics != null;
    _activeLineIndex = 0;
    _lineKeys
      ..clear()
      ..addAll(
        List.generate(
          _hasSyncedLyrics ? _lrcLyrics!.lines.length : 0,
          (_) => GlobalKey(),
        ),
      );

    unawaited(_positionSubscription?.cancel());
    _positionSubscription = ref
        .read(audioPlayerProvider)
        .positionStream
        .listen(_handlePositionChange);
  }

  void _handlePositionChange(Duration position) {
    if (!_hasSyncedLyrics) {
      return;
    }

    final int activeIndex = _lrcLyrics?.getActiveLineIndex(position) ?? 0;
    if (activeIndex == _activeLineIndex) {
      return;
    }

    setState(() {
      _activeLineIndex = activeIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_scrollToActiveLine());
      }
    });
  }

  Future<void> _scrollToActiveLine() async {
    if (!_hasSyncedLyrics || !widget.scrollController.hasClients) {
      return;
    }

    final BuildContext? lineContext =
        _lineKeys[_activeLineIndex].currentContext;
    if (lineContext == null) {
      return;
    }

    final RenderBox renderBox = lineContext.findRenderObject() as RenderBox;
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(
      renderBox,
    );
    final double revealOffset = viewport
        .getOffsetToReveal(renderBox, 0.5)
        .offset;

    if ((revealOffset - widget.scrollController.offset).abs() < 1) {
      return;
    }

    await widget.scrollController.animateTo(
      revealOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    unawaited(_positionSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? lyrics = widget.lyrics;
    if (lyrics == null || lyrics.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: CupertinoScrollbar(
        controller: widget.scrollController,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(right: 10),
          child: _hasSyncedLyrics
              ? _buildSyncedLines()
              : _buildPlainText(lyrics),
        ),
      ),
    );
  }

  Widget _buildPlainText(String lyrics) {
    return Text(
      lyrics,
      style: const TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSyncedLines() {
    final LrcLyrics lyrics = _lrcLyrics!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lyrics.lines.length; i++)
          Padding(
            key: _lineKeys[i],
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              lyrics.lines[i].text,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: i == _activeLineIndex
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: i == _activeLineIndex
                    ? context.appPrimaryTextColor
                    : context.appSecondaryTextColor,
              ),
            ),
          ),
      ],
    );
  }
}
