-- TODO: make this app switcher work for all tags of one screen
-- replace tasklist by a custom widget because we want to highlight a client before selecting it
--  --> we want to focus the selected client only when app switcher is closed, when keys are released
-- we want to use history so when we use app switcher, the first client to be selected will be the next, then
-- when we reopen app switcher, the first client to be selected will be the one precedently selected
-- (check with gnome how it works)
-- we want to prevent popup from being visible when there is 0 clients to show

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local variables = require("config.variables")

-- check if client 'c' is in selected tags
local function selected_tags_filter(c)
    -- Include sticky client too
    if c.sticky then return true end
    for _,v in pairs(awful.screen.focused().selected_tags) do
        if c.first_tag == v then
            return true
        end
    end
    return false
end

local function focus_client(c)
    c:emit_signal(
        "request::activate",
        "tasklist",
        {raise = true}
    )
end

local function focus_next_client()
    local iterator = awful.client.iterate(selected_tags_filter)
    iterator()
    local c = iterator()
    if c then focus_client(c) end
end

local function focus_prev_client()
    local last_client
    for c in awful.client.iterate(selected_tags_filter) do
        last_client = c
    end
    if last_client then focus_client(last_client) end
end

local function selected_tags_client_count()
    local count = 0
    for _ in awful.client.iterate(selected_tags_filter) do
        count = count + 1
    end
    return count
end

-- appswitcher mouse handling
local tasklist_buttons = {
    awful.button({variables.altkey}, 1, function (c)
        if c ~= _G.client.focus then
            focus_client(c)
        end
    end),
    awful.button({ }, 4, focus_next_client),
    awful.button({ }, 5, focus_prev_client)
}

-- TODO use client.connect_signal("request::manage", function(c) end) to update appswitcher

local appswitcher = awful.popup {
    widget = awful.widget.tasklist {
        screen = _G.mouse.screen,
        filter = selected_tags_filter,
        buttons = tasklist_buttons,
        layout = {
            -- spacing = 5,
            -- forced_num_rows = 2,
            layout = wibox.layout.grid.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            id = 'clienticon',
                            forced_height = dpi(110),
                            forced_width = dpi(110),
                            widget = awful.widget.clienticon,
                        },
                        halign = 'center',
                        widget = wibox.container.place
                    },
                    nil,
                    {
                        {
                            id = 'text_role',
                            widget = wibox.widget.textbox,
                        },
                        halign = 'center',
                        widget = wibox.container.place
                    },
                    forced_height = dpi(128),
                    forced_width = dpi(128),
                    layout = wibox.layout.align.vertical
                },
                margins = dpi(4),
                widget  = wibox.container.margin,
            },
            id = 'background_role',
            widget = wibox.container.background,
            create_callback = function(self, c, index, objects) --luacheck: no unused
                self:get_children_by_id('clienticon')[1].client = c
            end
        },
    },
    border_color = beautiful.border_normal,
    border_width = beautiful.border_width,
    ontop = true,
    placement = awful.placement.centered,
    visible = false
}

awful.keygrabber {
    keybindings = {
        {{variables.altkey}, 'Tab', focus_next_client},
        {{variables.altkey, 'Shift'}, 'Tab', focus_prev_client},
    },
    -- Note that it is using the key name and not the modifier name.
    stop_key = variables.altkey,
    stop_event = 'release',
    start_callback = function()
        if selected_tags_client_count() > 0 then
            appswitcher.visible = true
            awful.client.focus.history.disable_tracking()
        end
    end,
    stop_callback = function()
        if appswitcher.visible then
            appswitcher.visible = false
            awful.client.focus.history.enable_tracking()
        end
    end,
    root_keybindings = {
        {{variables.altkey}, 'Tab', focus_next_client, nil, {description = 'app switcher', group = 'client'}},
        {{variables.altkey, 'Shift'}, 'Tab', focus_prev_client, nil, {description = 'reverse app switcher', group = 'client'}},
    },
}

-- client.connect_signal("request::manage", function(c)
--     for client in awful.client.iterate(awful.widget.tasklist.filter.currenttags) do
--         count = count + 1
--     end

--     appswitcher.widget.widget = wibox.widget {
--         {
--             text = '1',
--             widget = wibox.widget.textbox
--         },
--         {
--             text = '2',
--             widget = wibox.widget.textbox
--         },
--         layout = wibox.layout.fixed.horizontal
--     }
-- end)

return appswitcher
