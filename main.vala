namespace ETerm {
    public class App: Gtk.Application {
        public App() {
            GLib.Object(application_id: "org.edge.terminal", flags: GLib.ApplicationFlags.FLAGS_NONE);
        }

	    protected override void activate() {
	        this.window_removed.connect(this.window_removed_cb);
	        this.add_actions();
            this.set_dark_theme();
            this.new_window();
        }

        private void add_actions() {
            GLib.SimpleAction action;

            action = new GLib.SimpleAction("copy", null);
            action.activate.connect(this.copy);
            this.add_action(action);

            action = new GLib.SimpleAction("paste", null);
            action.activate.connect(this.paste);
            this.add_action(action);

            action = new GLib.SimpleAction("new-window", null);
            action.activate.connect(this.new_window);
            this.add_action(action);

            action = new GLib.SimpleAction("new-tab", null);
            action.activate.connect(this.new_tab);
            this.add_action(action);

            action = new GLib.SimpleAction("close-tab", null);
            action.activate.connect(this.close_tab);
            this.add_action(action);

            action = new GLib.SimpleAction("about", null);
            action.activate.connect(this.about);
            this.add_action(action);

            this.set_accels_for_action("app.copy", { "<Primary><Shift>C" });
            this.set_accels_for_action("app.paste", { "<Primary><Shift>V" });
            this.set_accels_for_action("app.new-window", { "<Primary><Shift>N" });
            this.set_accels_for_action("app.new-tab", { "<Primary><Shift>T" });
            this.set_accels_for_action("app.close-tab", { "<Primary><Shift>W" });
        }

        private void set_dark_theme() {
            Gtk.Settings settings = Gtk.Settings.get_default();
            settings.gtk_application_prefer_dark_theme = false;
        }

        private void window_removed_cb(Gtk.Application self, Gtk.Window window) {
            if (this.get_windows().length() == 0) {
                this.quit();
            }
        }

        public void new_window() {
            ETerm.Window win = new ETerm.Window(this);
            this.add_window(win);
        }

        public ETerm.Window get_current_window() {
            Gtk.Window win = this.get_active_window();
            return (win as ETerm.Window);
        }

        public void about() {
		      stdout.printf("about!\n");
        }
        public void copy() {
            this.get_current_window().copy();
        }

        public void paste() {
            this.get_current_window().paste();
        }

        public void new_tab() {
            ETerm.Window win = this.get_current_window();
            win.selected_terminal.update_image();
            win.new_terminal();
        }

        public void close_tab() {
            ETerm.Window win = this.get_current_window();
            win.close_tab_from_term(win.selected_terminal);
        }
    }
}

int main(string[] args) {
    ETerm.App app = new ETerm.App();
    return app.run();
}
