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
    public weak Goo.CanvasItem? select_effect;

     /*
        Grabber Pos: 0 1 2
                     7   3
                     6 5 4

        // -1 if no nub is grabbed
    */
    public Goo.CanvasItemSimple[] nobs = new Goo.CanvasItemSimple[8];

    public weak Goo.CanvasItem? hovered_item;
    public weak Goo.CanvasRect? hover_effect;

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
        remove_select_effect ();

        current_scale = get_scale ();
        event_x_root = event.x;
        event_y_root = event.y;

        var clicked_item = get_item_at (event.x / current_scale, event.y / current_scale, true);

        if (clicked_item != null) {
            if (clicked_item is Goo.CanvasItemSimple) {
                start_x = (clicked_item as Goo.CanvasItemSimple).x;
                start_y = (clicked_item as Goo.CanvasItemSimple).y;
            }

            holding = true;
            add_select_effect (clicked_item);
            grab_focus (selected_item);

            selected_item = clicked_item;
        } else {
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

        var item = ((Goo.CanvasItemSimple) selected_item);
        var stroke = item.line_width;
        var width = item.bounds.x2 - item.bounds.x1 + stroke;
        var height = item.bounds.y2 - item.bounds.y1 + stroke;

        switch (holding_id) {
            case -1: // Moving
                ((Goo.CanvasItemSimple) selected_item).x = delta_x + start_x;
                ((Goo.CanvasItemSimple) selected_item).y = delta_y + start_y;

                // Bounding box
                ((Goo.CanvasItemSimple) select_effect).x = delta_x + start_x - ((Goo.CanvasItemSimple) selected_item).line_width;
                ((Goo.CanvasItemSimple) select_effect).y = delta_y + start_y - ((Goo.CanvasItemSimple) selected_item).line_width;

                debug ("X:%f - Y:%f\n", ((Goo.CanvasItemSimple) selected_item).x, ((Goo.CanvasItemSimple) selected_item).y);
                break;
            //  case 1: // Top left
            //      delta_x = fix_position (x, real_width, start_w);
            //      delta_y = fix_position (y, real_height, start_h);
            //      real_height = fix_size ((int) (start_h - 1 / current_scale * y));
            //      real_width = fix_size ((int) (start_w - 1 / current_scale * x));
            //      break;
            //  case 2: // Top
            //      delta_y = fix_position (y, real_height, start_h);
            //      real_height = fix_size ((int)(start_h - 1 / current_scale * y));
            //      break;
            //  case 3: // Top right
            //      delta_y = fix_position (y, real_height, start_h);
            //      real_height = fix_size ((int)(start_h - 1 / current_scale * y));
            //      real_width = fix_size ((int)(start_w + 1 / current_scale * x));
            //      break;
            //  case 4: // Right
            //      real_width = fix_size ((int)(start_w + 1 / current_scale * x));
            //      break;
            //  case 5: // Bottom Right
            //      real_width = fix_size ((int)(start_w + 1 / current_scale * x));
            //      real_height = fix_size ((int)(start_h + 1 / current_scale * y));
            //      break;
            //  case 6: // Bottom
            //      real_height = fix_size ((int)(start_h + 1 / current_scale * y));
            //      break;
            //  case 7: // Bottom left
            //      real_height = fix_size ((int)(start_h + 1 / current_scale * y));
            //      real_width = fix_size ((int)(start_w - 1 / current_scale * x));
            //      delta_x = fix_position (x, real_width, start_w);
            //      break;
            //  case 8: // Left
            //      real_width = fix_size ((int) (start_w - 1 / current_scale * x));
            //      delta_x = fix_position (x, real_width, start_w);
            //      break;
        }

        update_nub_position (holding_id, selected_item);

        return false;
    }

    private void motion_hover_event (Gdk.EventMotion event) {
        hovered_item = get_item_at (event.x / get_scale (), event.y / get_scale (), true);

        if (!(hovered_item is Goo.CanvasItem)) {
            remove_hover_effect ();
            return;
        }

        add_hover_effect (hovered_item);

        if ((hover_x != (hovered_item as Goo.CanvasItemSimple).x
            || hover_y != (hovered_item as Goo.CanvasItemSimple).y)
            && hover_effect != hovered_item
            ) {
            remove_hover_effect ();
        }

        hover_x = (hovered_item as Goo.CanvasItemSimple).x;
        hover_y = (hovered_item as Goo.CanvasItemSimple).y;
    }

    private void add_select_effect (Goo.CanvasItem? target) {
        if (target == null || target == select_effect) {
            return;
        }

        var item = (target as Goo.CanvasItemSimple);

        var line_width = 1.0 / current_scale;
        var stroke = item.line_width;
        var x = item.x - stroke;
        var y = item.y - stroke;
        var width = item.bounds.x2 - item.bounds.x1 + stroke;
        var height = item.bounds.y2 - item.bounds.y1 + stroke;

        select_effect = Goo.CanvasRect.create (get_root_item (), x, y, width, height,
                                   "line-width", line_width,
                                   "stroke-color", "#666"
                                   );

        nob_size = 10 / current_scale;

        for (int i = 0; i < 8; i++) {
            nobs[i] = Goo.CanvasRect.create (get_root_item (), 0, 0, nob_size, nob_size,
                "line-width", line_width,
                "stroke-color", "#41c9fd",
                "fill-color", "#fff"
            );

            //nobs[i].can_focus = false;
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

        nobs[0].remove ();
        nobs[6].remove ();
        nobs[2].remove ();
        nobs[4].remove ();
        nobs[1].remove ();
        nobs[3].remove ();
        nobs[5].remove ();
        nobs[7].remove ();
    }

    private void add_hover_effect (Goo.CanvasItem? target) {
        if (target == null || hover_effect != null || target == selected_item || target == select_effect) {
            return;
        }

        if ((target as Goo.CanvasItemSimple) in nobs) {
            set_cursor_for_nob (get_grabbed_id (target));
            return;
        }

        var item = (target as Goo.CanvasItemSimple);

        var line_width = 2.0 / get_scale ();
        var stroke = item.line_width;
        var x = item.x - stroke;
        var y = item.y - stroke;
        var width = item.bounds.x2 - item.bounds.x1 + stroke;
        var height = item.bounds.y2 - item.bounds.y1 + stroke;

        hover_effect = Goo.CanvasRect.create (get_root_item (), x, y, width, height,
                                   "line-width", line_width,
                                   "stroke-color", "#41c9fd"
                                   );

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
        var item = ((Goo.CanvasItemSimple) selected_item);
        var stroke = item.line_width;
        var width = item.bounds.x2 - item.bounds.x1 + stroke;
        var height = item.bounds.y2 - item.bounds.y1 + stroke;

        // TOP LEFT nob
        nobs[0].x = delta_x + start_x - (nob_size / 2) - stroke;
        nobs[0].y = delta_y + start_y - (nob_size / 2) - stroke;

        // TOP CENTER nob
        nobs[1].x = delta_x + start_x + (width / 2) - (nob_size / 2) - stroke;
        nobs[1].y = delta_y + start_y - (nob_size / 2) - stroke;

        // TOP RIGHT nob
        nobs[2].x = delta_x + start_x + width - (nob_size / 2) - stroke;
        nobs[2].y = delta_y + start_y - (nob_size / 2) - stroke;

        // RIGHT CENTER nob
        nobs[3].x = delta_x + start_x + width - (nob_size / 2) - stroke;
        nobs[3].y = delta_y + start_y + (height / 2) - (nob_size / 2) - stroke;

        // BOTTOM RIGHT nob
        nobs[4].x = delta_x + start_x + width - (nob_size / 2) - stroke;
        nobs[4].y = delta_y + start_y + height - (nob_size / 2) - stroke;

        // BOTTOM CENTER nob
        nobs[5].x = delta_x + start_x + (width / 2) - (nob_size / 2) - stroke;
        nobs[5].y = delta_y + start_y + height - (nob_size / 2) - stroke;

        // BOTTOM LEFT nob
        nobs[6].x = delta_x + start_x - (nob_size / 2) - stroke;
        nobs[6].y = delta_y + start_y + height - (nob_size / 2) - stroke;

        // LEFT CENTER nob
        nobs[7].x = delta_x + start_x - (nob_size / 2) - stroke;
        nobs[7].y = delta_y + start_y + (height / 2) - (nob_size / 2) - stroke;
    }

    private void set_cursor (Gdk.CursorType cursor_type) {
        var cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), cursor_type);
        get_window ().get_screen ().get_root_window ().set_cursor (cursor);
    }

    // To make it so items can't become imposible to grab. TODOs
    private int fix_position (int delta, int length, int initial_length) {
        var max_delta = (initial_length - MIN_SIZE) * current_scale;
        if (delta < max_delta) {
            return delta;
        } else {
            return (int) max_delta;
        }
    }

    private int fix_size (int size) {
        return size > MIN_SIZE ? size : MIN_SIZE;
    }
}