 Game game;

void setup() {
  size(1400, 1000);
  frameRate(60);
  game = new Game();
}

void draw() {
  background(255);
  game.draw_game();
  game.update();
}

void keyPressed() {
  
}

void mouseClicked() {
  game.set_mouse_clicked(true);
}
