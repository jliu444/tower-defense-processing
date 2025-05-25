Game game;

void setup() {
  size(1000, 1000);
  game = new Game();
}

void draw() {
  background(0);
  //game.update();

  game.draw_game();
}

void keyPressed() {
  
}
