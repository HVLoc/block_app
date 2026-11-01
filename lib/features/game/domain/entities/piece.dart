class Piece {
  const Piece(this.matrix, this.colorIndex);
  final List<List<int>> matrix;
  final int colorIndex;

  int get rows => matrix.length;
  int get cols => matrix[0].length;
}
