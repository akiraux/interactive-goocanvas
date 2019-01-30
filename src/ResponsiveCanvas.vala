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

public class Phi.ResponsiveCanvas : Goo.Canvas {
    private const int MIN_SIZE = 40;

    /**
     * Signal triggered when item was clicked by the user
     */
    public signal void item_clicked (Goo.CanvasItem? item);

    /**
     * Signal triggered when item has finished moving by the user,
     * and a change of it's coordenates was made
     */
    public signal void item_moved (Goo.CanvasItem? item);

    public weak Goo.CanvasItem? selected_item;
    private Goo.CanvasRect select_effect;

     /*
        Grabber Pos: 0 1 2
                     7   3
                     6 5 4

        // -1 if no nub is grabbed
    */
    private Goo.CanvasItemSimple[] nobs = new Goo.CanvasItemSimple[8];

    private weak Goo.CanvasItem? hovered_item;
    private Goo.CanvasRect? hover_effect;

    private bool holding;
    private double event_x_root;
    private double event_y_root;
    private double start_x;
    private double start_y;
    private double delta_x;
    private double delta_y;
    private double hover_x;
    private double hover_y;
    private double nob_size;
    private double current_scale;
    private int holding_id = -1;

    construct {
        events |= Gdk.EventMask.BUTTON_PRESS_MASK;
        events |= Gdk.EventMask.BUTTON_RELEASE_MASK;
        events |= Gdk.EventMask.POINTER_MOTION_MASK;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        remove_hover_effect ();

        current_scale = get_scale ();
        event_x_root = event.x;
        event_y_root = event.y;

       var clicked_item = get_item_at (event.x / current_scale, event.y / current_scale, true);

        if (clicked_item != null) {
            var clicked_id = get_grabbed_id (clicked_item);
            holding = true;

            if (clicked_id == -1) { // Non-nub was clicked
                remove_select_effect ();
                if (clicked_item is Goo.CanvasItemSimple) {
                    clicked_item.get ("x", out start_x, "y", out start_y);
                }

                add_select_effect (clicked_item);
                grab_focus (clicked_item);

                selected_item = clicked_item;
                holding_id = -1;
            } else { // nub was clicked
                holding_id = clicked_id;
            }
        } else {
            remove_select_effect ();
            grab_focus (get_root_item ());
        }

        return true;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        if (!holding) return false;

        holding = false;

        if (delta_x == 0 && delta_y == 0) { // Hidden for now. Just change poss && (start_w == real_width) && (start_h == real_height)) {
            return false;
        }

        item_moved (selected_item);
        add_hover_effect (selected_item);

        delta_x = 0;
        delta_y = 0;

        return false;
    }

    public override bool motion_notify_event (Gdk.EventMotion event) {
        if (!holding) {
            motion_hover_event (event);
            return false;
        }

        delta_x = (event.x - event_x_root) / current_scale;
        delta_y = (event.y - event_y_root) / current_scale;

        //  var item = ((Goo.CanvasItemSimple) selected_item);
        //  var stroke = item.line_width;
        //  var width = item.bounds.x2 - item.bounds.x1 + stroke;
        //  var height = item.bounds.y2 - item.bounds.y1 + stroke;

        switch (holding_id) {
            case -1: // Moving
                selected_item.set ("x", delta_x + start_x, "y", delta_y + start_y);

                // Bounding box
                select_effect.set ("x", delta_x + start_x - (((Goo.CanvasItemSimple) select_effect).line_width) * 2,
                                    "y", delta_y + start_y - (((Goo.CanvasItemSimple) select_effect).line_width) * 2);

                //  debug ("X:%f - Y:%f\n", ((Goo.CanvasItemSimple) selected_item).x, ((Goo.CanvasItemSimple) selected_item).y);
                break;
            case 0: // Top left
                //  delta_x = fix_position (x, real_width, start_w);
                //  delta_y = fix_position (y, real_height, start_h);
                //  real_height = fix_size ((int) (start_h - 1 / current_scale * y));
                //  real_width = fix_size ((int) (start_w - 1 / current_scale * x));
                break;
            //  case 1: // Top
            //      delta_y = fix_position (y, real_height, start_h);
            //      real_height = fix_size ((int)(start_h - 1 / current_scale * y));
            //      break;
            //  case 2: // Top right
            //      delta_y = fix_position (y, real_height, start_h);
            //      real_height = fix_size ((int)(start_h - 1 / current_scale * y));
            //      real_width = fix_size ((int)(start_w + 1 / current_scale * x));
            //      break;
            //  case 3: // Right
            //      real_width = fix_size ((int)(start_w + 1 / current_scale * x));
            //      break;
            //  case 4: // Bottom Right
            //      real_width = fix_size ((int)(start_w + 1 / current_scale * x));
            //      real_height = fix_size ((int)(start_h + 1 / current_scale * y));
            //      break;
            //  case 5: // Bottom
            //      real_height = fix_size ((int)(start_h + 1 / current_scale * y));
            //      break;
            //  case 6: // Bottom left
            //      real_height = fix_size ((int)(start_h + 1 / current_scale * y));
            //      real_width = fix_size ((int)(start_w - 1 / current_scale * x));
            //      delta_x = fix_position (x, real_width, start_w);
            //      break;
            //  case 7: // Left
            //      real_width = fix_size ((int) (start_w - 1 / current_scale * x));
            //      delta_x = fix_position (x, real_width, start_w);
            //      break;
        }

        update_nub_position (holding_id, selected_item);

        return false;
    }

