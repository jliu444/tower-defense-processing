public class Enemy {
   private float health, power, speed;
   private PVector position, direction;
   private boolean damaged, attacking;
   private PImage texture;
   private int time_at_last_attack;
   private HealthBar hp_bar;

   public Enemy(float health, float power, float speed, PVector position, PVector direction, PImage texture, int sq_size) {
    this.health = health;
    this.power = power;
    this.speed = speed;
    this.position = position;
    this.direction = direction;
    this.texture = texture;
    this.texture.resize(sq_size, sq_size);

    hp_bar = new HealthBar(position.x + 5, position.y + sq_size + 5, sq_size - 10, 5, health, health);

    damaged = false;
    attacking = false;
    time_at_last_attack = 0;
   }

   public Enemy(Enemy e) {
    this.health = e.health;
    this.power = e.power;
    this.speed = e.speed;
    this.position = e.position;
    this.direction = e.direction;
    this.texture = e.texture;
    this.texture.resize(50, 50);
    this.hp_bar = new HealthBar(e.get_hp_bar());

    damaged = false;
   }

   public float get_health() {
    return health;
   }

   public float get_power() {
    return power;
   }

   public float get_speed() {
    return speed;
   }
   
   public PVector get_direction() {
     return direction;
   }

   public PVector get_position() {
    return position;
   }

   public boolean is_attacking() {
    return attacking;
   }
   
   public PVector get_position_idx(int sq_size) {
    PVector quotient = PVector.div(position, sq_size);
    return new PVector((int)(quotient.x), (int)(quotient.y));
   }
   
   public int get_time_at_last_attack() {
    return time_at_last_attack;
   }

   public HealthBar get_hp_bar() {
    return hp_bar;
   }

   public void set_speed(float speed) {
     this.speed = speed;
   }

   public void set_position(PVector position) {
    this.position = position;
    hp_bar.set_position(new PVector(position.x + 5, position.y + 55));
   }

   public void set_direction(PVector direction) {
    this.direction = direction;
   }

   public void set_attacking(boolean attacking) {
    this.attacking = attacking;
   }

   public void draw_enemy() {
    image(texture, position.x, position.y);
    hp_bar.draw_hp_bar();
   }

   public void update_enemy(float delta_time) {
    if (!attacking) {
      PVector move = PVector.mult(direction, speed * delta_time);
      position.add(move);
      PVector new_hp_bar_pos = PVector.add(hp_bar.get_position(), move);
      hp_bar.set_position(new_hp_bar_pos);
    }
   }

   public void attack() {
    time_at_last_attack = millis();
   }

   public void damage(float dmg) {
    health -= dmg;
    hp_bar.set_curr_hp(health);
   }
}
