import ddf.minim.*;

Minim minim;
AudioPlayer player;

// specifications
int BOARDWIDTH = 7, BOARDHEIGHT = 6;
int DIFFICULTY = 2;
int SPACESIZE = 50;
int FPS = 20;
int XMARGIN = (640 - BOARDWIDTH * SPACESIZE)/ 2, YMARGIN = (480 - BOARDHEIGHT * SPACESIZE) / 2;
int XREDPILE = int(SPACESIZE / 2);
int YREDPILE = 480 - int(3 * SPACESIZE / 2);
int XYELLOWPILE = 640 - int(3 * SPACESIZE / 2);
int YYELLOWPILE = 480 - int(3 * SPACESIZE / 2);

// variables
PImage backg, red, yellow, boardim, arrow, computer, human, tie, mainmenu, rules;
PFont orbitron, unicode;
Board board = new Board(BOARDHEIGHT, BOARDWIDTH); // human: 1, computer: -1

int column_g;
int xcor, ycor; // coordinates of the currently active tile
int step;
float speed, dropSpeed;

int beginning, end;
int turn; // human: 1, computer: -1
int pressed;
int gameScreen; // mainMenu: 0, game: 1, endGame: 2, rules: 3
boolean showHelp, isFirstGame;
boolean draggingToken, humanMove;
int tokenx, tokeny;
boolean mouseR;
int winner;
boolean win;
RectBtn playBtn, rulesBtn, quitBtn, easyBtn, mediumBtn, hardBtn, ppBtn;
int r, t; // r: rules, t==0: dark theme, t==1; light theme

void setup(){
  minim = new Minim(this);
   
  player = minim.loadFile("bgMusic.wav");
  player.loop();
  player.setVolume(50); 
  
  size(640, 480);
  frameRate(FPS);
  
  backg = loadImage("background.png");
  backg.resize(640, 480);
  red = loadImage("red.png");
  red.resize(SPACESIZE, SPACESIZE);
  yellow = loadImage("yellow.png");
  yellow.resize(SPACESIZE, SPACESIZE);
  boardim = loadImage("boardim.png");
  boardim.resize(SPACESIZE, SPACESIZE);
  
  arrow = loadImage("arrow.png");
  arrow.resize(int(SPACESIZE * 3.75),int(1.5 * SPACESIZE));
  computer = loadImage("computer.png");
  human = loadImage("human.png");
  tie = loadImage("tie.png");
  
  mainmenu = loadImage("mainmenu.png");
  mainmenu.resize(640, 480);
  rules = loadImage("rules.png");
  rules.resize(640, 480);
  
  orbitron = createFont("orbitron-light.otf", 25);
  unicode = createFont("BabelStoneHan.ttf", 30);
  
  isFirstGame = true;
  beginning = 1;
  end = 0;
  pressed = 0;
  gameScreen = 0;
  draggingToken = false;
  humanMove = false;
  mouseR = false;
  r = 0;
  win = false;
  
  playBtn = new RectBtn(150, 200, 160, 100, 185, 59, 50, 50, orbitron, "PLAY");
  rulesBtn = new RectBtn(320, 200, 160, 100, 185, 59, 50, 50, orbitron, "RULES");
  quitBtn = new RectBtn(490, 200, 160, 100, 185, 59, 50, 50, orbitron, "QUIT");
  easyBtn = new RectBtn(320, 330, 250, 35, 206, 66, 56, 355, 185, 59, 50, orbitron, "Easy");
  mediumBtn = new RectBtn(320, 375, 250, 35, 206, 66, 56, 255, 185, 59, 50, orbitron, "Medium");
  hardBtn = new RectBtn(320, 420, 250, 35, 206, 66, 56, 255, 185, 59, 50, orbitron, "Hard");
  ppBtn = new RectBtn(600, 20, 80, 40, 185, 59, 50, 50, unicode, "\u23F8");

  rectMode(CENTER);
  textAlign(CENTER, CENTER);
}

