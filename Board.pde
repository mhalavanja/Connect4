class Board {
  
  private int w; //boardWidth but Processing is not autocompleting words so..
  private int h; //boardHeight
  private int[][] boardArr;
  
  public int getW(){ return w; }
  public void setW(int w){ this.w = w; }
  public int getH(){ return h; }
  public void setH(int h){ this.h = h; }
  public int[][] getBoard(){ return boardArr; }
  
  public Board(){}
  
  public Board(int h, int w){
    this.h = h;
    this.w = w;
    this.boardArr = new int[h][w];
  }
  
  public Board(Board board){
    this(board.getH(), board.getW());
    for (int j=0; j < w; ++j){
      for (int i=0; i < h; ++i)
        boardArr[i][j] = board.getBoard()[i][j];
    }
  }

  // return the row number of the lowest empty row in the given column
  public int getLowestEmptySpace(int column)
  {
    for(int i = h - 1; i >= 0; --i){
      if (boardArr[i][column] == 0) return i;
    }
    return -1;
  }

  public boolean isBoardFull()
  {
    for(int j = 0; j < w; ++j){
        if(boardArr[0][j] == 0) return false;
      }
    return true;
  }
  
  public void drawBoard(int XMARGIN, int YMARGIN, int SPACESIZE, PImage red, PImage yellow, PImage boardim)
  {
    int x = XMARGIN, y = YMARGIN;
    for (int j = 0; j < w; ++j){
      for (int i = 0; i < h; ++i){
        if (boardArr[i][j] == 1) image(red, x, y);
        else if (boardArr[i][j] == -1) image(yellow, x, y);
        image(boardim, x, y);
        y += SPACESIZE;
      }
      y = YMARGIN;
      x += SPACESIZE;
    }
    image(red, XREDPILE, YREDPILE);
    image(yellow, XYELLOWPILE, YYELLOWPILE);
  }
  
  public void reset(){
    for (int j=0; j < w; ++j){
      for (int i=0; i < h; ++i)
        boardArr[i][j]=0;
    }
  }
  
  public boolean isWinner(int player){
    for(int i = 0; i < h; ++i){
      for(int j = 0; j < w; ++j){
        if (boardArr[i][j] == player){
          // check vertical spaces
          if (i + 3 < h && boardArr[i+1][j] == player && boardArr[i+2][j] == player && boardArr[i+3][j] == player)
            return true;
          // check horizontal spaces
          else if (j + 3 < w && boardArr[i][j+1] == player && boardArr[i][j+2] == player && boardArr[i][j+3] == player)
            return true;
          // check / diagonal spaces
          else if (i - 3 > 0 && j + 3 < w && boardArr[i-1][j+1] == player && boardArr[i-2][j+2] == player && boardArr[i-3][j+3] == player)
            return true;
          // check \ diagonal spaces
          else if (i + 3 < h && j + 3 < w && boardArr[i+1][j+1] == player && boardArr[i+2][j+2] == player && boardArr[i+3][j+3] == player)
            return true;
        }
      }
    }
    return false;
  }
  
  public boolean isValidMove(int column){
    if (column < 0 || column >= w || boardArr[0][column] != 0) return false;
    return true;
  }
  
  public void makeMove(int player, int column){
    int lowest = getLowestEmptySpace(column);
    if (lowest != -1) boardArr[lowest][column] = player;
  }
}
