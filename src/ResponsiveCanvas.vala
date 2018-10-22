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

    private bool holding;
    private double event_x_root;
    private double event_y_root;
    private double start_x;
    private double start_y;
    private double delta_x;
    private double delta_y;
    private double current_scale;
    private int holding_id = 0;

    construct {
        events |= Gdk.EventMask.BUTTON_PRESS_MASK;
        events |= Gdk.EventMask.BUTTON_RELEASE_MASK;
        events |= Gdk.EventMask.POINTER_MOTION_MASK;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        current_scale = get_scale ();
        event_x_root = event.x;
        event_y_root = event.y;

        selected_item = get_item_at (event.x / current_scale, event.y / current_scale, true);

        if (selected_item != null) {
            if (selected_item is Goo.CanvasItemSimple) {
                start_x = (selected_item as Goo.CanvasItemSimple).x;
                start_y = (selected_item as Goo.CanvasItemSimple).y;
            }

            holding = true;
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

        delta_x = 0;
        delta_y = 0;

        return false;
    }

    public override bool motion_notify_event (Gdk.EventMotion event) {
        if (holding) {
            delta_x = (event.x - event_x_root) / current_scale;
            delta_y = (event.y - event_y_root) / current_scale;
            switch (holding_id) {
                case 0: // Moving
                    ((Goo.CanvasItemSimple) selected_item).x = delta_x + start_x;
                    ((Goo.CanvasItemSimple) selected_item).y = delta_y + start_y;
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

        }

        return false;
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