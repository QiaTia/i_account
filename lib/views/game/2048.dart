import 'package:flutter/material.dart';
import 'dart:math';

class My2048Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '2048 Game',
        ),
      ),
      body: Center(child: GameBoard()),
    );
  }
}

class GameBoard extends StatefulWidget {
  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    addRandomTile();
    addRandomTile();
  }

  void addRandomTile() {
    if (grid.every((row) => row.every((cell) => cell != 0))) return;
    Random random = Random();
    int x, y;
    do {
      x = random.nextInt(4);
      y = random.nextInt(4);
    } while (grid[x][y] != 0);

    grid[x][y] = random.nextDouble() < 0.9 ? 2 : 4;
  }

  void move(String direction) {
    switch (direction) {
      case 'up':
        for (int col = 0; col < 4; col++) {
          List<int> column = [for (int row = 0; row < 4; row++) grid[row][col]];
          column = mergeCells(column);
          for (int row = 0; row < 4; row++) grid[row][col] = column[row];
        }
        break;
      case 'down':
        for (int col = 0; col < 4; col++) {
          List<int> column = [
            for (int row = 3; row >= 0; row--) grid[row][col]
          ];
          column = mergeCells(column.reversed.toList()).reversed.toList();
          for (int row = 0; row < 4; row++) grid[row][col] = column[row];
        }
        break;
      case 'left':
        for (int row = 0; row < 4; row++) {
          grid[row] = mergeCells(grid[row]);
        }
        break;
      case 'right':
        for (int row = 0; row < 4; row++) {
          grid[row] = mergeCells(grid[row].reversed.toList()).reversed.toList();
        }
        break;
    }
    addRandomTile();
    setState(() {});
    checkGameOver();
  }

  List<int> mergeCells(List<int> cells) {
    List<int> result = [];
    cells.forEach((cell) {
      if (cell == 0) return;
      if (result.isNotEmpty && result.last == cell) {
        result[result.length - 1] *= 2;
      } else {
        result.add(cell);
      }
    });
    while (result.length < 4) result.add(0);
    return result;
  }

  void checkGameOver() {
    if (grid.any((row) => row.contains(0))) return;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i][j] == grid[i][j + 1] || grid[j][i] == grid[j + 1][i])
          return;
      }
    }
    setState(() {
      gameOver = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 16,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              int value = grid[index ~/ 4][index % 4];
              String text = value.toString();
              Color bgColor;
              Color textColor;
              if (value == 0) {
                bgColor = const Color(0xFFF5E6CC);
                textColor = Colors.transparent;
              } else if (value <= 4) {
                bgColor = const Color(0xFFEEE4DA);
                textColor = const Color(0xFF776E65);
              } else if (value <= 16) {
                bgColor = const Color(0xFFEDC850);
                textColor = Colors.white;
              } else if (value <= 128) {
                bgColor = const Color(0xF6F5DD);
                textColor = Colors.white;
              } else if (value <= 512) {
                bgColor = const Color(0xFFEDC53F);
                textColor = Colors.white;
              } else if (value <= 1024) {
                bgColor = const Color(0xFFFFAB6E);
                textColor = Colors.white;
              } else if (value <= 2048) {
                bgColor = const Color(0xFFEDC22E);
                textColor = Colors.white;
              } else {
                bgColor = const Color(0xFFEEED72);
                textColor = Colors.white;
              }
              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  text == '0' ? '' : text,
                  style: TextStyle(fontSize: 24, color: textColor),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => move('up'),
              style: ButtonStyle(
                backgroundColor:
                    const WidgetStatePropertyAll<Color>(Color(0xFFF57C00)),
                overlayColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return const Color(0xFFFb8C00);
                    }
                    return Colors.transparent;
                  },
                ),
                textStyle: const WidgetStatePropertyAll<TextStyle>(
                  TextStyle(fontSize: 10),
                ),
                padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              child: const Text('UP'),
            ),
            const SizedBox(width: 3),
            ElevatedButton(
              onPressed: () => move('left'),
              style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll<Color>(Color(0xFFF57C00)),
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return const Color(0xFFFb8C00);
                    }
                    return Colors.transparent;
                  },
                ),
                textStyle: const MaterialStatePropertyAll<TextStyle>(
                  TextStyle(fontSize: 10),
                ),
                padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              child: const Text('LEFT'),
            ),
            const SizedBox(width: 3),
            ElevatedButton(
              onPressed: () => move('right'),
              style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll<Color>(Color(0xFFF57C00)),
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return const Color(0xFFFb8C00);
                    }
                    return Colors.transparent;
                  },
                ),
                textStyle: const MaterialStatePropertyAll<TextStyle>(
                  TextStyle(fontSize: 10),
                ),
                padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              child: const Text('RIGHT'),
            ),
            const SizedBox(width: 3),
            ElevatedButton(
              onPressed: () => move('down'),
              style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll<Color>(Color(0xFFF57C00)),
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return const Color(0xFFFb8C00);
                    }
                    return Colors.transparent;
                  },
                ),
                textStyle: const MaterialStatePropertyAll<TextStyle>(
                  TextStyle(fontSize: 10),
                ),
                padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              child: const Text('DOWN'),
            ),
          ],
        ),
        if (gameOver)
          AlertDialog(
            title: const Text('Game Over'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    grid = List.generate(4, (_) => List.filled(4, 0));
                    gameOver = false;
                    addRandomTile();
                    addRandomTile();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Restart'),
              ),
            ],
          ),
      ],
    );
  }
}
