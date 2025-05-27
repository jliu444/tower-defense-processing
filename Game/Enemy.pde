public class Enemy {
   private float health, power, speed;
   private PVector position, direction;
   private boolean damaged;
   private PImage texture;

   public Enemy(float health, float power, float speed, PVector position, PVector direction, PImage texture) {
    this.health = health;
    this.power = power;
    this.speed = speed;
    this.position = position;
    this.direction = direction;
    this.texture = texture;
    this.texture.resize(50, 50);

    damaged = false;
   }

   public Enemy(Enemy e) {
    this.health = e.health;
    this.power = e.power;
    this.speed = e.speed;
    this.position = e.position;
    this.direction = e.direction;
    this.texture = e.texture;
    this.texture.resize(50, 50);

    damaged = false;
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

   public void set_position(PVector position) {
    this.position = position;
   }

   public void set_direction(PVector direction) {
    this.direction = direction;
   }

   public void draw_enemy() {
    image(texture, position.x, position.y);
   }

   public void update_enemy(float delta_time) {
    position.add(PVector.mult(direction, speed * delta_time));
   }
}