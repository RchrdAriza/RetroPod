import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:retropod/core/extensions/go_router_extensions.dart';
import 'package:retropod/core/navigation/routes.dart';
import 'package:retropod/features/device/models/device_action.dart';
import 'package:retropod/features/device/services/device_buttons_service_provider.dart';
import 'package:retropod/features/status_bar/widgets/status_bar.dart';

// ---------------------------------------------------------------------------
// Game constants
// ---------------------------------------------------------------------------
const int _kColumns = 7;
const int _kRows = 5;
const double _kBrickPadding = 2.0;
const double _kPaddleSpeed = 18.0;

enum _GameState { playing, paused, gameOver, win }

// ---------------------------------------------------------------------------
// Brick Game Painter
// ---------------------------------------------------------------------------
class _BrickGamePainter extends CustomPainter {
  final List<List<bool>> bricks;
  final Offset ball;
  final double ballRadius;
  final Rect paddle;
  final _GameState gameState;
  final int score;

  const _BrickGamePainter({
    required this.bricks,
    required this.ball,
    required this.ballRadius,
    required this.paddle,
    required this.gameState,
    required this.score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // Bricks
    final double brickW =
        (size.width - (_kBrickPadding * (_kColumns + 1))) / _kColumns;
    const double brickH = 10.0;
    const double brickAreaTop = 8.0;

    final List<Color> rowColors = [
      const Color(0xFFFF3B30),
      const Color(0xFFFF9500),
      const Color(0xFFFFCC00),
      const Color(0xFF34C759),
      const Color(0xFF007AFF),
    ];

    for (int row = 0; row < _kRows; row++) {
      for (int col = 0; col < _kColumns; col++) {
        if (bricks[row][col]) {
          final double left =
              _kBrickPadding + col * (brickW + _kBrickPadding);
          final double top =
              brickAreaTop + row * (brickH + _kBrickPadding);
          final Rect brickRect =
              Rect.fromLTWH(left, top, brickW, brickH);
          canvas.drawRRect(
            RRect.fromRectAndRadius(brickRect, const Radius.circular(2)),
            Paint()..color = rowColors[row % rowColors.length],
          );
        }
      }
    }

    // Ball
    canvas.drawCircle(
      ball,
      ballRadius,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // Paddle
    canvas.drawRRect(
      RRect.fromRectAndRadius(paddle, const Radius.circular(4)),
      Paint()..color = const Color(0xFFAAAAAA),
    );
  }

  @override
  bool shouldRepaint(covariant _BrickGamePainter old) => true;
}

// ---------------------------------------------------------------------------
// Brick Game Screen
// ---------------------------------------------------------------------------
class BrickGameScreen extends ConsumerStatefulWidget {
  const BrickGameScreen({super.key});

  @override
  ConsumerState<BrickGameScreen> createState() => _BrickGameScreenState();
}

class _BrickGameScreenState extends ConsumerState<BrickGameScreen>
    with SingleTickerProviderStateMixin {
  // Game area size — set during layout
  double _gameWidth = 160;
  double _gameHeight = 100;

  // Ball state
  late Offset _ball;
  late Offset _ballVelocity;
  final double _ballRadius = 5;

  // Paddle state
  final double _paddleW = 32;
  final double _paddleH = 5;
  late double _paddleX;

  // Bricks
  late List<List<bool>> _bricks;

  int _score = 0;
  _GameState _gameState = _GameState.playing;
  Ticker? _ticker;
  Duration? _lastTick;

  String get routeName => Routes.brick.name;

  @override
  void initState() {
    super.initState();
    _resetGame();
    ref.listenManual(deviceButtonsServiceProvider, _onDeviceAction);
    _ticker = createTicker(_tick)..start();
  }

  void _resetGame() {
    _paddleX = _gameWidth / 2 - _paddleW / 2;
    _ball = Offset(_gameWidth / 2, _gameHeight - 30);
    final random = Random();
    final angle = (random.nextDouble() * 60 - 30) * (pi / 180) - pi / 2;
    const speed = 2.5;
    _ballVelocity = Offset(cos(angle) * speed, sin(angle) * speed);
    _bricks = List.generate(
      _kRows,
      (_) => List.filled(_kColumns, true),
    );
    _score = 0;
    _gameState = _GameState.playing;
    _lastTick = null;
  }

  void _tick(Duration elapsed) {
    if (_gameState != _GameState.playing) return;

    final dt = _lastTick == null
        ? 0.0
        : (elapsed - _lastTick!).inMilliseconds / 16.67;
    _lastTick = elapsed;
    if (dt <= 0) return;

    setState(() {
      double nx = _ball.dx + _ballVelocity.dx * dt;
      double ny = _ball.dy + _ballVelocity.dy * dt;
      double vx = _ballVelocity.dx;
      double vy = _ballVelocity.dy;

      // Wall bounces
      if (nx - _ballRadius < 0) {
        nx = _ballRadius;
        vx = -vx;
      } else if (nx + _ballRadius > _gameWidth) {
        nx = _gameWidth - _ballRadius;
        vx = -vx;
      }
      if (ny - _ballRadius < 0) {
        ny = _ballRadius;
        vy = -vy;
      }

      // Paddle
      final Rect paddleRect = Rect.fromLTWH(
        _paddleX,
        _gameHeight - _paddleH - 4,
        _paddleW,
        _paddleH,
      );
      if (ny + _ballRadius >= paddleRect.top &&
          ny - _ballRadius <= paddleRect.bottom &&
          nx >= paddleRect.left &&
          nx <= paddleRect.right &&
          vy > 0) {
        ny = paddleRect.top - _ballRadius;
        vy = -vy;
        // Add spin based on where ball hits paddle
        final hitPos = (nx - paddleRect.left) / _paddleW - 0.5;
        vx = hitPos * 4.0;
      }

      // Brick collision
      final double brickW =
          (_gameWidth - (_kBrickPadding * (_kColumns + 1))) / _kColumns;
      const double brickH = 10.0;
      const double brickAreaTop = 8.0;

      outer:
      for (int row = 0; row < _kRows; row++) {
        for (int col = 0; col < _kColumns; col++) {
          if (!_bricks[row][col]) continue;
          final double left =
              _kBrickPadding + col * (brickW + _kBrickPadding);
          final double top = brickAreaTop + row * (brickH + _kBrickPadding);
          final Rect brickRect = Rect.fromLTWH(left, top, brickW, brickH);
          final Rect ballRect = Rect.fromCircle(
            center: Offset(nx, ny),
            radius: _ballRadius,
          );
          if (ballRect.overlaps(brickRect)) {
            _bricks[row][col] = false;
            _score += (_kRows - row) * 10;
            vy = -vy;
            break outer;
          }
        }
      }

      // Win check
      final bool allGone =
          _bricks.every((row) => row.every((b) => !b));
      if (allGone) {
        _gameState = _GameState.win;
      }

      // Fall off bottom
      if (ny - _ballRadius > _gameHeight) {
        _gameState = _GameState.gameOver;
      }

      _ball = Offset(nx, ny);
      _ballVelocity = Offset(vx, vy);
    });
  }

  void _movePaddle(double dx) {
    setState(() {
      _paddleX = (_paddleX + dx).clamp(0.0, _gameWidth - _paddleW);
    });
  }

  Future<void> _onDeviceAction(_, DeviceAction? action) async {
    if (action == null) return;
    if (GoRouter.of(context).locationNamed != routeName) return;
    switch (action) {
      case DeviceAction.menu:
        if (mounted) context.pop();
        break;
      case DeviceAction.playPause:
        setState(() {
          if (_gameState == _GameState.playing) {
            _gameState = _GameState.paused;
          } else if (_gameState == _GameState.paused) {
            _gameState = _GameState.playing;
            _lastTick = null;
          } else if (_gameState == _GameState.gameOver ||
              _gameState == _GameState.win) {
            _resetGame();
          }
        });
        break;
      case DeviceAction.rotateForward:
        if (_gameState == _GameState.playing) {
          _movePaddle(_kPaddleSpeed);
        }
        break;
      case DeviceAction.rotateBackward:
        if (_gameState == _GameState.playing) {
          _movePaddle(-_kPaddleSpeed);
        }
        break;
      case DeviceAction.select:
        setState(() {
          if (_gameState == _GameState.gameOver ||
              _gameState == _GameState.win) {
            _resetGame();
          } else if (_gameState == _GameState.paused) {
            _gameState = _GameState.playing;
            _lastTick = null;
          }
        });
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  Widget _buildOverlay(BuildContext context) {
    final String title;
    final String subtitle;
    if (_gameState == _GameState.gameOver) {
      title = context.localization.brickGameOver;
      subtitle = context.localization.brickScore(_score);
    } else if (_gameState == _GameState.win) {
      title = context.localization.brickGameWin;
      subtitle = context.localization.brickScore(_score);
    } else {
      // paused
      title = 'Paused';
      subtitle = context.localization.brickScore(_score);
    }

    return ColoredBox(
      color: const Color(0xAA000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'SELECT to restart',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.brick.title(context)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _gameWidth = constraints.maxWidth;
                _gameHeight = constraints.maxHeight;
                final Rect paddleRect = Rect.fromLTWH(
                  _paddleX,
                  _gameHeight - _paddleH - 4,
                  _paddleW,
                  _paddleH,
                );
                return GestureDetector(
                  onTapDown: (_) {
                    if (_gameState == _GameState.playing) {
                      setState(() => _gameState = _GameState.paused);
                    } else if (_gameState == _GameState.paused) {
                      setState(() {
                        _gameState = _GameState.playing;
                        _lastTick = null;
                      });
                    } else {
                      setState(_resetGame);
                    }
                  },
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _BrickGamePainter(
                          bricks: _bricks,
                          ball: _ball,
                          ballRadius: _ballRadius,
                          paddle: paddleRect,
                          gameState: _gameState,
                          score: _score,
                        ),
                        child: const SizedBox.expand(),
                      ),
                      // Score overlay (top right)
                      Positioned(
                        top: 2,
                        right: 4,
                        child: Text(
                          context.localization.brickScore(_score),
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 9,
                          ),
                        ),
                      ),
                      if (_gameState != _GameState.playing)
                        _buildOverlay(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