void draw(){
  if (gameScreen == 0){
    background(mainmenu);

    playBtn.drawBtn();
    rulesBtn.drawBtn();
    quitBtn.drawBtn();
    easyBtn.drawBtn();
    mediumBtn.drawBtn();
    hardBtn.drawBtn();
    ppBtn.drawBtn();

    fill(0,0,0,0);
    if (overCircle(40, 423, 62)) stroke(255);
    else noStroke();
    ellipse(40, 423, 62, 62);
    if (overCircle(108, 423, 62)) stroke(0);
    else noStroke();
    ellipse(108, 423, 62, 62);

    if (mousePressed){
      if (easyBtn.isOverBtn()) DIFFICULTY = 1;
      else if (mediumBtn.isOverBtn()) DIFFICULTY = 2;
      else if (hardBtn.isOverBtn()) DIFFICULTY = 3;
      else if (playBtn.isOverBtn()) gameScreen = 1;
      else if (rulesBtn.isOverBtn()) gameScreen = 3;
      else if (quitBtn.isOverBtn()) exit();
      else if (overCircle(40, 423, 62)){
        darkTheme(); 
        t = 0;
      }
      else if (overCircle(108, 423, 62)){
        lightTheme();
        t = 1;
      }
    }
  }
  
  if (gameScreen == 1 || gameScreen == 2){
    background(backg);
    ppBtn.drawBtn();
    drawTile(xcor,ycor,turn);
    board.drawBoard(XMARGIN, YMARGIN, SPACESIZE, red, yellow, boardim);
    
    if (showHelp) image(arrow, int(SPACESIZE / 2) + SPACESIZE, 470 - int(3 * SPACESIZE / 2));
  }
  
  if (gameScreen == 1){
    if (beginning == 1){
      if (isFirstGame){
        turn = -1; // computer: -1
        showHelp = true;
      }
      else {
        if (round(random(0,1)) == 0) turn = -1;
        else turn = 1;
        showHelp = false;
      }
    
      board.reset();
      step = 0;
      if(turn == 1){
        xcor = XREDPILE;
        ycor = YREDPILE;
      }
      else{
        xcor = XYELLOWPILE;
        ycor = YYELLOWPILE;
      }
      beginning = 0;
    }
    
    if(turn == 1){ // human
      humanMove = true;
      
      if(t == 0) fill(246, 27, 31);
      else fill(80, 7, 45);
      text("Your turn!", 320, 40);
      
      if (step == 0){
          if (mousePressed && draggingToken == false && mouseX > XREDPILE && mouseX < XREDPILE + SPACESIZE
          && mouseY > YREDPILE && mouseY < YREDPILE + SPACESIZE){
          // start of dragging on red token pile
            draggingToken = true;
            xcor = mouseX - SPACESIZE / 2;
            ycor = mouseY - SPACESIZE / 2;
           }
          if (mouseR){
            column_g = (int)((xcor + SPACESIZE / 2 - XMARGIN) / SPACESIZE);
            if (board.isValidMove(column_g)){
              dropSpeed = 1.0;
              step = 1;
            }
          }
      }
      else if (step == 1){
        draggingToken = false;
        mouseR = false;  
      
        int row = board.getLowestEmptySpace(column_g);
      
        if(int((ycor + int(dropSpeed) - YMARGIN) / SPACESIZE) < row){
          ycor += int(dropSpeed);
          dropSpeed += 0.5;
        }
        else step = 2;
      }
      else if (step == 2){
        board.makeMove(1, column_g);
        showHelp = false;
        if (board.isWinner(1)){
          winner = 1;
          gameScreen = 2; // RESTART
          win = true;
        }
        turn =- 1;
        humanMove = false;
        xcor = XYELLOWPILE;
        ycor = YYELLOWPILE;
        step = 0;
      }
    }
    else{ // computer
      textFont(orbitron);
      if(t == 0) fill(246, 27, 31);
      else fill(80, 7, 45);
      text("Computer's turn!", 320, 40);
    
      if (step == 0){
        column_g = getComputerMove(DIFFICULTY);
        dropSpeed = 1.0;
        speed = 1.0;
        xcor = XYELLOWPILE;
        ycor = YYELLOWPILE;
        step = 1;
      }
      else if (step == 1){  
        if (ycor > (YMARGIN - SPACESIZE)){
          speed += 0.1;
          ycor -= int(speed);
        }
        else step = 2;
      }
      else if (step == 2){
        if (xcor > (XMARGIN + column_g * SPACESIZE + 10)){
          xcor -= int(speed);
          speed += 0.1;
        }
        else {
          xcor = XMARGIN + column_g * SPACESIZE; 
          step = 3;
        }
      }
      else if (step == 3){
        int row = board.getLowestEmptySpace(column_g);

        if (int((ycor + int(dropSpeed) - YMARGIN) / SPACESIZE) < row){
          ycor += int(dropSpeed);
          dropSpeed += 0.5;
        }
        else step = 4;
      }
      else if (step == 4){
        board.makeMove(-1, column_g);
        if (board.isWinner(-1)){
          winner = -1;
          gameScreen = 2; // RESTART
          win = true;
        }
        turn = 1;
        step = 0;
        xcor = XREDPILE;
        ycor = YREDPILE;
      }
    }
  
    if (!win && board.isBoardFull()){
      winner = 0;
      gameScreen = 2; // RESTART
    }
  }
  
    if(gameScreen == 2){
      ppBtn.drawBtn();
      isFirstGame = false;
      imageMode(CENTER);
      if (winner == 1) image(human, 640 / 2, 480 / 2);
      else if (winner == -1) image(computer, 640/2, 480 / 2);
      else image(tie, 640 / 2, 480 / 2);
      imageMode(CORNER);
      win = false;
    }
  
  if(gameScreen == 3){
    background(rules);
    ppBtn.drawBtn();
    r++;
  }
}

