local awful = require("awful")
local gears = require("gears")
local dbus = require("dbus_proxy")

local brightness = {}

local proxy
local function init_proxy()
    proxy = dbus.Proxy:new(
        {
            bus = dbus.Bus.SESSION,
            name = "fr.mpostaire.awdctl",
            interface = "fr.mpostaire.awdctl.Brightness",
            path = "/fr/mpostaire/awdctl/Brightness"
        }
    )
end

if pcall(init_proxy) then
    brightness.enabled = true
else
    brightness.enabled = false
    return brightness
end

local on_properties_changed_callbacks = {}

proxy:on_properties_changed(function (p, changed, invalidated)
    assert(p == proxy)
    local call_callback = false
    for k,v in pairs(changed) do
        if k == "Percentage" then
            brightness.brightness = v
            call_callback = true
        end
    end

    if call_callback then
        for _,v in pairs(on_properties_changed_callbacks) do
            v()
        end
    end
end)

brightness.brightness = proxy.Percentage

function brightness.set_brightness(value)
    proxy:SetBrightness(value)
end

function brightness.inc_brightness(value)
    proxy:IncBrightness(value)
end

function brightness.dec_brightness(value)
    proxy:DecBrightness(value)
end

function brightness.on_properties_changed(func)
    table.insert(on_properties_changed_callbacks, func)
end

local keys = gears.table.join(
    awful.key({}, "XF86MonBrightnessUp", function()
        brightness.inc_brightness(5)
    end,
    {description = "brightness up", group = "other"}),
    awful.key({}, "XF86MonBrightnessDown", function()
        brightness.dec_brightness(5)
    end,
    {description = "brightness down", group = "other"})
)

_G.root.keys(gears.table.join(_G.root.keys(), keys))

return brightness
