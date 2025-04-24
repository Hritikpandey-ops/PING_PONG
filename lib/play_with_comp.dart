import 'dart:async';
import 'package:flutter/material.dart';

class PlayWithComputerScreen extends StatefulWidget {
  const PlayWithComputerScreen({super.key});

  @override
  State<PlayWithComputerScreen> createState() => _PlayWithComputerScreenState();
}

class _PlayWithComputerScreenState extends State<PlayWithComputerScreen> {
  late double screenWidth;
  late double screenHeight;

  // Ball position and velocity (relative to game box)
  double ballX = 0;
  double ballY = 0;
  double dx = 3;
  double dy = 3;

  // Paddle positions (relative to game box)
  double userPaddleX = 0;
  double computerPaddleX = 0;

  // Paddle size
  final double paddleWidth = 100;
  final double paddleHeight = 15;

  // Game loop
  late Timer gameLoop;

  // Score and Difficulty
  int score = 0;
  String difficulty = 'Medium';
  bool isGameOver = false;

  // Game state
  bool isGameStarted = false;
  bool isInitialized = false;

  // Speed multiplier based on difficulty
  double get speedMultiplier {
    if (difficulty == 'Easy') return 1.5;
    if (difficulty == 'Medium') return 2.0;
    return 2.5; // Hard
  }

  // Game box dimensions and positioning
  late double boundaryLeft;
  late double boundaryRight;
  late double boundaryTop;
  late double boundaryBottom;
  late double gameBoxWidth;
  late double gameBoxHeight;
  final double gameBoxHorizontalPadding = 50;
  final double gameBoxVerticalPadding = 100;

  @override
  void initState() {
    super.initState();
    boundaryLeft = 0;
    boundaryRight = 0;
    boundaryTop = 0;
    boundaryBottom = 0;
    gameBoxWidth = 0;
    gameBoxHeight = 0;
  }

  void initializeGameDimensions() {
    gameBoxWidth = screenWidth - 2 * gameBoxHorizontalPadding;
    gameBoxHeight = (screenHeight - 2 * gameBoxVerticalPadding) * 0.6;
    
    boundaryLeft = gameBoxHorizontalPadding;
    boundaryRight = boundaryLeft + gameBoxWidth;
    boundaryTop = gameBoxVerticalPadding + ((screenHeight - 2 * gameBoxVerticalPadding) - gameBoxHeight) / 2;
    boundaryBottom = boundaryTop + gameBoxHeight;
    
    userPaddleX = (gameBoxWidth - paddleWidth) / 2;
    computerPaddleX = (gameBoxWidth - paddleWidth) / 2;
    
    ballX = gameBoxWidth / 2;
    ballY = gameBoxHeight / 2;
    
    isInitialized = true;
  }

  void updateGame() {
    setState(() {
      // Move ball
      ballX += dx;
      ballY += dy;

      // Ball wall collision - left/right
      if (ballX <= 0 || ballX >= gameBoxWidth - 15) {
        dx = -dx;
        ballX = ballX.clamp(0, gameBoxWidth - 15);
      }

      // Ball wall collision - top
      if (ballY <= 0) {
        dy = -dy;
        ballY = 0;
      }

      // Computer paddle collision
      if (ballY <= paddleHeight &&
          ballX + 15 >= computerPaddleX &&
          ballX <= computerPaddleX + paddleWidth) {
        dy = -dy;
        ballY = paddleHeight;
        score++;
      }

      // User paddle collision
      if (ballY >= gameBoxHeight - paddleHeight - 15 &&
          ballX + 15 >= userPaddleX &&
          ballX <= userPaddleX + paddleWidth) {
        dy = -dy;
        ballY = gameBoxHeight - paddleHeight - 15;
      }

      // Game over when ball misses the paddle
      if (ballY > gameBoxHeight) {
        gameOver();
      }

      // Improved Computer AI
      if (dy < 0) { // Only track when ball is moving upward
        double predictedX = ballX + (dx/dy) * (0 - ballY);
        double targetX = predictedX.clamp(0, gameBoxWidth - paddleWidth);
        double distance = targetX - (computerPaddleX + paddleWidth/2);
        
        double moveSpeed = (distance.abs() * 0.1).clamp(2, 8) * speedMultiplier;
        
        if (distance > 5) {
          computerPaddleX += moveSpeed;
        } else if (distance < -5) {
          computerPaddleX -= moveSpeed;
        }
      }

      // Keep computer paddle in bounds
      computerPaddleX = computerPaddleX.clamp(0, gameBoxWidth - paddleWidth);
    });
  }

