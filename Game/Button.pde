public class Button {
    private float _width, _height;
    private color c, highlight;
    private PVector position;

    public Button(float _width, float _height, color c, color highlight, PVector position) {
        this._width = _width;
        this._height = _height;
        this.c = c;
        this.highlight = highlight;
        this.position = position;
    }

    public void draw_button() {
        color active_color = c;
        if (mouse_in_button())
            active_color = highlight;

        stroke(0);
        fill(active_color);
        rect(position.x, position.y, _width, _height);
    }

    public boolean mouse_in_button() {
        if (mouseX >= position.x &&
            mouseX <= position.x + _width &&
            mouseY >= position.y &&
            mouseY <= position.y + height) {
                return true;
            }

        return false;
    }
}