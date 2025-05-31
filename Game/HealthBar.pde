public class HealthBar {
    float x_pos, y_pos, width, height;
    float curr_hp, total_hp;

    public HealthBar(float x_pos, float y_pos, float width, float height, float curr_hp, float total_hp) {
        this.x_pos = x_pos;
        this.y_pos = y_pos;
        this.width = width;
        this.height = height;
        this.curr_hp = curr_hp;
        this.total_hp = total_hp;
    }

    public HealthBar(HealthBar bar) {
        this.x_pos = bar.x_pos;
        this.y_pos = bar.y_pos;
        this.width = bar.width;
        this.height = bar.height;
        this.curr_hp = bar.curr_hp;
        this.total_hp = bar.total_hp;
    }

    public PVector get_position() {
        return new PVector(x_pos, y_pos);
    }

    public void set_position(PVector new_pos) {
        x_pos = new_pos.x;
        y_pos = new_pos.y;
    }

    public void set_curr_hp(float hp) {
        curr_hp = hp;
    }

    public void set_total_hp(float hp) {
        total_hp = hp;
    }

    public void draw_hp_bar() {
        if (curr_hp < total_hp) {
            stroke(0);
            fill(6, 201, 29);
            float curr_hp_len = (curr_hp / total_hp) * width;
            rect(x_pos, y_pos, curr_hp_len, height);

            fill(163, 13, 8);
            rect(x_pos + curr_hp_len, y_pos, width - curr_hp_len, height);
        }
    }
}