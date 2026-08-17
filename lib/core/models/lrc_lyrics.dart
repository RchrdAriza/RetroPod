/// A single timestamped line of synchronized lyrics.
class LrcLine {
  /// The moment in the track where [text] should be shown.
  final Duration timestamp;

  /// The lyric text associated with [timestamp].
  final String text;

  const LrcLine({required this.timestamp, required this.text});
}

/// Parsed synchronized (LRC) lyrics.
class LrcLyrics {
  /// Timed lines sorted by [LrcLine.timestamp].
  final List<LrcLine> lines;

  const LrcLyrics(this.lines);

  /// Returns the index of the line active at [position].
  ///
  /// Returns `-1` when [position] precedes every line or [lines] is empty.
  int getActiveLineIndex(Duration position) {
    if (lines.isEmpty) {
      return -1;
    }

    int activeIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].timestamp <= position) {
        activeIndex = i;
      } else {
        break;
      }
    }
    return activeIndex;
  }
}

/// Matches an LRC timestamp token such as `[00:11.12]` or `[00:11]`.
final RegExp _timestampPattern = RegExp(
  r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]',
);

/// Matches an LRC `[offset:+500]` metadata tag.
final RegExp _offsetPattern = RegExp(r'\[offset:([+-]?\d+)\]');

/// Parses [source] into synchronized lyrics.
///
/// Returns `null` when the text has no timestamped lines and therefore
/// should be shown as plain unsynchronized text.
LrcLyrics? parseLrcLyrics(String? source) {
  if (source == null || source.trim().isEmpty) {
    return null;
  }

  final List<LrcLine> lines = [];
  int? offsetMilliseconds;

  for (final String rawLine in source.split('\n')) {
    final String line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }

    final RegExpMatch? offsetMatch = _offsetPattern.firstMatch(line);
    if (offsetMatch != null) {
      offsetMilliseconds = int.tryParse(offsetMatch.group(1)!);
      continue;
    }

    final List<RegExpMatch> matches = _timestampPattern
        .allMatches(line)
        .toList();
    if (matches.isEmpty) {
      continue;
    }

    final String text = line.substring(matches.last.end).trim();

    for (final RegExpMatch match in matches) {
      final int minutes = int.parse(match.group(1)!);
      final int seconds = int.parse(match.group(2)!);
      final int fractionMilliseconds = _parseFraction(match.group(3));
      int milliseconds =
          minutes * 60000 + seconds * 1000 + fractionMilliseconds;
      if (offsetMilliseconds != null) {
        milliseconds += offsetMilliseconds;
      }

      lines.add(
        LrcLine(
          timestamp: Duration(milliseconds: milliseconds),
          text: text,
        ),
      );
    }
  }

  if (lines.isEmpty) {
    return null;
  }

  lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  return LrcLyrics(lines);
}

int _parseFraction(String? fraction) {
  if (fraction == null || fraction.isEmpty) {
    return 0;
  }
  return (double.parse('0.$fraction') * 1000).round();
}
