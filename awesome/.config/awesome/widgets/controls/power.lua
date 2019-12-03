local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local capi = {awesome = awesome}

local icons = {
    reboot = "",
    suspend = "",
    lock = "",
    disconnect = "", -- TODO: find a better icon
    poweroff = ""
}

return function()
    local font = string.gsub(beautiful.icon_font, "%d+", "16")

    local reboot = wibox.widget {
        {
            {
                align  = 'center',
                markup = icons.reboot,
                font = font,
                widget = wibox.widget.textbox
            },
            margins = 5,
            widget = wibox.container.margin
        },
        widget = wibox.container.background
    }

    local suspend = wibox.widget {
        {
            {
                align  = 'center',
                markup = icons.suspend,
                font = font,
                widget = wibox.widget.textbox
            },
            margins = 5,
            widget = wibox.container.margin
        },
        widget = wibox.container.background
    }

    local lock = wibox.widget {
        {
            {
                align  = 'center',
                markup = icons.lock,
                font = font,
                widget = wibox.widget.textbox
            },
            margins = 5,
            widget = wibox.container.margin
        },
        widget = wibox.container.background
    }

    local disconnect = wibox.widget {
        {
            {
                align  = 'center',
                markup = icons.disconnect,
                font = font,
                widget = wibox.widget.textbox
            },
            margins = 5,
            widget = wibox.container.margin
        },
        widget = wibox.container.background
    }

    local poweroff = wibox.widget {
        {
            {
                align  = 'center',
                markup = icons.poweroff,
                font = font,
                widget = wibox.widget.textbox
            },
            margins = 5,
            widget = wibox.container.margin
        },
        widget = wibox.container.background
    }

    local widget = wibox.widget {
        lock,
        disconnect,
        suspend,
        reboot,
        poweroff,
        spacing = 8,
        layout = wibox.layout.flex.horizontal
    }

    lock:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn.easy_async_with_shell("~/.scripts/lock.sh", function() end)
            widget.parent.control_popup.visible = false
        end)
    ))

    disconnect:buttons(gears.table.join(
        awful.button({}, 1, function()
            capi.awesome.quit()
            widget.parent.control_popup.visible = false
        end)
    ))

    suspend:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn.easy_async_with_shell("systemctl suspend", function() end)
            widget.parent.control_popup.visible = false
        end)
    ))

    reboot:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn.easy_async_with_shell("systemctl reboot", function() end)
            widget.parent.control_popup.visible = false
        end)
    ))

    poweroff:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn.easy_async_with_shell("systemctl -i poweroff", function() end)
            widget.parent.control_popup.visible = false
        end)
    ))

    lock:connect_signal("mouse::enter", function()
        lock.bg = beautiful.fg_normal
        lock.fg = beautiful.bg_normal
    end)
    lock:connect_signal("mouse::leave", function()
        lock.bg = beautiful.bg_normal
        lock.fg = beautiful.fg_normal
    end)

    disconnect:connect_signal("mouse::enter", function()
        disconnect.bg = beautiful.fg_normal
        disconnect.fg = beautiful.bg_normal
    end)
    disconnect:connect_signal("mouse::leave", function()
        disconnect.bg = beautiful.bg_normal
        disconnect.fg = beautiful.fg_normal
    end)

    suspend:connect_signal("mouse::enter", function()
        suspend.bg = beautiful.fg_normal
        suspend.fg = beautiful.bg_normal
    end)
    suspend:connect_signal("mouse::leave", function()
        suspend.bg = beautiful.bg_normal
        suspend.fg = beautiful.fg_normal
    end)

    reboot:connect_signal("mouse::enter", function()
        reboot.bg = beautiful.fg_normal
        reboot.fg = beautiful.bg_normal
    end)
    reboot:connect_signal("mouse::leave", function()
        reboot.bg = beautiful.bg_normal
        reboot.fg = beautiful.fg_normal
    end)

    poweroff:connect_signal("mouse::enter", function()
        poweroff.bg = beautiful.fg_normal
        poweroff.fg = beautiful.bg_normal
    end)
    poweroff:connect_signal("mouse::leave", function()
        poweroff.bg = beautiful.bg_normal
        poweroff.fg = beautiful.fg_normal
    end)

    widget.type = "control_widget"

    return widget
end