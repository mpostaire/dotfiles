local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local client_menu = require("popups.client_menu")
local capi = {client = client}

awful.titlebar.enable_tooltip = false

-- Add a titlebar if titlebars_enabled is set to true in the rules.
capi.client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            -- client_menu.hide()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            client_menu.show(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            -- awful.titlebar.widget.floatingbutton (c),
            -- awful.titlebar.widget.stickybutton   (c),
            -- awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
