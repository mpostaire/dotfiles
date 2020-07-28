local awful = require("awful")
local wibox = require("wibox")
local variables = require("config.variables")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")

local submenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "documentation", function()
        awful.spawn.easy_async(variables.browser .. " https://awesomewm.org/apidoc/", function() end)
        local screen = awful.screen.focused()
        local tag = screen.tags[2] -- TODO: automatic tag detection
        if tag then
           tag:view_only()
        end
    end },
    { "edit config", function()
        awful.spawn.easy_async(variables.gui_editor .. " " .. variables.home .. "/dotfiles", function() end)
    end },
    { "restart", _G.awesome.restart },
    { "quit", function()
        _G.awesome.quit()
    end },
}

local mainmenu = awful.menu(
    {
        items = {
            { "awesome", submenu, beautiful.awesome_icon },
            { "open terminal", function()
                awful.spawn.easy_async(variables.terminal, function() end)
            end }
        }
    }
)

local background = wibox {
    x = 0,
    y = 0,
    width = _G.mouse.screen.geometry.width,
    height = _G.mouse.screen.geometry.height,
    opacity = 0,
    visible = false,
    ontop = true,
    type = 'normal'
}

background:connect_signal("button::press", function()
    background.visible = false
    mainmenu:toggle()
end)

mainmenu:get_root().wibox:connect_signal("property::visible", function()
    background.visible = mainmenu:get_root().wibox.visible
end)

-- this function can't be named 'show' or 'toggle' or it causes stack overflow
function mainmenu.launch()
    background.visible = not background.visible
    mainmenu:toggle()
end

return mainmenu
