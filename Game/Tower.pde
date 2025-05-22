public class Tower {
  private float power;
  private float fire_rate;
  private int price;
  private PVector position;
  
  public Tower(float power, float fire_rate, int price, PVector position) {
    this.power = power;
    this.fire_rate = fire_rate;
    this.price = price;
    this.position = position;
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
}
