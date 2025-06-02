import java.util.Arrays;
import java.util.Stack;
import java.util.Collections;
import java.util.Map;
import java.util.Queue;
import java.util.LinkedList;

public class Game {
  private final int MAX_TOWERS = 15;
  private final int MAX_ENEMIES = 100;
  private final int SIDE_BAR_LEN = 400;
  private final int GRID_LEN = 20;
  private final int SQ_SIZE = min(width - SIDE_BAR_LEN, height) / GRID_LEN;
  private final PVector[] DIRECTIONS = { 
    new PVector(0, -1), // north
    new PVector(1, 0), // east
    new PVector(0, 1), // south
    new PVector(-1, 0) // west
  };
  
  private final PImage SHOP_LEFT_TEX = loadImage("images/left_arrow.png");
  private final PImage SHOP_RIGHT_TEX = loadImage("images/right_arrow.png");
  private final PImage BUY_TEX = loadImage("images/buy.png");
  private final PImage CANCEL_TEX = loadImage("images/cancel.png");
  private final PImage MACHINE_GUN_TEX = loadImage("images/machine_gun_tower.png");
  private final PImage LAZER_TEX = loadImage("images/laser_tower.png");
  private final PImage SLIME_TEX = loadImage("images/slime.png");
  private final PImage BLUE_SLIME_TEX = loadImage("images/blue_slime.png");
  private final PImage NINJA_SLIME_TEX = loadImage("images/ninja_slime.png");
  private final PImage KING_SLIME_TEX = loadImage("images/king_slime.png");
  private final PImage RESTART_TEX = loadImage("images/restart.png");

  private final int SECOND = 1000; // milliseconds in a second

  private int start_time;
  private int prev_frame_time, curr_frame_time;
  private int time_to_next_wave;

  private int time_at_last_spawn;
  private float spawn_rate;

  private boolean mouse_clicked;

  private boolean is_placing_tower; 
  private Tower tower_being_placed;

  private Button shop_left, shop_right, buy;
  private int curr_tower_idx;
  
  private float base_health;
  private int wave;
  private int cash;
  
  private ArrayList<Tower> active_towers;
  private ArrayList<Enemy> enemies;
  private GridType[][] map;
  
  private Map<PVector, PVector> pos_to_dir;

  private Tower[] shop_towers;
  private Enemy[] enemy_types;

  private PVector enemy_spawn, base; // x is row num on map, y is col num

  private Tower stats_to_display;

  // game stats
  private int kills, lifetime_cash;
  private float dmg_taken, dmg_dealt;
  private Button restart;
  private boolean restarted;
  
  public Game() {
    prev_frame_time = 0;
    curr_frame_time = millis();

    time_at_last_spawn = 0;
    spawn_rate = 0;

    mouse_clicked = false;

    is_placing_tower = false;
    tower_being_placed = null;

    shop_left = new Button(width - 350, 625, 50, 50, 
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           SHOP_LEFT_TEX);

    shop_right = new Button(width - 100, 625, 50, 50, 
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           SHOP_RIGHT_TEX);
                           
    buy = new Button(width - 250, 625, 100, 50, 
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           BUY_TEX);
                          
    restart = new Button(width / 2 - 50, 605, 100, 100,
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           RESTART_TEX);

    curr_tower_idx = 0;

    base_health = 100.0;
    wave = 0;
    cash = 100;
    
    active_towers = new ArrayList<Tower>();

    enemies = new ArrayList<Enemy>();

    kills = 0;
    lifetime_cash = 0;
    dmg_taken = 0;
    dmg_dealt = 0;
    restarted = false;

    final PVector zero = new PVector(0, 0);
    shop_towers = new Tower[2];
    shop_towers[0] = new Tower(5.0, 2, 100, zero, 150, MACHINE_GUN_TEX);
    shop_towers[1] = new Tower(12.0, 100, 100, zero, 300, LAZER_TEX);

    enemy_types = new Enemy[4];
    enemy_types[0] = new Enemy(24.0, 5.0, .1, zero, zero, SLIME_TEX, 25, SQ_SIZE);
    enemy_types[1] = new Enemy(50.0, 10.0, .11, zero, zero, BLUE_SLIME_TEX, 40, SQ_SIZE);
    enemy_types[2] = new Enemy(30.0, 7.5, .15, zero, zero, NINJA_SLIME_TEX, 40, SQ_SIZE);
    enemy_types[3] = new Enemy(100.0, 25.0, .08, zero, zero, KING_SLIME_TEX, 100, SQ_SIZE);

    stats_to_display = null;

    init_map();

    generate_path_dirs();

    start_time = millis();
  }
  
