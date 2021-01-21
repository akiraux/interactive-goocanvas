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

public class GCav.Application : Gtk.Application {
    public const string PROGRAM_ID = "com.github.akiraux.interactive-goocanvas";
    public const string PROGRAM_NAME = "CanvasDemo";

    construct {
        flags |= ApplicationFlags.HANDLES_OPEN;

        application_id = PROGRAM_ID;
    }

    public static Gtk.Window? window = null;
    public static Gtk.Grid grid;

    GCav.ResponsiveCanvas canvas;
    //  bool set_color = false;

    public override void activate () {
        var window = new Gtk.Window ();
        this.add_window (window);

        canvas = new GCav.ResponsiveCanvas ();
        canvas.set_size_request (1200, 800);
        canvas.set_scale (1);
        canvas.set_bounds (0, 0, 10000, 10000);

        var headerbar = new GCav.HeaderBar (canvas);
        window.set_titlebar (headerbar);

        var root = canvas.get_root_item ();

        var rect = new Goo.CanvasRect (null, 100.0, 100.0, 400.0, 400.0,
                                   "line-width", 5.0,
                                   "radius-x", 100.0,
                                   "radius-y", 100.0,
                                   "stroke-color", "#f37329",
                                   "fill-color", "#ffa154", null);
        rect.set ("parent", root);

        var rect2 = new Goo.CanvasRect (null, 50, 100, 200, 100,
            "line-width", 5.0,
            "stroke-color", "#64baff",
            "fill-color", "#3689e6");

        rect2.set ("parent", root);

        var rect3 = new Goo.CanvasRect (null, 0, 0, 64, 64,
            "radius-x", 32.0,
            "radius-y", 32.0,
            "line-width", 5.0,
            "stroke-color", "#9bdb4d",
            "fill-color", "#68b723");

        rect3.set ("parent", root);

        var text = new Goo.CanvasText (null, "Add text here", 20, 20, 200, Goo.CanvasAnchorType.NW, "font", "Open Sans 18");
        text.set ("parent", root);

        var points = new Goo.CanvasPoints(4);
        points.set_point(0, 10, 10);
        points.set_point(1, 50, 30);
        points.set_point(2, 80, 60);
        points.set_point(3, 40, 80);
        var poly = new Goo.CanvasPolyline (null, false, 4, "points", points);
        poly.set("parent", root);
        poly.line_width = 10.0;
        poly.fill_color = "red";
        poly.stroke_color = "blue";
        poly.x = 420;
        poly.y = 120;

        window.add (canvas);
        window.show_all ();

        window.show ();
    }

    public static int main (string[] args) {
        /* Initiliaze gettext support */
        Intl.setlocale (LocaleCategory.MESSAGES, Intl.get_language_names ()[0]);
        Intl.setlocale (LocaleCategory.NUMERIC, "en_US");
        //Intl.textdomain (Config.GETTEXT_PACKAGE);

        Environment.set_application_name (PROGRAM_NAME);
        Environment.set_prgname (PROGRAM_NAME);

        var application = new GCav.Application ();

        return application.run (args);
    }
}
