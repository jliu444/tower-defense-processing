public class Game {
  private final int MAX_TOWERS = 15;
  private int base_health;
  private int wave;
  private int currency;
  
  private boolean is_game_over;
  
  private Tower[] towers;
  private int[] map;
  
  public Game() {
    base_health = 0;
    wave = 0;
    currency = 0;
    
    is_game_over = false;
    
    towers = new Tower[MAX_TOWERS];
    map = new int[20][20];
  }
  
  public void update() {
    
  }
  
  private void placeTower
  
}