  private void init_map() {
    map = new GridType[GRID_LEN][GRID_LEN];
    for (GridType[] row : map)
      Arrays.fill(row, GridType.EMPTY);
    
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

    if (base.y == GRID_LEN - 1) possible_dirs.remove(DIRECTIONS[0]);
    else if (base.x == GRID_LEN - 1) possible_dirs.remove(DIRECTIONS[3]);
    
    ArrayList<PVector> dirs = new ArrayList<PVector>(possible_dirs);

    PVector curr = new PVector(enemy_spawn.x, enemy_spawn.y);
    PVector prev_move = null;

    while(curr.x != base.x || curr.y != base.y) {
      possible_dirs = new ArrayList<PVector>(dirs);

      if (curr.x == GRID_LEN - 1) possible_dirs.remove(DIRECTIONS[1]);
      if (curr.x == 0) possible_dirs.remove(DIRECTIONS[3]);
      if (curr.y == GRID_LEN - 1) possible_dirs.remove(DIRECTIONS[2]);
      if (curr.y == 0) possible_dirs.remove(DIRECTIONS[0]);

      if (prev_move != null) possible_dirs.remove(PVector.mult(prev_move, -1)); // don't move backwards
      
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
  
  private void generate_path_dirs() {
    Queue<PVector> st = new LinkedList<PVector>();
    st.add(new PVector(enemy_spawn.x, enemy_spawn.y));

    Map<PVector, PVector> parent = new HashMap<PVector, PVector>();
    parent.put(new PVector(enemy_spawn.x, enemy_spawn.y), null);

    boolean[][] visited = new boolean[map.length][map[0].length];
    for (boolean[] arr : visited)
      Arrays.fill(arr, false);

    visited[(int)enemy_spawn.y][(int)enemy_spawn.x] = true;

    pos_to_dir = new HashMap<PVector, PVector>();

    while (!st.isEmpty()) {
      PVector pos = st.poll();

      if (pos.x == base.x && pos.y == base.y) {
        PVector curr = pos;

        while (parent.get(curr) != null) {
          PVector dir = PVector.sub(curr, parent.get(curr));
          pos_to_dir.put(parent.get(curr), dir);
          curr = parent.get(curr);
        }

        return;
      }

      for (PVector dir : DIRECTIONS) {
        PVector new_pos = PVector.add(pos, dir);
        if (is_valid_pos(new_pos) &&
            !visited[(int)new_pos.y][(int)new_pos.x] &&
            (map[(int)new_pos.y][(int)new_pos.x] == GridType.ENEMY_PATH ||
            map[(int)new_pos.y][(int)new_pos.x] == GridType.BASE)) {

          visited[(int)new_pos.y][(int)new_pos.x] = true;
          st.add(new_pos);
          parent.put(new_pos, pos);
        } 
      }
    }
  }
  
  public void draw_game() {
    prev_frame_time = curr_frame_time;
    curr_frame_time = millis();


    draw_map();
    draw_towers();
    display_tower_stats();
    draw_enemies();
    draw_UI();
  }

  private void draw_map() {
    int curr_x = 0, curr_y = 0;

    while (curr_y + SQ_SIZE <= height) {
      switch (map[curr_y / SQ_SIZE][curr_x / SQ_SIZE]) {
        case EMPTY:
        case OCCUPIED: 
          if(is_placing_tower) stroke(55, 32);
          else stroke(43, 143, 46); 

          fill(43, 143, 46);
          break; // will be drawn by draw_towers() 
        case ENEMY_PATH: stroke(54, 43, 43); fill(54, 43, 43); break;
        case ENEMY_SPAWN: stroke(255, 0, 0); fill(255, 0, 0); break;
        case BASE: stroke(0, 0, 255); fill(0, 0, 255); break;
      }

      square(curr_x, curr_y, SQ_SIZE);
      
      if (curr_x + SQ_SIZE >= width - SIDE_BAR_LEN) {
        curr_x = 0;
        curr_y += SQ_SIZE;
      } else {
        curr_x += SQ_SIZE;
      }
    }
  }
  
  private void draw_towers() {
    for (Tower t : active_towers)
      t.draw_tower();
  }

  private void draw_enemies() {
    for (Enemy e : enemies)
      e.draw_enemy();
  }

  private void draw_UI() {
    textSize(50);
    fill(0);
    textAlign(RIGHT);
    text("Cash: $" + cash, width - 50, 50);
    text("HP: " + base_health, width - 50, 100);
    text("Wave: " + wave, width - 50, 150);

    if (!is_game_over()) {
      time_to_next_wave = (wave == 0 ? (5 * SECOND - (millis() - start_time) % (5 * SECOND)) / SECOND
                                     : (20 * SECOND - (millis() - start_time - 5 * SECOND) % (20 * SECOND)) / SECOND);
    }
    text("Next wave in: " + time_to_next_wave, width - 50, 200);

    draw_shop();
  }

  private void draw_shop() {
    shop_left.draw_button();
    shop_right.draw_button();
    buy.draw_button();

    Tower t = shop_towers[curr_tower_idx];

    fill(0);
    rect(width - 350, 300, 300, 300);
    image(t.get_texture_large(), width - 350, 300);

    textAlign(CENTER);
    textSize(32);

    if (cash < t.get_price())
      fill(255, 0, 0);
    else
      fill(0);

    text("Price: $" + t.get_price(), width - 200, 280);

  }

  private void display_tower_stats() {
    if (stats_to_display == null)
      return;


    PVector pos = stats_to_display.get_position();
    float left = pos.x - 15;
    float top = pos.y - 60;

    fill(255);
    textAlign(LEFT);
    textSize(16);
    
    text("Power: " + stats_to_display.get_power(), left, top);
    text("Firerate: " + stats_to_display.get_fire_rate() + " atks/s", left, top + 15); 
    text("DPS: " + stats_to_display.get_power() * stats_to_display.get_fire_rate(), left, top + 30); 
    text("Range: " + stats_to_display.get_range() + " px", left, top + 45);

    noStroke();
    fill(255, 32);
    circle(pos.x + 25, pos.y + 25, stats_to_display.get_range() * 2);
  }

  public void update() {
    if (is_game_over()) {
      game_over();
      return;
    }

    update_wave();
    // fix spawn rate
    if (wave > 0 && (millis() - time_at_last_spawn) >= 1000 / spawn_rate)
      spawn_enemy();

    update_towers();
    update_enemies();
    update_buttons();

    if (is_placing_tower) {
      place_tower();
    }
  }

  private void update_wave() {
    if (wave == 0 && millis() - start_time >= 5 * SECOND) {
      ++wave;
      spawn_rate = .2;
    }

    else if (millis() - start_time >= 5 * SECOND && (millis() - start_time - 5 * SECOND) / (20 * SECOND) == wave) {
      ++wave;
      spawn_rate *= 2;
    }
  }

  private void spawn_enemy() {
    int available_types = 1;
    if (wave >= 3)
      ++available_types;
    if (wave >= 5)
      ++available_types;
    if (wave >= 7)
      ++available_types;

    Enemy to_spawn = new Enemy(enemy_types[(int)random(available_types)]);
    to_spawn.set_position(PVector.mult(enemy_spawn, SQ_SIZE));
    to_spawn.set_direction(pos_to_dir.get(to_spawn.get_position_idx(SQ_SIZE)));
    enemies.add(to_spawn);
    
    time_at_last_spawn = millis();
  }

  private void update_towers() {
    for (Tower t : active_towers) {
      if (t.get_target() == null)
        t.lock_to_enemy(enemies);
      else if (t.attack_target())
          dmg_dealt += t.get_power();

      if (mouse_clicked && t.mouse_in_tower()) {
        if (stats_to_display == t)
          stats_to_display = null;
        else
          stats_to_display = t;
      }

      t.update_tower();
    }
  }

  private void update_enemies() {
    for (int i = 0; i < enemies.size(); ++i) {
      Enemy e = enemies.get(i);
      if (e.get_health() <= 0) {
        enemies.remove(e);
        cash += e.get_value();
        lifetime_cash += e.get_value();
        ++kills;
      }

      if (e.is_attacking() && millis() - e.get_time_at_last_attack() >= 1 * SECOND) {
        e.attack();
        base_health -= e.get_power();
        dmg_taken += e.get_power();
        continue;
      }
      PVector pos = PVector.div(e.get_position(), SQ_SIZE);
      PVector pos_idx = e.get_position_idx(SQ_SIZE);
      
      if (abs(pos.x - pos_idx.x) < .1 && abs(pos.y - pos_idx.y) < .1) {
          if (pos_idx.x == base.x && pos_idx.y == base.y) {
            e.set_attacking(true);
          }

          e.set_direction(pos_to_dir.get(pos_idx));
      }

      e.update_enemy(curr_frame_time - prev_frame_time);
    }
  }

  private void update_buttons() {
    if (mouse_clicked && buy.mouse_in_button() && !is_placing_tower) {
      is_placing_tower = true;
      buy.set_texture(CANCEL_TEX);
      tower_being_placed = new Tower(shop_towers[curr_tower_idx]);
    } else if (mouse_clicked && buy.mouse_in_button() && is_placing_tower) {
      is_placing_tower = false;
      buy.set_texture(BUY_TEX);
      tower_being_placed = null;
    }

    if (mouse_clicked && shop_left.mouse_in_button())
      curr_tower_idx = (curr_tower_idx - 1 + shop_towers.length) % shop_towers.length; 
    
    if (mouse_clicked && shop_right.mouse_in_button())
      curr_tower_idx = (curr_tower_idx + 1) % shop_towers.length;
  }
  
  private void place_tower() {
    PVector tower_pos = snap_to_grid(
      new PVector(mouseX - SQ_SIZE / 2, mouseY - SQ_SIZE / 2)
    );

    int row_idx = (int)tower_pos.y / SQ_SIZE;
    int col_idx = (int)tower_pos.x / SQ_SIZE;

    if (row_idx >= 0 && row_idx < map.length && col_idx >= 0 && col_idx < map[0].length) { 
      GridType curr_grid = map[row_idx][col_idx];

      if (curr_grid != GridType.EMPTY || cash < tower_being_placed.get_price())
        tint(209, 8, 28, 128);
      else
        tint(255, 128);

      image(tower_being_placed.get_texture_small(), tower_pos.x, tower_pos.y);
      noStroke();
      fill(255, 32);
      circle(tower_pos.x + 25, tower_pos.y + 25, tower_being_placed.get_range() * 2);
      tint(255, 255);

      if (mouse_clicked && curr_grid == GridType.EMPTY && cash >= tower_being_placed.get_price()) {
        is_placing_tower = false;
        buy.set_texture(BUY_TEX);
        cash -= tower_being_placed.get_price();
        active_towers.add(tower_being_placed);
        active_towers.get(active_towers.size() - 1).set_position(tower_pos);
        map[row_idx][col_idx] = GridType.OCCUPIED;
        tower_being_placed = null;
      }
    }
  }

  private PVector snap_to_grid(PVector pos) {
    return new PVector(
      SQ_SIZE * round(pos.x / SQ_SIZE), 
      SQ_SIZE * round(pos.y / SQ_SIZE)
    );
  }

  private boolean is_game_over() {
    return base_health <= 0;
  }

  private void game_over() {
    fill(88, 124, 214);
    rect(350, 250, 700, 470);

    fill(255);
    textAlign(CENTER);
    textSize(64);
    text("Game Over!", width / 2, 320);
    textSize(32);
    text("Total Kills: " + kills, width / 2, 390);
    text("Cash Earned: $" + lifetime_cash, width / 2, 435);
    text("Damage Taken: " + dmg_taken, width / 2, 480);
    text("Damage Dealt: " + dmg_dealt, width / 2, 525);
    text("Waves Survived: " + (wave - 1), width / 2, 570);

    restart.draw_button();

    if (mouse_clicked && restart.mouse_in_button()) {
      restarted = true;
    }
  }

  public void set_mouse_clicked(boolean mouse_clicked) {
    this.mouse_clicked = mouse_clicked;
  }
  
  private boolean is_valid_pos(PVector pos) {
    return pos.x >= 0 && pos.x < map[0].length && pos.y >= 0 && pos.y < map.length;
  }
  
  // return the number of steps (horizontal + vertical)
  // between v1 and v2 in terms of the map array
  private int num_steps(PVector v1, PVector v2) {
    return (int)abs(v1.x - v2.x) + (int)abs(v1.y - v2.y);
  }
}
