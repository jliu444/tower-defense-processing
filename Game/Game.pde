import java.util.Arrays;
import java.util.Stack;
import java.util.Collections;
import java.util.Map;
import java.util.Queue;
import java.util.LinkedList;
import java.text.DecimalFormat;

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
  private final PImage PAUSE_TEX = loadImage("images/pause.png");
  private PImage RESUME_TEX = loadImage("images/resume.png");
  private final PImage RESTART_TEX = loadImage("images/restart.png");
  private final PImage RESTART2_TEX = loadImage("images/restart2.png");
  private PImage GRASS_TEX = loadImage("images/grass.jpg");
  private PImage PATH_TEX = loadImage("images/dirt.jpg");

  private final DecimalFormat format = new DecimalFormat("0.#");

  private final int SECOND = 1000; // milliseconds in a second

  private int start_time;
  private int prev_frame_time, curr_frame_time;
  private int time_to_next_wave;

  private int time_at_last_spawn;
  private float spawn_rate;

  private boolean mouse_clicked;
  private boolean key_released;

  private boolean is_placing_tower; 
  private Tower tower_being_placed;

  private Button shop_left, shop_right, buy;
  private int curr_tower_idx;
  
  private HealthBar hp_bar;
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

  private Tower selected_tower;

  // game stats
  private int kills, lifetime_cash;
  private float dmg_taken, dmg_dealt;

  private Button restart, restart2, pause;
  private boolean restarted, paused;
  private int time_at_pause, total_pause_time;

  
  public Game() {
    prev_frame_time = 0;
    curr_frame_time = millis();

    time_at_last_spawn = 0;
    spawn_rate = 0;

    mouse_clicked = false;

    is_placing_tower = false;
    tower_being_placed = null;

    shop_left = new Button(width - 350, 895, 50, 50, 
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           SHOP_LEFT_TEX);

    shop_right = new Button(width - 100, 895, 50, 50, 
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           SHOP_RIGHT_TEX);
                           
    buy = new Button(width - 250, 895, 100, 50, 
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           BUY_TEX);
                          
    restart = new Button(width / 2 - 50, 605, 100, 100,
                           color(24, 85, 184), 
                           color(54, 104, 186), 
                           color(73, 118, 191),
                           RESTART_TEX);

    restart2 = new Button(950, 0, 50, 50,
                          color(255, 0),
                          color(255, 0),
                          color(255, 0),
                          RESTART2_TEX);

    pause = new Button(0, 0, 50, 50,
                          color(255, 0),
                          color(255, 0),
                          color(255, 0),
                          PAUSE_TEX);

    GRASS_TEX.resize(50, 50);
    PATH_TEX.resize(50, 50);

    curr_tower_idx = 0;

    base_health = 100.0;
    hp_bar = new HealthBar(1050, 25, 300, 50, base_health, base_health);
    wave = 0;
    cash = 100;
    
    active_towers = new ArrayList<Tower>();

    enemies = new ArrayList<Enemy>();

    kills = 0;
    lifetime_cash = 0;
    dmg_taken = 0;
    dmg_dealt = 0;
    restarted = false;
    paused = false;

    time_at_pause = 0;
    total_pause_time = 0;

    final PVector zero = new PVector(0, 0);
    shop_towers = new Tower[2];
    shop_towers[0] = new Tower("Machine Gun Tower", 5, 2.0, 100, zero, 150, MACHINE_GUN_TEX);
    shop_towers[1] = new Tower("Laser Tower", 12, 100.0, 100, zero, 300, LAZER_TEX);

    enemy_types = new Enemy[4];
    enemy_types[0] = new Enemy(24.0, 5.0, .1, zero, zero, SLIME_TEX, 25, SQ_SIZE);
    enemy_types[1] = new Enemy(50.0, 10.0, .11, zero, zero, BLUE_SLIME_TEX, 40, SQ_SIZE);
    enemy_types[2] = new Enemy(30.0, 7.5, .15, zero, zero, NINJA_SLIME_TEX, 40, SQ_SIZE);
    enemy_types[3] = new Enemy(100.0, 25.0, .08, zero, zero, KING_SLIME_TEX, 100, SQ_SIZE);

    selected_tower = null;

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
    draw_enemies();
    draw_towers();
    display_tower_stats();

    if (is_placing_tower) {
      place_tower();
    }
    stroke(152, 183, 237);
    fill(152, 183, 237);
    rect(1000, 0, 400, 1000);
    draw_UI();

    if (is_game_over())
      game_over();
  }

  private void draw_map() {
    int curr_x = 0, curr_y = 0;

    while (curr_y + SQ_SIZE <= height) {
      PImage tex = null;
      switch (map[curr_y / SQ_SIZE][curr_x / SQ_SIZE]) {
        case EMPTY:
        case OCCUPIED: 
          tex = GRASS_TEX;
          noFill();
          if(is_placing_tower) {
            strokeWeight(2);
            stroke(55, 64);
          } else {
            noStroke(); 
          }

          break; // will be drawn by draw_towers() 
        case ENEMY_PATH: noFill(); noStroke(); tex = PATH_TEX; break;
        case ENEMY_SPAWN: stroke(255, 0, 0); fill(255, 0, 0); break;
        case BASE: stroke(0, 0, 255); fill(0, 0, 255); break;
      }

      if (tex != null) {
        image(tex, curr_x, curr_y);
      }
      
      square(curr_x, curr_y, SQ_SIZE);
      strokeWeight(1);
      
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
    pause.draw_button();
    restart2.draw_button();

    textSize(32);
    textAlign(CENTER);
    fill(0, 128);

    int curr_time = (paused ? time_at_pause : millis()) - start_time - total_pause_time;
    int minute = curr_time / SECOND / 60;
    int second = curr_time / SECOND - (minute * 60);
    text(minute + ":" + (second < 10 ? "0" : "") + second, 500, 35);

    hp_bar.draw_hp_bar();

    textSize(50);
    fill(0);
    textAlign(RIGHT);
    text("Cash: $" + cash, width - 50, 150);
    text("Wave: " + wave, width - 50, 200);

    if (!is_game_over()) {
      time_to_next_wave = (wave == 0 ? (5 * SECOND - curr_time % (5 * SECOND)) / SECOND
                                     : (20 * SECOND - (curr_time - 5 * SECOND) % (20 * SECOND)) / SECOND);
    }
    text("Next wave in: " + time_to_next_wave, width - 50, 250);

    draw_shop();
  }

  private void draw_shop() {
    shop_left.draw_button();
    shop_right.draw_button();
    buy.draw_button();

    Tower t = shop_towers[curr_tower_idx];

    fill(0);
    rect(width - 350, 375, 300, 300);
    image(t.get_texture_large(), width - 350, 375);
    
    textSize(32);
    float left = width - 335;
    float top = 715;
    
    fill(24, 85, 184);
    rect(width - 350, 325, 300, 50);
    rect(width - 350, 675, 300, 200);  

    textAlign(CENTER);
    fill(255);
    text(t.get_name(), width - 200, 360);
    
    textAlign(LEFT);
    fill(255);
    text("Power: ", left, top);
    text("Firerate: ", left, top + 35);
    text("DPS: ", left, top + 70);
    text("Range: ", left, top + 105);
    
    if (cash < t.get_price())
      fill(255, 0, 0);
    else
      fill(255);
      
    text("Price: ", left, top + 140);
    
    fill(255);
    float right = width - 65;
    textAlign(RIGHT);
    text(format.format(t.get_power()), right, top);
    text(format.format(t.get_fire_rate()), right, top + 35);
    text(format.format(t.get_power() * t.get_fire_rate()), right, top + 70);
    text(format.format(t.get_range()), right, top + 105);    
    
    if (cash < t.get_price())
      fill(255, 0, 0);
    else
      fill(255);
      
    text("$" + t.get_price(), right, top + 140);
  }

  private void display_tower_stats() {
    if (selected_tower == null)
      return;

    PVector pos = selected_tower.get_position();
    noStroke();
    fill(250, 242, 10, 64);
    rect(pos.x, pos.y, 50, 50);
    float left = pos.x - 15;
    float top = pos.y - 75;

    fill(255);
    textAlign(LEFT);
    textSize(16);

    // adjust location of tower stat display to keep it within window
    if (left <= 0) {
      left = pos.x + 55;
      top = pos.y;
    } else if (left + 115 >= width - SIDE_BAR_LEN) {
      left = pos.x - 135;
      if (pos.y + 70 < height) {
        top = pos.y;
      }
    }
    if (top <= 0) {
      top = pos.y + 60;
    }
    
    int power = selected_tower.get_power();
    float fire_rate = selected_tower.get_fire_rate();
    int range = selected_tower.get_range();
    int upgrade_price = selected_tower.get_upgrade_price();
    int upgraded_power = round(power * 1.2);

    text("Power: " + power + " -> " + upgraded_power, left, top);
    text("Firerate: " + fire_rate, left, top + 15); 
    text("DPS: " + (power * fire_rate) + " -> " + (upgraded_power * fire_rate), left, top + 30); 
    text("Range: " + range + " px", left, top + 45);

    if (cash < upgrade_price)
      fill(255, 0, 0);
    text("Upgrade Price: $" + upgrade_price, left, top + 60);

    textAlign(CENTER);
    textSize(32);
    fill(250, 242, 10);
    text("Press 'Z' to upgrade", 500, height - 20);

    noStroke();
    fill(255, 32);
    circle(pos.x + 25, pos.y + 25, selected_tower.get_range() * 2);
  }

  public void update() {
    if ((is_game_over() && !paused) ||
        (mouse_clicked && pause.mouse_in_button()) ||
        (key_released && (key == 'P' || key == 'p'))) {
      if (!paused) {
        time_at_pause = millis();
        pause.set_texture(RESUME_TEX);
      } else {
        total_pause_time += millis() - time_at_pause;
        pause.set_texture(PAUSE_TEX);
      }

      paused = !paused;
    }

    if (is_game_over() || paused)
      return;

    update_wave();

    // fix spawn rate
    if (wave > 0 && (millis() - time_at_last_spawn) >= 1000 / spawn_rate)
      spawn_enemy();

    if (mouse_clicked)
      selected_tower = null;

    update_towers();
    update_enemies();
    update_buttons();

    if (selected_tower != null &&
        key_released && (key == 'Z' || key == 'z') &&
        cash >= selected_tower.get_upgrade_price()) {
            cash -= selected_tower.get_upgrade_price();
            selected_tower.upgrade_tower();
    }
  }

  private void update_wave() {
    int curr_time = (paused ? time_at_pause : millis()) - start_time - total_pause_time;

    if (wave == 0 && curr_time >= 5 * SECOND) {
      ++wave;
      spawn_rate = .2;
    }

    else if (millis() - start_time >= 5 * SECOND && (curr_time - 5 * SECOND) / (20 * SECOND) == wave) {
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
        if (selected_tower == t)
          selected_tower = null;
        else
          selected_tower = t;
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
        base_health = max(0, base_health - e.get_power());
        hp_bar.set_curr_hp(base_health);
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
          // println(e.get_direction());
      }

      
      // trying to fix issue when speed is too high, enemy moved out of path
      //println("here");
      //println(e.get_position());
      //PVector move = PVector.mult(e.get_direction(), e.get_speed() * (curr_frame_time - prev_frame_time));
      //println(move);
      
      //// calculate maximum movement
      //PVector init_dir = pos_to_dir.get(pos_idx);
      //PVector dir = pos_to_dir.get(pos_idx);
      //PVector curr_pos = new PVector(pos_idx.x, pos_idx.y);
      //while (dir.x == init_dir.x && dir.y == init_dir.y) {
      //  curr_pos.add(dir);
      //  if (curr_pos.x == base.x && curr_pos.y == base.y)
      //    break;
      //  dir = pos_to_dir.get(curr_pos);
      //}

      //PVector max_move = PVector.sub(curr_pos, e.get_position());
      //println(max_move);

      //if (abs(move.x) + abs(move.y) < abs(max_move.x) + abs(max_move.y)) {
      //  println("in1");
      //  e.set_position(PVector.add(e.get_position(), move));
      //}
      //else {
      //  println("in2");
      //  e.set_position(PVector.add(e.get_position(), max_move));
      //}
      e.update_enemy(curr_frame_time - prev_frame_time);

    }
  }

  private void update_buttons() {
    if (!mouse_clicked)
      return;

    // menu buttons
    if (restart2.mouse_in_button())
      restarted = true;

    // shop buttons
    if (buy.mouse_in_button() && !is_placing_tower) {
      is_placing_tower = true;
      buy.set_texture(CANCEL_TEX);
      tower_being_placed = new Tower(shop_towers[curr_tower_idx]);
    } else if (buy.mouse_in_button() && is_placing_tower) {
      is_placing_tower = false;
      buy.set_texture(BUY_TEX);
      tower_being_placed = null;
    }

    if (shop_left.mouse_in_button()) {
      curr_tower_idx = (curr_tower_idx - 1 + shop_towers.length) % shop_towers.length;
      is_placing_tower = false;
      buy.set_texture(BUY_TEX);
      tower_being_placed = null;
    }
    
    if (shop_right.mouse_in_button()) {
      curr_tower_idx = (curr_tower_idx + 1) % shop_towers.length;
      is_placing_tower = false;
      buy.set_texture(BUY_TEX);
      tower_being_placed = null;
    }
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

  public void set_key_released(boolean key_released) {
    this.key_released = key_released;
  }
  
  private boolean is_valid_pos(PVector pos) {
    return pos.x >= 0 && pos.x < map[0].length && pos.y >= 0 && pos.y < map.length;
  }
  
  private PVector pos_to_idx(PVector pos) {
    return new PVector((int)pos.x / SQ_SIZE, (int)pos.y / SQ_SIZE);
  }
  
  // return the number of steps (horizontal + vertical)
  // between v1 and v2 in terms of the map array
  private int num_steps(PVector v1, PVector v2) {
    return (int)abs(v1.x - v2.x) + (int)abs(v1.y - v2.y);
  }
}
