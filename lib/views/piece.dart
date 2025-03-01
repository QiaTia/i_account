import 'package:flutter/material.dart';

class GoGame extends StatelessWidget {
  const GoGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent,),
        backgroundColor: const Color(0xFFf0f0f0),
        body: Center(child: GomokuWidget()),
      );
  }
}

class GomokuWidget extends StatefulWidget {
  @override
  _GomokuWidgetState createState() => _GomokuWidgetState();
}

class _GomokuWidgetState extends State<GomokuWidget> {
  final int _boardSize = 500;
  final int _gridCount = 15;
  List<List<Color?>> _stones = [];
  bool _isBlackTurn = true;
  String _gameStatus = "黑方回合";
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    _stones = List.generate(
      _gridCount,
      (i) => List.generate(_gridCount, (j) => null),
    );
  }

  void _placeStone(int x, int y) {
    if (_gameOver || _stones[x][y] != null) return;
    
    setState(() {
      _stones[x][y] = _isBlackTurn ? Colors.black : Colors.white;
      if (_checkWin(x, y)) {
        _gameStatus = "${_isBlackTurn ? "黑" : "白"}方胜利！";
        _gameOver = true;
      } else {
        _isBlackTurn = !_isBlackTurn;
        _gameStatus = "${_isBlackTurn ? "黑" : "白"}方回合";
      }
    });
  }

  bool _checkWin(int x, int y) {
    final directions = [
      [1, 0],  // 水平
      [0, 1],  // 垂直
      [1, 1],  // 右下
      [1, -1], // 右上
    ];

    for (var dir in directions) {
      int count = 1;
      for (int i = 1; i < 5; i++) {
        int dx = x + dir[0] * i;
        int dy = y + dir[1] * i;
        if (dx < 0 || dx >= _gridCount || dy < 0 || dy >= _gridCount) break;
        if (_stones[dx][dy] == _stones[x][y]) {
          count++;
        } else {
          break;
        }
      }

      for (int i = 1; i < 5; i++) {
        int dx = x - dir[0] * i;
        int dy = y - dir[1] * i;
        if (dx < 0 || dx >= _gridCount || dy < 0 || dy >= _gridCount) break;
        if (_stones[dx][dy] == _stones[x][y]) {
          count++;
        } else {
          break;
        }
      }

      if (count >= 5) return true;
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      _initializeBoard();
      _isBlackTurn = true;
      _gameStatus = "黑方回合";
      _gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _gameStatus,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTapUp: (details) {
            if (_gameOver) return;
            final offset = details.localPosition;
            
            final cellSize = _boardSize / (_gridCount - 1); // 修改为基于间隔计算
            // final double threshold = cellSize / 3;

            // 计算最近的交叉点
            int x = ((offset.dx) / cellSize).round().clamp(0, _gridCount - 1);
            int y = ((offset.dy) / cellSize).round().clamp(0, _gridCount - 1);

            _placeStone(x, y);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFf3d2b5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
            child: SizedBox(
              width: _boardSize.toDouble(),
              height: _boardSize.toDouble(),
              child: CustomPaint(painter: GomokuPainter(_stones, _gridCount)),
            ) ,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetGame,
          child: const Text("重新开始"),
        )
      ],
    );
  }
}

class GomokuPainter extends CustomPainter {
  final List<List<Color?>> stones;
  final int gridCount;

  GomokuPainter(this.stones, this.gridCount);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / (gridCount - 1); // 基于间隔计算
    final linePaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 1.5;
    print("cellSize: $cellSize");
    // 绘制棋盘线
    for (int i = 0; i < gridCount; i++) {
      // 水平线
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        linePaint,
      );
      // 垂直线
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        linePaint,
      );
    }

    // 绘制棋子
    final stoneRadius = cellSize / 2.4;
    for (int i = 0; i < gridCount; i++) {
      for (int j = 0; j < gridCount; j++) {
        if (stones[i][j] != null) {
          final paint = Paint()
            ..color = stones[i][j]!
            ..style = PaintingStyle.fill;
          
          // 直接在交叉点绘制
          canvas.drawCircle(
            Offset(i * cellSize, j * cellSize),
            stoneRadius,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
