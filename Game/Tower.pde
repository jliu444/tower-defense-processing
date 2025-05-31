public class Tower {
  private float power, fire_rate, range;
  private int price;
  private PVector position;
  private PImage texture_large, texture_small;
  private int time_at_last_attack;
  private Enemy target;
  
  public Tower(float power, float fire_rate, int price, PVector position, float range, PImage texture) {
    this.power = power;
    this.fire_rate = fire_rate;
    this.price = price;
    this.position = position;
    this.range = range;

    texture_large = texture;
    texture_large.resize(300, 300);
    texture_small = texture.copy();
    texture_small.resize(50, 50);

    time_at_last_attack = 0;
    target = null;
  }
  
  public Tower(Tower t) {
    this.power = t.power;
    this.fire_rate = t.fire_rate;
    this.price = t.price;
    this.position = t.position;
    this.range = t.range;

    texture_large = t.get_texture_large();
    texture_small = t.get_texture_small();

    time_at_last_attack = t.time_at_last_attack;
    target = t.target;
  }

  public float get_power() {
    return power;
  }
  
  public float get_fire_rate() {
    return fire_rate;
  }
  
  public int get_price() {
    return price;
  }
  
  public PVector get_position() {
    return position;
  }

  public float get_range() {
    return range;
  }

  public PImage get_texture_large() {
    return texture_large;
  }

  public PImage get_texture_small() {
    return texture_small;
  }

  public int get_time_at_last_attack() {
    return time_at_last_attack;
  }

  public Enemy get_target() {
    return target;
  }

  public void set_position(PVector position) {
    this.position = position;
  }

  public void draw_tower() {
    image(texture_small, position.x, position.y);
  }

  public void lock_to_enemy(ArrayList<Enemy> enemies) {
    float nearest = Float.MAX_VALUE;
    for (Enemy e : enemies) {
      float tower_to_enemy = dist(position.x + 25, position.y + 25, e.get_position().x, e.get_position().y);
      if (tower_to_enemy <= range && tower_to_enemy < nearest)
        target = e;
    }
  }

  public void attack_target() {
    if (millis() - time_at_last_attack >= 1 / fire_rate * 1000)
      target.damage(power);

    if (target.get_health() <= 0)
      target = null;
  }

  public void update_tower() {

  }

  public void attack() {
    time_at_last_attack = millis();
  }
}
