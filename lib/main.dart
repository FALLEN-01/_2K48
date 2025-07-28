import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const Game2048(),
    );
  }
}

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  int gridSize = 4; // Default to 4x4
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  bool gameOver = false;
  bool won = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    score = 0;
    gameOver = false;
    won = false;
    _addRandomTile();
    _addRandomTile();
  }

  void _changeGridSize(int newSize) {
    gridSize = newSize;
    grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    score = 0;
    gameOver = false;
    won = false;
    _addRandomTile();
    _addRandomTile();
  }

  double _getGridSize() {
    switch (gridSize) {
      case 4:
        return 320;
      case 6:
        return 360;
      case 8:
        return 400;
      case 10:
        return 440;
      default:
        return 320;
    }
  }

  double _getFontSize(int value) {
    double baseFontSize;
    switch (gridSize) {
      case 4:
        baseFontSize = value >= 1000 ? 20 : 28;
        break;
      case 6:
        baseFontSize = value >= 1000 ? 16 : 22;
        break;
      case 8:
        baseFontSize = value >= 1000 ? 14 : 18;
        break;
      case 10:
        baseFontSize = value >= 1000 ? 12 : 16;
        break;
      default:
        baseFontSize = value >= 1000 ? 20 : 28;
    }
    return baseFontSize;
  }

  void _addRandomTile() {
    List<Point<int>> emptyCells = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) {
          emptyCells.add(Point(i, j));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final random = Random();
      final cell = emptyCells[random.nextInt(emptyCells.length)];
      grid[cell.x][cell.y] = random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool _canMove() {
    // Check for empty cells
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) return true;
      }
    }

    // Check for possible merges
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (j < gridSize - 1 && grid[i][j] == grid[i][j + 1]) return true;
        if (i < gridSize - 1 && grid[i][j] == grid[i + 1][j]) return true;
      }
    }

    return false;
  }

  void _moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = grid[i].where((cell) => cell != 0).toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          row[j] *= 2;
          score += row[j];
          if (row[j] == 2048 && !won) {
            won = true;
            Future.microtask(() => _showWinDialog());
          }
          row.removeAt(j + 1);
        }
      }
      while (row.length < gridSize) {
        row.add(0);
      }

      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] != row[j]) moved = true;
        grid[i][j] = row[j];
      }
    }

    if (moved) {
      _addRandomTile();
      if (!_canMove()) {
        gameOver = true;
        Future.microtask(() => _showGameOverDialog());
      }
      setState(() {});
    }
  }

  void _moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = grid[i].where((cell) => cell != 0).toList();
      for (int j = row.length - 1; j > 0; j--) {
        if (row[j] == row[j - 1]) {
          row[j] *= 2;
          score += row[j];
          if (row[j] == 2048 && !won) {
            won = true;
            Future.microtask(() => _showWinDialog());
          }
          row.removeAt(j - 1);
          j--;
        }
      }
      while (row.length < gridSize) {
        row.insert(0, 0);
      }

      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] != row[j]) moved = true;
        grid[i][j] = row[j];
      }
    }

    if (moved) {
      _addRandomTile();
      if (!_canMove()) {
        gameOver = true;
        Future.microtask(() => _showGameOverDialog());
      }
      setState(() {});
    }
  }

  void _moveUp() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> column = [];
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != 0) column.add(grid[i][j]);
      }

      for (int i = 0; i < column.length - 1; i++) {
        if (column[i] == column[i + 1]) {
          column[i] *= 2;
          score += column[i];
          if (column[i] == 2048 && !won) {
            won = true;
            Future.microtask(() => _showWinDialog());
          }
          column.removeAt(i + 1);
        }
      }
      while (column.length < gridSize) {
        column.add(0);
      }

      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != column[i]) moved = true;
        grid[i][j] = column[i];
      }
    }

    if (moved) {
      _addRandomTile();
      if (!_canMove()) {
        gameOver = true;
        Future.microtask(() => _showGameOverDialog());
      }
      setState(() {});
    }
  }

  void _moveDown() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> column = [];
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != 0) column.add(grid[i][j]);
      }

      for (int i = column.length - 1; i > 0; i--) {
        if (column[i] == column[i - 1]) {
          column[i] *= 2;
          score += column[i];
          if (column[i] == 2048 && !won) {
            won = true;
            Future.microtask(() => _showWinDialog());
          }
          column.removeAt(i - 1);
          i--;
        }
      }
      while (column.length < gridSize) {
        column.insert(0, 0);
      }

      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != column[i]) moved = true;
        grid[i][j] = column[i];
      }
    }

    if (moved) {
      _addRandomTile();
      if (!_canMove()) {
        gameOver = true;
        Future.microtask(() => _showGameOverDialog());
      }
      setState(() {});
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 You Win!'),
          content: const Text(
            'You reached 2048! Continue playing or start a new game.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('💀 Game Over'),
          content: Text('Final Score: $score\nTry again?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.grey[300]!;
      case 2:
        return Colors.grey[100]!;
      case 4:
        return Colors.grey[200]!;
      case 8:
        return Colors.orange[200]!;
      case 16:
        return Colors.orange[300]!;
      case 32:
        return Colors.orange[400]!;
      case 64:
        return Colors.orange[500]!;
      case 128:
        return Colors.orange[600]!;
      case 256:
        return Colors.orange[700]!;
      case 512:
        return Colors.orange[800]!;
      case 1024:
        return Colors.orange[900]!;
      case 2048:
        return Colors.red[600]!;
      default:
        return Colors.red[800]!;
    }
  }

  Color _getTextColor(int value) {
    return value <= 4 ? Colors.grey[700]! : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('2048'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Grid size dropdown in navbar right side
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<int>(
              value: gridSize,
              dropdownColor: Colors.orange[600],
              underline: const SizedBox(),
              icon: const Icon(Icons.grid_view, color: Colors.white),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              items: const [
                DropdownMenuItem<int>(
                  value: 4,
                  child: Text('4x4', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<int>(
                  value: 6,
                  child: Text('6x6', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<int>(
                  value: 8,
                  child: Text('8x8', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<int>(
                  value: 10,
                  child: Text('10x10', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _changeGridSize(newValue);
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Score and New Game button row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // New Game button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'New Game',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Game instructions
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Swipe to move tiles. When two tiles with the same number touch, they merge into one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 10),

          // Game Grid
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onPanEnd: (details) {
                    if (gameOver) return;

                    final velocity = details.velocity.pixelsPerSecond;
                    final dx = velocity.dx;
                    final dy = velocity.dy;

                    if (dx.abs() > dy.abs()) {
                      if (dx > 0) {
                        _moveRight();
                      } else {
                        _moveLeft();
                      }
                    } else {
                      if (dy > 0) {
                        _moveDown();
                      } else {
                        _moveUp();
                      }
                    }
                  },
                  child: SizedBox(
                    width: _getGridSize(),
                    height: _getGridSize(),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: gridSize >= 8 ? 4 : 8,
                        mainAxisSpacing: gridSize >= 8 ? 4 : 8,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        final i = index ~/ gridSize;
                        final j = index % gridSize;
                        final value = grid[i][j];

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: _getTileColor(value),
                            borderRadius: BorderRadius.circular(
                              gridSize >= 8 ? 2 : 4,
                            ),
                          ),
                          child: Center(
                            child: value == 0
                                ? null
                                : Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: _getFontSize(value),
                                      fontWeight: FontWeight.bold,
                                      color: _getTextColor(value),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Controls hint
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Swipe in any direction to move tiles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
