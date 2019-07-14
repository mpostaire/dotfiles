-- this is an incomplete basic network widget
-- ethernet support not tested, ethernet icon is a placeholder

local wibox = require("wibox")
local beautiful = require("beautiful")
local popup_notification = require("util.popup_notification")
local rofi = require("util.rofi")
local awful = require("awful")
local gears = require("gears")
local variables = require("configuration.variables")

local p = require("dbus_proxy")

local icons = {
    wifi = "",
    off = "",
    eth = "E"
}

local state = 'off'

local notification = popup_notification:new()

local icon_widget = wibox.widget {
    {
        id = "icon",
        font = "Material Icons 12",
        widget = wibox.widget.textbox
    },
    widget = wibox.container.margin(_, beautiful.wibar_widgets_padding, beautiful.widgets_inner_padding, 0, 0)
}

local text_widget = wibox.widget {
    {
        id = "text",
        widget = wibox.widget.textbox
    },
    widget = wibox.container.margin(_, 0, beautiful.wibar_widgets_padding, 0, 0)
}

local network_widget = wibox.widget {
    icon_widget,
    text_widget,
    layout = wibox.layout.fixed.horizontal
}

local manager_proxy = p.Proxy:new(
    {
        bus = p.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager",
        path = "/org/freedesktop/NetworkManager"
    }
)

local connection_proxy
local function set_connection_proxy(connection_path)
    if manager_proxy.ActiveConnections[1] then
        connection_proxy = p.Proxy:new(
            {
                bus = p.Bus.SYSTEM,
                name = "org.freedesktop.NetworkManager",
                interface = "org.freedesktop.NetworkManager.Connection.Active",
                path = connection_path
            }
        )
    end
end

local function set_state()
    if manager_proxy.ActiveConnections[1] then
        if string.match(connection_proxy.Type, "wireless") then
            state = 'wifi'
        elseif string.match(connection_proxy.Type, "ethernet") then
            state = 'eth'
        else
            state = 'off'
        end
    else
        state = 'off'
    end
end

-- manager_proxy.ActiveConnections[1]: the first element of this array is usually the primary connection
-- if bugs, we may use manager_proxy.PrimaryConnection
set_connection_proxy(manager_proxy.ActiveConnections[1])
set_state()

local function get_icon(mouse_hover)
    if state == 'wifi' or state == 'eth' then
        if mouse_hover then
            return '<span foreground="'..beautiful.fg_normal_hover..'">'..icons[state]..'</span>'
        else
            return icons[state]
        end
    else
        if mouse_hover then
            return '<span foreground="'..beautiful.white_alt_hover..'">'..icons[state]..'</span>'
        else
            return '<span foreground ="' ..beautiful.white_alt.. '">' ..icons[state].. '</span>'
        end
    end
end

local function get_title()
    return "<b>Réseau</b>"
end

local function get_message()
    return "En construction"
end

local function get_text(mouse_hover)
    if state == 'off' then return "ERROR" end

    if mouse_hover then
        return '<span foreground="'..beautiful.fg_normal_hover..'">'..connection_proxy.Id..'</span>'
    else
        return connection_proxy.Id
    end
end

local function update_widget()
    local icon = get_icon()
    icon_widget:get_children_by_id('icon')[1]:set_markup_silently(get_icon())
    if state == 'wifi' or state == 'eth' then
        text_widget.visible = true
        text_widget:get_children_by_id('text')[1]:set_markup_silently(get_text())
    else
        text_widget.visible = false
    end

    notification:set_markup(get_title(), get_message())
    notification:set_icon(icon)
end

-- we update once so the widget is not empty at creation
update_widget()

network_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        rofi.network_menu()
    end
end)

local old_cursor, old_wibox
network_widget:connect_signal("mouse::enter", function()
    -- mouse_hover color highlight
    icon_widget:get_children_by_id('icon')[1]:set_markup_silently(get_icon(true))
    text_widget:get_children_by_id('text')[1]:set_markup_silently(get_text(true))

    local w = mouse.current_wibox
    old_cursor, old_wibox = w.cursor, w
    w.cursor = "hand1"
end)
network_widget:connect_signal("mouse::leave", function()
    -- no mouse_hover color highlight
    icon_widget:get_children_by_id('icon')[1]:set_markup_silently(get_icon())
    text_widget:get_children_by_id('text')[1]:set_markup_silently(get_text())

    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)

manager_proxy:on_properties_changed(function (p, changed, invalidated)
    assert(p == manager_proxy)
    for k, v in pairs(changed) do
        if k == "ActiveConnections" then
            if manager_proxy.ActiveConnections[1] then
                set_connection_proxy(manager_proxy.ActiveConnections[1])
            end
            set_state()
            update_widget()
        end
    end
end)

network_widget.keys = gears.table.join(
    awful.key({ variables.modkey }, "w", rofi.network_menu,
                {description = "show the network menu", group = "launcher"})
)

return network_widget
