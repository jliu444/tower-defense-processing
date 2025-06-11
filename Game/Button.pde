public class Button {
    private float x_pos, y_pos;
    private float _width, _height;
    private color c, highlight1, highlight2;
    private PImage texture;

    public Button(float x_pos, float y_pos, float _width, float _height, color c, color highlight1, color highlight2, PImage texture) {
        this.x_pos = x_pos;
        this.y_pos = y_pos;
        this._width = _width;
        this._height = _height;
        this.c = c;
        this.highlight1 = highlight1;
        this.highlight2 = highlight2;
        this.texture = texture;
        this.texture.resize((int)_width, (int)_height);
    }
    
    public void set_texture(PImage texture) {
      this.texture = texture;
      this.texture.resize((int)_width, (int)_height);
    }

    public void draw_button() {
        color active_color = c;
        if (mouse_in_button()) {
            active_color = highlight1;

            if (mousePressed)
                active_color = highlight2;
        }

        noStroke();
        fill(active_color);
        rect(x_pos, y_pos, _width, _height, 8.5);
        image(texture, x_pos, y_pos);
    }

    public boolean mouse_in_button() {
        if (mouseX >= x_pos &&
            mouseX <= x_pos + _width &&
            mouseY >= y_pos &&
            mouseY <= y_pos + _height) {
                return true;
            }

        return false;
    }
}
