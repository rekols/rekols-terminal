using Gtk;

namespace Widgets {
	public class Dialog : Gtk.Window {
		private int width = 400;
        	private int height = 200;

		public signal void confirm();

		public Dialog(string message, Gtk.Window window){
			this.set_transient_for(window);
			this.set_skip_taskbar_hint(true);
			this.set_skip_pager_hint(true);
			this.set_size_request(width, height);
			this.set_resizable(false);
			
			Gdk.Window gdk_window = window.get_window();
			int x, y;
			gdk_window.get_root_origin(out x, out y);
			Gtk.Allocation window_alloc;
			window.get_allocation(out window_alloc);

			move(x + (window_alloc.width - width) / 2,
                 	     y + (window_alloc.height - height) / 2);
		}

	}
}
