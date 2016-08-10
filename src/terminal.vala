namespace ETerm {
    public class Terminal: Gtk.Box {
        public signal void closed();
        public signal void title_changed(string title);

        public Vte.Terminal terminal;
        public Gtk.Image image;
        public Gtk.Scrollbar scrollbar;

        public Gdk.RGBA background_color = Gdk.RGBA();
        public Gdk.RGBA foreground_color = Gdk.RGBA();

	public GLib.Menu menu = new GLib.Menu();

        public Terminal() {
            this.set_orientation(Gtk.Orientation.HORIZONTAL);

            this.image = new Gtk.Image();

            this.background_color.parse("#262c37");  // 262c37
            this.foreground_color.parse("#39E83E");  // 009688

            this.terminal = new Vte.Terminal();
            this.terminal.set_color_background(this.background_color);
            this.terminal.set_color_foreground(this.foreground_color);
            this.terminal.realize.connect(this.vte_realize_cb);
            this.terminal.child_exited.connect(this.vte_exited_cb);
            this.terminal.window_title_changed.connect(this.title_changed_cb);
            this.pack_start(this.terminal, true, true, 0);

            Gtk.Adjustment adj = this.terminal.get_vadjustment();
            adj.changed.connect(this.adj_changed);

            this.scrollbar = new Gtk.Scrollbar(Gtk.Orientation.VERTICAL, adj);
            //this.pack_end(scrollbar, false, false, 0);

	    this.terminal.add_events(Gdk.EventMask.BUTTON_PRESS_MASK);
	    this.terminal.button_press_event.connect(this.button_press_cb);


	    GLib.MenuItem item = new GLib.MenuItem("Copy", "app.copy");
	    menu.append_item(item);

	    item = new GLib.MenuItem("Paste", "app.paste");
	    menu.append_item(item);
	    item = new GLib.MenuItem("New Window", "app.new-window");
	    menu.append_item(item);
	    item = new GLib.MenuItem("New Tab", "app.new-tab");
	    menu.append_item(item);
	    item = new GLib.MenuItem("Close Tab", "app.close-tab");
	    menu.append_item(item);
	    item = new GLib.MenuItem("About", "app.about");
	    menu.append_item(item);


            this.spawn();

            this.show_all();
        }



	public bool button_press_cb(Gtk.Widget wterminal, Gdk.EventButton event){
		if (event.button == 3) {
			Gdk.Rectangle rect = Gdk.Rectangle();
			Gtk.Popover popover = new Gtk.Popover.from_model(this.terminal, menu); 

			rect.x = (int)event.x - 1;
			rect.y = (int)event.y - 1;
			rect.width = 2;
			rect.height = 2;

			popover.set_pointing_to(rect);
			popover.show_all();
		}

		return false;
	}

        private void spawn() {
            string[] argv = { "/bin/bash" };

            try {
                this.terminal.spawn_sync(
                    Vte.PtyFlags.DEFAULT,
                    GLib.Environment.get_home_dir(),
                    argv, {},
                    GLib.SpawnFlags.DO_NOT_REAP_CHILD,
                    null, null
                );
            } catch (GLib.Error error) {
                GLib.warning(@"Error launching a terminal emulator: $(error.message)");
            }
        }

        private void vte_realize_cb(Gtk.Widget terminal) {
            this.terminal.grab_focus();

            GLib.Timeout.add(300, () => {
                this.update_image();
                return false;
            });
        }

        private void vte_exited_cb(Vte.Terminal terminal, int status) {
            this.closed();
        }

        private void title_changed_cb(Vte.Terminal terminal) {
            this.title_changed(this.terminal.get_window_title());
        }

        private void adj_changed(Gtk.Adjustment adj) {
            double upper = adj.get_upper();
            double page_size = adj.get_page_size();

            if (page_size < upper && this.scrollbar.get_parent() == null) {
                this.pack_end(this.scrollbar, false, false, 0);
            } else if (page_size > upper && this.scrollbar.get_parent() != null) {
                this.remove(this.scrollbar);
            }

            this.show_all();
        }

        public string get_title() {
            string title = this.terminal.get_window_title();
            return (title != null)? title: "Terminal";
        }

        public void update_image() {
            Gtk.Allocation alloc;
            this.get_allocation(out alloc);

            Gdk.Window win = this.terminal.get_window();
            if (win == null) {
                return;
            }

            if (!win.is_viewable()) {
                return;
            }

            Gdk.Pixbuf pixbuf = Gdk.pixbuf_get_from_window(win, 0, 0, alloc.width, alloc.height);
            pixbuf = pixbuf.scale_simple(200, 150, Gdk.InterpType.HYPER);
            this.image.set_from_pixbuf(pixbuf);
        }

        public Gtk.Image get_image() {
            return this.image;
        }

        public bool get_has_selection() {
            return this.terminal.get_has_selection();
        }

        public void copy_text() {
            if (!this.get_has_selection()) {
                return;
            }

            this.terminal.copy_clipboard();
        }

        public void paste_text() {
            this.terminal.paste_clipboard();
        }
    }
}
