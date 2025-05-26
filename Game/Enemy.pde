public class Enemy {
   private float health;
   private float power;
   private PVector position;

   public Enemy(float health, float power, PVector position) {
    this.health = health;
    this.power = power;
    this.position = position;
   }

   public float get_health() {
    return health;
   }

   public float get_power() {
    return power;
   }

   public PVector get_position() {
    return position;
   }

   public void draw_enemy() {
    
   }

   public void update_enemy() {

   }
}