    private void motion_hover_event (Gdk.EventMotion event) {
        hovered_item = get_item_at (event.x / get_scale (), event.y / get_scale (), true);

        if (!(hovered_item is Goo.CanvasItemSimple)) {
            remove_hover_effect ();
            return;
        }

        add_hover_effect (hovered_item);

        double check_x;
        double check_y;
        hovered_item.get ("x", out check_x, "y", out check_y);

        if ((hover_x != check_x || hover_y != check_y) && hover_effect != hovered_item) {
            remove_hover_effect ();
        }

        hover_x = check_x;
        hover_y = check_y;
    }

    public void add_select_effect (Goo.CanvasItem? target) {
        if (target == null || target == select_effect) {
            return;
        }

        double x, y;
        target.get ("x", out x, "y", out y);

        var item = (target as Goo.CanvasItemSimple);

        var line_width = 1.0 / current_scale;
        var real_x = x - (line_width * 2);
        var real_y = y - (line_width * 2);
        var width = item.bounds.x2 - item.bounds.x1;
        var height = item.bounds.y2 - item.bounds.y1;

        select_effect = new Goo.CanvasRect (null, real_x, real_y, width, height,
                                   "line-width", line_width,
                                   "stroke-color", "#666", null
                                   );

        select_effect.set ("parent", get_root_item ());

        nob_size = 10 / current_scale;

        for (int i = 0; i < 8; i++) {
            nobs[i] = new Goo.CanvasRect (null, 0, 0, nob_size, nob_size,
                "line-width", line_width,
                "stroke-color", "#41c9fd",
                "fill-color", "#fff", null
            );
            nobs[i].set ("parent", get_root_item ());
        }

        update_nub_position (-1, target);
        select_effect.can_focus = false;
    }

    private void remove_select_effect () {
        if (select_effect == null) {
            return;
        }

        select_effect.remove ();
        select_effect = null;
        selected_item = null;

        for (int i = 0; i < 8; i++) {
            nobs[i].remove ();
        }
    }

    private void add_hover_effect (Goo.CanvasItem? target) {
        if (target == null || hover_effect != null || target == selected_item || target == select_effect) {
            return;
        }

        if ((target as Goo.CanvasItemSimple) in nobs) {
            set_cursor_for_nob (get_grabbed_id (target));
            return;
        }

        double x, y;
        target.get ("x", out x, "y", out y);

        var item = (target as Goo.CanvasItemSimple);

        var line_width = 2.0 / get_scale ();
        var stroke = item.line_width;
        var real_x = x - (line_width * 2);
        var real_y = y - (line_width * 2);
        var width = item.bounds.x2 - item.bounds.x1 + stroke - line_width;
        var height = item.bounds.y2 - item.bounds.y1 + stroke - line_width;

        hover_effect = new Goo.CanvasRect (null, real_x, real_y, width, height,
                                   "line-width", line_width,
                                   "stroke-color", "#41c9fd", null
                                   );
        hover_effect.set ("parent", get_root_item ());

        hover_effect.can_focus = false;
    }

