public class Game {
  private final int MAX_TOWERS = 15;
  private final int WIDTH = 20, HEIGHT = 20;
  private int base_health;
  private int wave;
  private int currency;
  
  private boolean is_game_over;
  
  private Tower[] towers;
  private GridType[][] map;
  PVector enemy_spawn, base; // x is row num on map, y is col num
  
  public Game() {
    base_health = 0;
    wave = 0;
    currency = 0;
    
    is_game_over = false;
    
    towers = new Tower[MAX_TOWERS];
    init_map();
  }
  
  private void init_map() {
    map = new GridType[HEIGHT][WIDTH];
    enemy_spawn = new PVector(0, 0);
    base = new PVector(0, 0);
    
    // enemy spawn and base are along the width
    if ((int)random(2) == 1) {
      enemy_spawn.x = (int)random(WIDTH);
      base.x = (int)random(WIDTH);
      base.y = HEIGHT - 1;
    } else { // enemy spawn and base are along height
      enemy_spawn.y = (int)random(HEIGHT);
      base.y = (int)random(HEIGHT);
    }
  }
  
  public void draw_game() {
    
  }
  
  private void draw_towers() {
    
  }
  
  public void update() {
    
  }
  
  private void placeTower() {
    
  }
  
}