  void resetBall() {
    ballX = gameBoxWidth / 2;
    ballY = gameBoxHeight / 2;
    dx = 3 * speedMultiplier * (dx > 0 ? 1 : -1);
    dy = 3 * speedMultiplier;
  }

  void gameOver() {
    setState(() {
      isGameOver = true;
      isGameStarted = false;
      gameLoop.cancel();
    });
  }

  void startGame() {
    setState(() {
      isGameStarted = true;
      isGameOver = false;
      score = 0;
      resetBall();
      userPaddleX = (gameBoxWidth - paddleWidth) / 2;
      computerPaddleX = (gameBoxWidth - paddleWidth) / 2;
    });
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) => updateGame());
  }

  void restartGame() {
    setState(() {
      isGameOver = false;
      isGameStarted = false;
      score = 0;
    });
  }

  @override
  void dispose() {
    if (gameLoop.isActive) {
      gameLoop.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    
    if (!isInitialized) {
      initializeGameDimensions();
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: GestureDetector(
        onHorizontalDragUpdate: isGameStarted ? (details) {
          setState(() {
            userPaddleX += details.delta.dx;
            userPaddleX = userPaddleX.clamp(0, gameBoxWidth - paddleWidth);
          });
        } : null,
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.indigo[900]!, Colors.grey[900]!],
                ),
              ),
            ),

            // Game box with neon effect
            Positioned(
              left: boundaryLeft,
              top: boundaryTop,
              child: Container(
                width: gameBoxWidth,
                height: gameBoxHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            ),

            // Center line
            Positioned(
              left: boundaryLeft + gameBoxWidth/2 - 1,
              top: boundaryTop,
              child: Container(
                width: 2,
                height: gameBoxHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.cyanAccent, Colors.transparent],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Ball with glow effect
            Positioned(
              left: boundaryLeft + ballX,
              top: boundaryTop + ballY,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            ),

            // User paddle (glowing green)
            Positioned(
              left: boundaryLeft + userPaddleX,
              top: boundaryTop + gameBoxHeight - paddleHeight,
              child: Container(
                width: paddleWidth,
                height: paddleHeight,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.7),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            ),

            // Computer paddle (glowing red)
            Positioned(
              left: boundaryLeft + computerPaddleX,
              top: boundaryTop,
              child: Container(
                width: paddleWidth,
                height: paddleHeight,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.7),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            ),

            // Score display
            Positioned(
              left: 30,
              top: 30,
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.amber.withOpacity(0.7),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Difficulty display
            Positioned(
              right: 30,
              top: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: Text(
                  'Difficulty: $difficulty',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Game Over overlay
            if (isGameOver)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'GAME OVER',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 15,
                                color: Colors.red.withOpacity(0.7),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Final Score: $score',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            restartGame();
                            startGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            shadowColor: Colors.cyanAccent.withOpacity(0.7),
                          ),
                          child: const Text(
                            'PLAY AGAIN',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Start button
            if (!isGameStarted && !isGameOver)
              Positioned(
                top: boundaryBottom + 30,
                left: (screenWidth - 200) / 2,
                child: ElevatedButton(
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.cyanAccent.withOpacity(0.7),
                  ),
                  child: const Text(
                    'START GAME',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

            // Game title
            if (!isGameStarted && !isGameOver)
              Positioned(
                top: boundaryTop - 70,
                left: 0,
                right: 0,
                child: Text(
                  'PONG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 15,
                        color: Colors.cyanAccent.withOpacity(0.7),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}