namespace ETerm {
    public class HeaderBar: Gtk.HeaderBar {
        public signal void show_grid(bool show);

        public Gtk.ToggleButton grid_button;

        public HeaderBar() {
            this.set_show_close_button(true);
            this.set_title("Terminal");

            Gtk.Image image = new Gtk.Image.from_icon_name("view-grid-symbolic", Gtk.IconSize.BUTTON);
            this.grid_button = new Gtk.ToggleButton();
            this.grid_button.set_image(image);
            this.grid_button.set_tooltip_text("Show terminals on a grid");
            this.grid_button.toggled.connect(this.button_toggled);
            this.pack_start(this.grid_button);
        }

        private void button_toggled(Gtk.ToggleButton button) {
            this.show_grid(button.get_active());
        }
    }
}
