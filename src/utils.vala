namespace ETerm {

    public Gdk.Pixbuf make_pixbuf(string name, int size) {
        try {
            var screen = Gdk.Screen.get_default();
            var theme = Gtk.IconTheme.get_for_screen(screen);
            var pixbuf = theme.load_icon(name, size, Gtk.IconLookupFlags.FORCE_SYMBOLIC);

            if (pixbuf.get_width() != size || pixbuf.get_height() != size) {
                pixbuf = pixbuf.scale_simple(size, size, Gdk.InterpType.BILINEAR);
            }

            return pixbuf;
        }
        catch (GLib.Error e) {
            return new Gtk.Image().get_pixbuf();
        }
    }

    public Gtk.Image make_image(string name, int size) {
        return new Gtk.Image.from_pixbuf(ETerm.make_pixbuf(name, size));
    }

    public void load_theme(Gtk.Widget widget, string theme) {
        Gtk.CssProvider style_provider = new Gtk.CssProvider();
        try {
            style_provider.load_from_data(theme, theme.length);
        } catch (GLib.Error error) {
            return;
        }

        Gtk.StyleContext context = widget.get_style_context();
        context.add_provider(style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }
}
