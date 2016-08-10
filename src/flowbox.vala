namespace ETerm {
    public class FlowBoxChild: Gtk.Box {
        public signal void close();

        public ETerm.Terminal term;

        public Gtk.Label label;
        public Gtk.Button button;
        public Gtk.Image image;

        public bool selected = false;

        public class FlowBoxChild(ETerm.Terminal term) {
            this.term = term;
            this.term.title_changed.connect(this.terminal_title_changed);

            this.set_orientation(Gtk.Orientation.VERTICAL);
            this.set_border_width(8);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            this.pack_start(box, false, false, 0);

            string title = this.term.get_title();
            this.label = new Gtk.Label(title);
            this.label.set_xalign(0);
            this.label.set_max_width_chars(20);
            this.label.set_ellipsize(Pango.EllipsizeMode.END);
            box.pack_start(this.label, false, false, 0);

            this.button = new Gtk.Button();
            this.button.set_relief(Gtk.ReliefStyle.NONE);
            this.button.set_image(new Gtk.Image.from_icon_name("window-close-symbolic", Gtk.IconSize.BUTTON));
            this.button.clicked.connect(() => { this.close(); });
            box.pack_end(this.button, false, false, 0);

            this.term.update_image();
            this.pack_end(this.term.get_image(), true, true, 0);

            this.show_all();
        }

        private void terminal_title_changed(ETerm.Terminal terminal, string title) {
            this.label.set_label(title);
        }

        public void load_theme(bool selected) {
            if (selected == this.selected) {
                return;
            }

            this.selected = selected;

            string theme = "* { color: %s; }".printf(this.selected? "#009688": "#FFFFFF");
            ETerm.load_theme(this.label, theme);
        }
    }

    public class FlowBoxChildNew: Gtk.Box {

        public FlowBoxChildNew() {
            this.set_orientation(Gtk.Orientation.VERTICAL);

            this.pack_start(ETerm.make_image("list-add-symbolic", 100), true, true, 0);
            this.show_all();
        }
    }

    public class FlowBox: Gtk.ScrolledWindow {

        public signal void page_changed(ETerm.Terminal term);
        public signal void new_terminal();
        public signal void terminal_closed(ETerm.FlowBoxChild child);
        public signal void close_window();

        public ETerm.Terminal selected_terminal;

        public Gtk.FlowBox box;

        public GLib.List<ETerm.FlowBoxChild> childs;
        public GLib.List<ETerm.Terminal> terminals;

        public Gtk.FlowBoxChild child_add;

        public FlowBox() {
            Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            this.add(box);

            this.box = new Gtk.FlowBox();
            this.box.set_homogeneous(true);
            this.box.set_activate_on_single_click(true);
            this.box.set_selection_mode(Gtk.SelectionMode.SINGLE);
            this.box.child_activated.connect(this._page_changed);
            box.pack_start(this.box, false, false, 0);

            this.make_child_new();

            this.childs = new GLib.List<ETerm.FlowBoxChild>();
            this.terminals = new GLib.List<ETerm.Terminal>();

            string theme = "* { background-color: #275292 }";  //background
            ETerm.load_theme(this, theme);
        }

        private void _page_changed(Gtk.FlowBox box, Gtk.FlowBoxChild child) {
            if (child == null) {
                return;
            }

            if (child == this.child_add) {
                this.new_terminal();
                return;
            }

            Gtk.Widget widget = child.get_child();
            ETerm.FlowBoxChild echild = (ETerm.FlowBoxChild)widget;
            this.selected_terminal = echild.term;
            this.page_changed(this.selected_terminal);
        }

        private void make_child_new() {
            ETerm.FlowBoxChildNew child = new ETerm.FlowBoxChildNew();
            this.box.insert(child, -1);

            this.child_add = (Gtk.FlowBoxChild)child.get_parent();
        }

        public void add_term(ETerm.Terminal term) {
            foreach (ETerm.Terminal terminal in this.terminals) {
                if (terminal == term) {
                    return;
                }
            }

            ETerm.FlowBoxChild child = new ETerm.FlowBoxChild(term);
            child.close.connect(() => { this.terminal_closed(child); });
            this.childs.append(child);
            this.terminals.append(term);
            this.box.insert(child, (int)this.box.get_children().length() - 1);

            string theme = "* { background-color: #275292 }";  //xuan zhong
            ETerm.load_theme((child.get_parent() as Gtk.FlowBoxChild), theme);
        }

        public void remove_term(ETerm.Terminal term) {
            int index = 0;

            foreach (ETerm.FlowBoxChild child in this.childs) {
                if (child.term == term) {
                    this.terminals.remove(term);
                    this.childs.remove(child);
                    this.box.remove((Gtk.FlowBoxChild)child.get_parent());
                    break;
                }

                index ++;
            }

            if (this.get_count_childs() == -1) {
                this.close_window();
                return;
            }

            if (this.selected_terminal == term) {
                this.set_current_term_from_index((index < this.get_count_childs())? index: this.get_count_childs());
                this.page_changed(this.selected_terminal);
            }
        }

        public void set_current_term(ETerm.Terminal term) {
            ETerm.FlowBoxChild? echild = null;

            foreach (ETerm.FlowBoxChild child in this.childs) {
                if (child.term == term) {
                    echild = child;
                    break;
                }
            }

            if (echild == null) {
                GLib.warning("Fail to select a terminal");
                return;
            }

            if (echild.get_parent() == null) {
                return;
            }

            Gtk.FlowBoxChild child = (Gtk.FlowBoxChild)echild.get_parent();
            this.box.select_child(child);
        }

        public void set_current_term_from_index(int index) {
            if (index > this.childs.length() - 1) {
                GLib.warning("Fail to select a terminal");
                return;
            }

            ETerm.FlowBoxChild echild;

            echild = this.childs.nth_data(index);

            if (echild.get_parent() == null) {
                return;
            }

            this.selected_terminal = echild.term;
            Gtk.FlowBoxChild child = (Gtk.FlowBoxChild)echild.get_parent();
            this.box.select_child(child);
        }

        public int get_count_childs() {
            return (int)this.childs.length() - 1;
        }
    }
}
