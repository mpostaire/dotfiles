local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local brightness = require("util.brightness")
local helpers = require("util.helpers")
local slider = require("widgets.slider")

local icon = ""

return function(width)
    local slider_width = width or 150
    -- we convert brightness value from [10,100] to [0,100] interval
    local brightness_value = ((brightness.brightness - 10) / 90) * 100

    local brightness_slider = slider {
        bar_left_color = beautiful.white,
        bar_right_color = beautiful.bg_focus,
        handle_color = beautiful.fg_normal,
        handle_shape = gears.shape.circle,
        handle_border_color = beautiful.fg_normal,
        handle_width = 14,
        value = brightness_value,
        maximum = 100,
        forced_width = slider_width,
        forced_height = 4
    }

    local icon_widget = wibox.widget {
        markup = icon,
        font = helpers.change_font_size(beautiful.icon_font, 16),
        widget = wibox.widget.textbox
    }
    local widget = wibox.widget {
        {
            icon_widget,
            right = 8,
            widget = wibox.container.margin
        },
        brightness_slider,
        nil,
        layout = wibox.layout.align.horizontal
    }

    widget._private.brightness_updating_value = false
    widget._private.mouse_updating_value = false
    local handle = brightness_slider.handle
    handle:connect_signal("property::value", function()
        -- if we are updating handle.value because brightness changed we do not want to change it again to prevent loops
        if widget._private.brightness_updating_value then
            widget._private.brightness_updating_value = false
            return
        else
            widget._private.mouse_updating_value = true
            -- handle.value is changed to fit in the [10,100] interval
            brightness.set_brightness(((handle.value / 100) * 90) + 10)
        end
    end)

    brightness.on_properties_changed(function()
        if widget._private.mouse_updating_value then
            widget._private.mouse_updating_value = false
            return
        end
        widget._private.brightness_updating_value = true
        handle.value = ((brightness.brightness - 10) / 90) * 100
    end)

    brightness_slider:buttons(gears.table.join(
        awful.button({}, 4, function()
            brightness.inc_brightness(5)
        end),
        awful.button({}, 5, function()
            brightness.dec_brightness(5)
        end)
    ))

    widget.type = "control_widget"
    widget.group = "slider"

    return widget
end
