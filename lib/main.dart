import 'package:flutter/material.dart';

void main() {
  runApp(const HangmanApp());
}

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HangmanGame(),
    );
  }
}

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  _HangmanGameState createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  List<String> wordList = [
    'FLUTTER',
    'DART',
    'MOBILE',
    'DEVELOPMENT',
    'PROGRAMMING',
    'HANGMAN',
  ];
  late String selectedWord;
  late List<String> guessedLetters;
  List<String> guessedAllLetters = [];
  int maxAttempts = 6;
  int attemptsLeft = 6;
  List<String> alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    setState(() {
      selectedWord =
          wordList[(DateTime.now().millisecondsSinceEpoch % wordList.length)]
              .toUpperCase();
      guessedLetters = List.filled(selectedWord.length, '_');
      guessedAllLetters = [];
      attemptsLeft = maxAttempts;
    });
  }

  void guessLetter(String letter) {
    setState(() {
      if (!guessedAllLetters.contains(letter)) {
        guessedAllLetters.add(letter);

        if (selectedWord.contains(letter)) {
          for (int i = 0; i < selectedWord.length; i++) {
            if (selectedWord[i] == letter) {
              guessedLetters[i] = letter;
            }
          }
        } else {
          attemptsLeft--;
        }

        if (!guessedLetters.contains('_')) {
          _showDialog(
            'You Won!',
            'Congratulations! You guessed the word: $selectedWord',
          );
        } else if (attemptsLeft == 0) {
          _showDialog(
            'Game Over',
            'Sorry, you lost. The word was: $selectedWord',
          );
        }
      }
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                startNewGame();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildHangmanImage() {
    int wrongAttempts = maxAttempts - attemptsLeft;
    return CustomPaint(
      painter: HangmanPainter(wrongAttempts),
      size: const Size(200, 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangman Game'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: startNewGame),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildHangmanImage(),
            const SizedBox(height: 20),
            Text(
              'Attempts left: $attemptsLeft',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              guessedLetters.join(' '),
              style: const TextStyle(
                fontSize: 30,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Guessed letters: ${guessedAllLetters.join(', ')}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children:
                  alphabet.map((letter) {
                    bool isGuessed = guessedAllLetters.contains(letter);
                    bool isCorrect = selectedWord.contains(letter) && isGuessed;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isGuessed
                                ? isCorrect
                                    ? Colors.green
                                    : Colors.red
                                : null,
                        foregroundColor: isGuessed ? Colors.white : null,
                      ),
                      onPressed:
                          attemptsLeft > 0 && !isGuessed
                              ? () => guessLetter(letter)
                              : null,
                      child: Text(letter),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int wrongAttempts;

  HangmanPainter(this.wrongAttempts);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Gallows - always visible
    // Base
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.8),
      paint,
    );
    // Pole
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.2),
      paint,
    );
    // Top beam
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.2),
      paint,
    );
    // Rope
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.3),
      paint,
    );

    // Head (4th wrong attempt)
    if (wrongAttempts >= 1) {
      canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.35),
        size.height * 0.05,
        paint,
      );
    }

    // Body (5th wrong attempt)
    if (wrongAttempts >= 2) {
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.4),
        Offset(size.width * 0.7, size.height * 0.6),
        paint,
      );
    }

    // Left arm (6th wrong attempt)
    if (wrongAttempts >= 3) {
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.45),
        Offset(size.width * 0.65, size.height * 0.5),
        paint,
      );
    }

    // Right arm (7th wrong attempt)
    if (wrongAttempts >= 4) {
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.45),
        Offset(size.width * 0.75, size.height * 0.5),
        paint,
      );
    }

    // Left leg (8th wrong attempt)
    if (wrongAttempts >= 5) {
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.6),
        Offset(size.width * 0.65, size.height * 0.7),
        paint,
      );
    }

    // Right leg (9th wrong attempt)
    if (wrongAttempts >= 6) {
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.6),
        Offset(size.width * 0.75, size.height * 0.7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
