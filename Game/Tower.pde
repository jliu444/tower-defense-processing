public class Tower {
  private String name;
  private float fire_rate;
  private int power, range;
  private int price, upgrade_price;
  private PVector position;
  private PImage texture_large, texture_small;
  private int time_at_last_attack;
  private Enemy target;
  
  public Tower(String name, int power, float fire_rate, int price, PVector position, int range, PImage texture) {
    this.name = name;
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

    upgrade_price = price / 2;
  }
  
  public Tower(Tower t) {
    this.name = t.name;
    this.power = t.power;
    this.fire_rate = t.fire_rate;
    this.price = t.price;
    this.position = t.position;
    this.range = t.range;

    this.texture_large = t.get_texture_large();
    this.texture_small = t.get_texture_small();

    this.time_at_last_attack = t.time_at_last_attack;
    this.target = t.target;

    this.upgrade_price = t.upgrade_price;
  }
  
  public String get_name() {
    return name;
  }

  public int get_power() {
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

  public int get_range() {
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

  public int get_upgrade_price() {
    return upgrade_price;
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
      if (tower_to_enemy <= range && tower_to_enemy < nearest) {
        target = e;
        nearest = tower_to_enemy;
      }
    }
  }

  public boolean mouse_in_tower() {
    return (mouseX >= position.x && mouseX <= position.x + 50 &&
        mouseY >= position.y && mouseY <= position.y + 50);
  }

  public boolean attack_target() {
    if (target.get_health() <= 0)
      target = null;

    else if (millis() - time_at_last_attack >= 1000 / fire_rate) {
      target.damage(power);
      time_at_last_attack = millis();
      return true;
    }

    return false;
  }

  public void upgrade_tower() {
    power = round(power * 1.2);
    upgrade_price = round(upgrade_price * 1.3);
  }

  public void update_tower() {
    if (target != null &&
        dist(position.x + 25, position.y + 25, target.get_position().x, target.get_position().y) > range)
      target = null;
  }
}