boolean overCircle(int x, int y, int diameter){
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter / 2 ) return true;
  return false;
}

void mouseClicked(){
  if (gameScreen == 2){
    beginning = 1;
    gameScreen = 0;
  }
  else if (gameScreen == 3 && r > 5){
    gameScreen = 0;
    r = 0;
  }
}

void darkTheme(){
  backg = loadImage("background.png");
  backg.resize(640, 480);
  red = loadImage("red.png");
  red.resize(SPACESIZE, SPACESIZE);
  yellow = loadImage("yellow.png");
  yellow.resize(SPACESIZE, SPACESIZE);
  boardim = loadImage("boardim.png");
  boardim.resize(SPACESIZE, SPACESIZE);
}

void lightTheme(){
  backg = loadImage("backgroundl.png");
  backg.resize(640, 480);
  red = loadImage("greenl.png");
  red.resize(SPACESIZE, SPACESIZE);
  yellow = loadImage("violet.png");
  yellow.resize(SPACESIZE, SPACESIZE);
  boardim = loadImage("boardl.png");
  boardim.resize(SPACESIZE, SPACESIZE);
}

void drawTile(int x, int y, int player){
  if (player == -1) image(yellow, x, y);
  else image(red, x, y);
}

void mouseDragged(){
  if (humanMove && draggingToken){
    xcor = mouseX - SPACESIZE / 2;
    ycor = mouseY - SPACESIZE / 2;
  }
}

void mouseReleased(){
  if (humanMove && draggingToken) mouseR = true;
  else if (ppBtn.isOverBtn()) {
    if (player.isPlaying()){
      player.pause();
      ppBtn.setLabel("\u25B6");
    }
    else {
      player.loop();
      ppBtn.setLabel("\u23F8");
    }
  }
}

int getComputerMove(int diff){
  int[] potentialMoves = getPotentialMoves(board, -1, diff);
  int bestMoveFitness =- 1, i;
  for (i = 0; i < BOARDWIDTH; ++i)
    if (potentialMoves[i] > bestMoveFitness && board.isValidMove(i)) bestMoveFitness = potentialMoves[i];
  

  IntList bestMoves = new IntList();
  for (i = 0; i < potentialMoves.length; ++i)
    if (potentialMoves[i] == bestMoveFitness && board.isValidMove(i)) bestMoves.append(i);
  int choice = round(random(bestMoves.size() - 1));
  return bestMoves.array()[choice];
}

int[] getPotentialMoves(Board board, int player, int diff){
  int w = board.getW();
  int[] potentialMoves = new int[w];
  
  for (int i = 0; i < w; ++i) potentialMoves[i] = 0;
  if (diff == 0 || board.isBoardFull()) return potentialMoves;
  
  int enemy = player == 1 ? -1 : 1;
    
  for (int firstMove = 0; firstMove < w; ++firstMove){
    Board dupeBoard = new Board(board);
    if (!dupeBoard.isValidMove(firstMove)) continue;
    dupeBoard.makeMove(player, firstMove);
    if (dupeBoard.isWinner(player)){
      potentialMoves[firstMove] = 1;
      break;
    }
    else{
      if (dupeBoard.isBoardFull()) potentialMoves[firstMove] = 0;
      else {
        for (int counterMove = 0; counterMove < w; ++counterMove){
          Board dupeBoard2 = new Board(dupeBoard);
          if (!dupeBoard2.isValidMove(counterMove)) continue;
          dupeBoard2.makeMove(enemy, counterMove);
          if (dupeBoard2.isWinner(enemy)){
            potentialMoves[firstMove] = -1;
            break;
          }
          else {
            int[] results = getPotentialMoves(dupeBoard2, player, diff - 1);
            int sum = 0;
            for (int j = 0; j < w; ++j) sum += results[j];
            potentialMoves[firstMove] += (sum / w) / w;
          }
        }
      }
    }
  }
  return potentialMoves;
}