    private void remove_hover_effect () {
        set_cursor (Gdk.CursorType.ARROW);

        if (hover_effect == null) {
            return;
        }

        hover_effect.remove ();
        hover_effect = null;
    }

    private int get_grabbed_id (Goo.CanvasItem? target) {
        for (int i = 0; i < 8; i++) {
            if (target == nobs[i]) return i;
        }

        return -1;
    }

    private void set_cursor_for_nob (int grabbed_id) {
        switch (grabbed_id) {
            case -1:
                set_cursor (Gdk.CursorType.ARROW);
                break;
            case 0:
                set_cursor (Gdk.CursorType.TOP_LEFT_CORNER);
                break;
            case 1:
                set_cursor (Gdk.CursorType.TOP_SIDE);
                break;
            case 2:
                set_cursor (Gdk.CursorType.TOP_RIGHT_CORNER);
                break;
            case 3:
                set_cursor (Gdk.CursorType.RIGHT_SIDE);
                break;
            case 4:
                set_cursor (Gdk.CursorType.BOTTOM_RIGHT_CORNER);
                break;
            case 5:
                set_cursor (Gdk.CursorType.BOTTOM_SIDE);
                break;
            case 6:
                set_cursor (Gdk.CursorType.BOTTOM_LEFT_CORNER);
                break;
            case 7:
                set_cursor (Gdk.CursorType.LEFT_SIDE);
                break;
        }
    }

    // Updates all the nub's position arround the selected item, except for the grabbed nub
    // TODO: concider item rotation into account
    private void update_nub_position (int grabbed_nub, Goo.CanvasItem selected_item) {
        var item = (selected_item as Goo.CanvasItemSimple);
        double width;
        double height;

        var stroke = (item.line_width / 2);
        selected_item.get ("width", out width, "height", out height);

        // TOP LEFT nob
        nobs[0].set ("x", delta_x + start_x - (nob_size / 2) - stroke, 
                    "y", delta_y + start_y - (nob_size / 2) - stroke);

        // TOP CENTER nob
        nobs[1].set ("x", delta_x + start_x + (width / 2) - (nob_size / 2) - stroke,
                    "y", delta_y + start_y - (nob_size / 2) - stroke);

        // TOP RIGHT nob
        nobs[2].set ("x", delta_x + start_x + width - (nob_size / 2) + stroke,
                    "y", delta_y + start_y - (nob_size / 2) - stroke);

        // RIGHT CENTER nob
        nobs[3].set ("x", delta_x + start_x + width - (nob_size / 2) + stroke,
                    "y", delta_y + start_y + (height / 2) - (nob_size / 2) - stroke);

        // BOTTOM RIGHT nob
        nobs[4].set ("x", delta_x + start_x + width - (nob_size / 2) + stroke,
                    "y", delta_y + start_y + height - (nob_size / 2) + stroke);

        // BOTTOM CENTER nob
        nobs[5].set ("x", delta_x + start_x + (width / 2) - (nob_size / 2) - stroke,
                    "y", delta_y + start_y + height - (nob_size / 2) + stroke);

        // BOTTOM LEFT nob
        nobs[6].set ("x", delta_x + start_x - (nob_size / 2) - stroke,
                    "y", delta_y + start_y + height - (nob_size / 2) + stroke);

        // LEFT CENTER nob
        nobs[7].set ("x", delta_x + start_x - (nob_size / 2) - stroke,
                    "y", delta_y + start_y + (height / 2) - (nob_size / 2) - stroke);
    }

    private void set_cursor (Gdk.CursorType cursor_type) {
        var cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), cursor_type);
        get_window ().set_cursor (cursor);
    }

    //  // To make it so items can't become imposible to grab. TODOs
    //  private int fix_position (int delta, int length, int initial_length) {
    //      var max_delta = (initial_length - MIN_SIZE) * current_scale;
    //      if (delta < max_delta) {
    //          return delta;
    //      } else {
    //          return (int) max_delta;
    //      }
    //  }

    //  private int fix_size (int size) {
    //      return size > MIN_SIZE ? size : MIN_SIZE;
    //  }
}