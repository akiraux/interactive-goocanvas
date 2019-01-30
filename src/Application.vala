/*
* Copyright (c) 2018 Felipe Escoto (https://github.com/Philip-Scott)
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
*/

public class Phi.Application : Granite.Application {
    public const string PROGRAM_ID = "com.github.philip-scott.canvas-demo";
    public const string PROGRAM_NAME = "CanvasDemo";

    construct {
        flags |= ApplicationFlags.HANDLES_OPEN;

        application_id = PROGRAM_ID;
        program_name = PROGRAM_NAME;
        exec_name = PROGRAM_ID;
        app_launcher = PROGRAM_ID;

        build_version = "1.0.0";
    }

    public static Gtk.Window? window = null;
    public static Gtk.Grid grid;

    Goo.Canvas canvas;
    bool set_color = false;

    public override void activate () {
        var window = new Gtk.Window ();
        this.add_window (window);

        canvas = new Phi.ResponsiveCanvas ();
        canvas.set_size_request (600, 600);
        canvas.set_scale (1);
        canvas.set_bounds (0, 0, 10000, 10000);

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

        var application = new Phi.Application ();

        return application.run (args);
    }
}