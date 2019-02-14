/*
* Copyright (c) 2018 Felipe Escoto (https://github.com/Philip-Scott)
* Copyright (c) 2019 Akira UX (https://github.com/akiraux)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
* Authored by: Alessandro Castellani <castellani.ale@gmail.com>
*/

public class GCav.HeaderBar : Gtk.HeaderBar {
    public GCav.ResponsiveCanvas canvas { get; construct; }
    
    public Gtk.Button zoom_out_button;
    public Gtk.Button zoom_default_button;
    public Gtk.Button zoom_in_button;

	public HeaderBar (GCav.ResponsiveCanvas responsive_canvas) {
        Object (canvas: responsive_canvas);

		set_show_close_button (true);

		build_ui ();
	}

	private void build_ui () {
        zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.MENU);
        zoom_out_button.clicked.connect (zoom_out);
        zoom_default_button = new Gtk.Button.with_label ("100%");
        zoom_default_button.clicked.connect (zoom_reset);
        zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU);
        zoom_in_button.clicked.connect (zoom_in);

        var zoom_grid = new Gtk.Grid ();
        zoom_grid.column_homogeneous = true;
        zoom_grid.hexpand = false;
        zoom_grid.margin = 12;
        zoom_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        zoom_grid.add (zoom_out_button);
        zoom_grid.add (zoom_default_button);
        zoom_grid.add (zoom_in_button);

        pack_start (zoom_grid);
		//  var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

		//  pack_end (mode_switch);
    }
    
    public void zoom_out () {
        var zoom = int.parse (zoom_default_button.label) - 10;
        if (zoom < 0) {
            zoom_out_button.sensitive = false;
            return;
        }

        zoom_out_button.sensitive = true;
        zoom_default_button.label = "%.0f%%".printf (zoom);
        canvas.set_scale (canvas.get_scale () - 0.1);
    }

    public void zoom_in () {
        var zoom = int.parse (zoom_default_button.label) + 10;
        if (zoom > 1000) {
            zoom_in_button.sensitive = false;
            return;
        }

        zoom_in_button.sensitive = true;
        zoom_default_button.label = "%.0f%%".printf (zoom);
        canvas.set_scale (canvas.get_scale () + 0.1);
    }

    public void zoom_reset () {
        zoom_in_button.sensitive = true;
        zoom_out_button.sensitive = true;
        zoom_default_button.label = "100%";
        canvas.set_scale (1);
    }
}