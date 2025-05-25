public class Game {
  private final int MAX_TOWERS = 15;
  private final int GRID_LEN = 20;
  private final int SQ_SIZE = min(width, height) / GRID_LEN;
  private final PVector[] DIRECTIONS = { 
    new PVector(0, -1), new PVector(1, 0), new PVector(0, 1), new PVector(-1, 0)
  };
  
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
    map = new GridType[GRID_LEN][GRID_LEN];
    for (int i = 0; i < GRID_LEN; ++i) {
      for(int j = 0; j < GRID_LEN; ++j) {
        map[i][j] = GridType.EMPTY;
      }
    }
    
    enemy_spawn = new PVector(0, 0);
    base = new PVector(0, 0);
    
    // enemy spawn and base are along the width
    if ((int)random(2) == 1) {
      enemy_spawn.x = (int)random(GRID_LEN);
      base.x = (int)random(GRID_LEN);
      base.y = GRID_LEN - 1;
    } else { // enemy spawn and base are along height
      enemy_spawn.y = (int)random(GRID_LEN);
      base.y = (int)random(GRID_LEN);
      base.x = GRID_LEN - 1;
    }

    map[(int)enemy_spawn.y][(int)enemy_spawn.x] = GridType.ENEMY_SPAWN;
    map[(int)base.y][(int)base.x] = GridType.BASE;
    
    generate_enemy_path();
  }
  
  private void generate_enemy_path() {
    ArrayList<PVector> possible_dirs = new ArrayList<PVector>();
    for (PVector dir : DIRECTIONS) 
      possible_dirs.add(dir);

    if (base.y == GRID_LEN - 1) {
      possible_dirs.remove(DIRECTIONS[0]);
    } else if (base.x == GRID_LEN - 1) {
      possible_dirs.remove(DIRECTIONS[3]);
    }
    
    ArrayList<PVector> dirs = new ArrayList<PVector>(possible_dirs);

    PVector curr = enemy_spawn;
    PVector prev_move = null;
    while(curr.x != base.x || curr.y != base.y) {
      possible_dirs = new ArrayList<PVector>(dirs);
      if (curr.x == GRID_LEN - 1)
        possible_dirs.remove(DIRECTIONS[1]);

      if (curr.x == 0)
        possible_dirs.remove(DIRECTIONS[3]);

      if (curr.y == GRID_LEN - 1)
        possible_dirs.remove(DIRECTIONS[2]);

      if (curr.y == 0)
        possible_dirs.remove(DIRECTIONS[0]);

      if (prev_move != null)
        possible_dirs.remove(PVector.mult(prev_move, -1)); // don't move backwards
      
      // once against wall, go toward base  
      PVector dir = possible_dirs.get((int)random(possible_dirs.size()));
      if (possible_dirs.size() == 2) {
        PVector sum = PVector.add(possible_dirs.get(0), possible_dirs.get(1));
        if (sum.x == 0 && sum.y == 0) {
          PVector diff = PVector.sub(base, curr);
          dir = PVector.div(diff, max(abs(diff.x), abs(diff.y)));
        }
      }
      
      prev_move = new PVector(dir.x, dir.y);
      curr.add(dir);
      
      if (curr.x != base.x || curr.y != base.y)
        map[(int)curr.y][(int)curr.x] = GridType.ENEMY_PATH;
    }
  }
  
  public void draw_game() {
    draw_map();
    draw_towers();
  }

  private void draw_map() {
    int curr_x = 0, curr_y = 0;
    while (curr_y + SQ_SIZE <= height) {
      switch (map[curr_y / SQ_SIZE][curr_x / SQ_SIZE]) {
        case EMPTY: stroke(43, 143, 46); fill(43, 143, 46); break;
        case OCCUPIED: stroke(0); fill(0); break; // will be drawn by draw_towers() 
        case ENEMY_PATH: stroke(54, 43, 43); fill(54, 43, 43); break;
        case ENEMY_SPAWN: stroke(255, 0, 0); fill(255, 0, 0); break;
        case BASE: stroke(0, 0, 255); fill(0, 0, 255); break;
      }
      square(curr_x, curr_y, SQ_SIZE);
      
      if (curr_x + SQ_SIZE >= width) {
        curr_x = 0;
        curr_y += SQ_SIZE;
      } else {
        curr_x += SQ_SIZE;
      }
    }
  }
  
  private void draw_towers() {
    
  }
  
  public void update() {
    
  }
  
  private void placeTower() {
    
  }
  
}
