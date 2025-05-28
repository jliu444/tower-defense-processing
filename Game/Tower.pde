public class Tower {
  private float power, fire_rate, range;
  private int price;
  private PVector position;
  private PImage texture_large, texture_small;
  
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
  }
  
  public Tower(Tower t) {
    this.power = t.power;
    this.fire_rate = t.fire_rate;
    this.price = t.price;
    this.position = t.position;
    this.range = t.range;

    texture_large = t.get_texture_large();
    texture_small = t.get_texture_small();
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

  public void set_position(PVector position) {
    this.position = position;
  }

  public void draw_tower() {
    image(texture_small, position.x, position.y);

  }

  public void update_tower() {

  }
}
