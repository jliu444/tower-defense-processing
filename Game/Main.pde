Game game;

void setup() {
  size(1400, 1000);
  frameRate(60);
  game = new Game();
}

void draw() {
  background(255);
  
  if (game.restarted)
    game = new Game();

  game.update();
  game.draw_game();
  game.set_mouse_clicked(false);
  game.set_key_released(false);
}

void keyPressed() {

}

void keyReleased() {
  game.set_key_released(true);

  if (key == 'r' || key == 'R')
    game = new Game();
}

void mouseClicked() {
  game.set_mouse_clicked(true);
}
