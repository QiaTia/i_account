import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final List<String> words = [
    'love', 'performance', 'change', 'success', 'development', 'way', 'quickly',
    'harmony', 'progress', 'solve', 'end', 'blank', 'happiness', 'waste', 'beauty',
    'ability', 'balance', 'expectation', 'diligence', 'situation', 'task', 'failure',
    'hope', 'impact', 'passion', 'advance', 'tolerance', 'implementation', 'relative',
    'trust', 'hero', 'excellent', 'awareness', 'final', 'outstanding', 'responsibility',
    'preparation', 'competition', 'evolution', 'establish', 'challenge', 'contrast',
    'regulation', 'skills', 'resources', 'confidence'
  ];

  final TextEditingController _controller = TextEditingController();
  final List<WordData> activeWords = [];
  double gameSpeed = 1.0;
  Timer? _wordGenerator;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _wordGenerator = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        activeWords.add(WordData(
          word: words[_random.nextInt(words.length)],
          left: _random.nextDouble() * (MediaQuery.of(context).size.width - 200),
          controller: AnimationController(
            vsync: this,
            duration: Duration(seconds: 5),
          )..forward(),
          rotation: _random.nextBool() 
              ? _random.nextDouble() * 0.1 - 0.05 
              : _random.nextDouble() * 0.05,
          speed: gameSpeed,
        ));
        gameSpeed *= 1.05; // 逐渐增加难度
      });
    });
  }

  void _checkInput(String value) {
    if (value.isEmpty) return;
    
    setState(() {
      activeWords.removeWhere((wordData) {
        if (wordData.word == value) {
          wordData.controller.reverse();
          return true;
        }
        return false;
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FAFB), Color(0xFFECF2F4)],
        ),
      ),
      child: Stack(
        children: [
          ...activeWords.map((wordData) => _buildAnimatedWord(wordData)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _checkInput,
                  decoration: InputDecoration(
                    hintText: '试试用键盘接住下落的单词',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWord(WordData wordData) {
    return AnimatedBuilder(
      animation: wordData.controller,
      builder: (context, child) {
        if (wordData.controller.status == AnimationStatus.dismissed) {
          return SizedBox.shrink();
        }
        
        final screenHeight = MediaQuery.of(context).size.height;
        return Positioned(
          left: wordData.left,
          top: screenHeight * wordData.controller.value,
          child: Opacity(
            opacity: wordData.controller.value,
            child: Transform.rotate(
              angle: wordData.rotation * 2 * pi,
              child: Text(
                wordData.word,
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _wordGenerator?.cancel();
    for (var word in activeWords) {
      word.controller.dispose();
    }
    super.dispose();
  }
}

class WordData {
  final String word;
  final double left;
  final AnimationController controller;
  final double rotation;
  final double speed;

  WordData({
    required this.word,
    required this.left,
    required this.controller,
    required this.rotation,
    required this.speed,
  });
}