import 'package:flutter_test/flutter_test.dart';
import 'package:retropod/core/models/lrc_lyrics.dart';

void main() {
  group('parseLrcLyrics', () {
    test('returns null for empty lyrics', () {
      expect(parseLrcLyrics(null), isNull);
      expect(parseLrcLyrics(''), isNull);
      expect(parseLrcLyrics('   '), isNull);
    });

    test('returns null for plain text without timestamps', () {
      expect(parseLrcLyrics('just a plain lyric line'), isNull);
    });

    test('parses single timestamped line', () {
      final lyrics = parseLrcLyrics('[00:11.12] You were the shadow');
      expect(lyrics, isNotNull);
      expect(lyrics!.lines.length, 1);
      expect(lyrics.lines.first.timestamp, const Duration(milliseconds: 11120));
      expect(lyrics.lines.first.text, 'You were the shadow');
    });

    test('parses multiple lines and sorts them by timestamp', () {
      final lyrics = parseLrcLyrics(
        '[00:30.00] second line\n[00:11.12] first line',
      );
      expect(lyrics!.lines.map((line) => line.text), [
        'first line',
        'second line',
      ]);
    });

    test('duplicates a line for every timestamp it carries', () {
      final lyrics = parseLrcLyrics('[00:11.12][00:45.00] repeated line');
      expect(lyrics!.lines.length, 2);
      expect(lyrics.lines[0].timestamp, const Duration(milliseconds: 11120));
      expect(lyrics.lines[1].timestamp, const Duration(milliseconds: 45000));
    });

    test('ignores LRC metadata tags', () {
      final lyrics = parseLrcLyrics(
        '[ti:My Song]\n[ar:My Artist]\n[00:11.12] a lyric\n',
      );
      expect(lyrics!.lines.length, 1);
      expect(lyrics.lines.first.text, 'a lyric');
    });

    test('applies offset tag to all timestamps', () {
      final lyrics = parseLrcLyrics('[offset:+500]\n[00:11.00] a lyric');
      expect(
        lyrics!.lines.first.timestamp,
        const Duration(milliseconds: 11500),
      );
    });

    test('parses fraction-less timestamps', () {
      final lyrics = parseLrcLyrics('[00:11] a lyric');
      expect(
        lyrics!.lines.first.timestamp,
        const Duration(milliseconds: 11000),
      );
    });

    test('getActiveLineIndex returns active line for a position', () {
      final lyrics = parseLrcLyrics('[00:11.12] one\n[00:14.90] two');
      expect(
        lyrics!.getActiveLineIndex(const Duration(milliseconds: 11120)),
        0,
      );
      expect(lyrics.getActiveLineIndex(const Duration(milliseconds: 14000)), 0);
      expect(lyrics.getActiveLineIndex(const Duration(milliseconds: 14900)), 1);
      expect(lyrics.getActiveLineIndex(const Duration(seconds: 3)), 0);
    });

    test('getActiveLineIndex returns -1 for empty lyrics', () {
      expect(const LrcLyrics([]).getActiveLineIndex(Duration.zero), -1);
    });
  });
}
