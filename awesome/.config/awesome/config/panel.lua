local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local widgets = require("widgets")

awful.screen.connect_for_each_screen(function(s)
    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = beautiful.wibar_height })

    -- Add widgets to the wibox
    s.mywibox:setup {
        {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                widgets.launcher(),
                s.mytaglist,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                -- widgets.archupdates, -- commented to hide it for now (when I translate wigets in OOP, this will be prettier)
                widgets.network(),
                widgets.timedate("%H:%M"),
                widgets.group({
                    widgets.brightness(false),
                    widgets.volume(false),
                    widgets.player(),
                    widgets.battery(),
                    widgets.power()
                }),
                s.mylayoutbox
            },
        },
        bottom = beautiful.wibar_bottom_border_width,
        color = beautiful.wibar_border_color,
        widget = wibox.container.margin,
    }
end)
