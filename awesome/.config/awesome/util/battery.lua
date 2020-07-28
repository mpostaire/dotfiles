-- This module supports only one battery. Unknown behaviour when more than one is used.
local dbus = require("dbus_proxy")

local battery = {}
-- TODO: rewrite using lgi.require('UPowerGlib') (https://github.com/lexa/awesome_upower_battery/blob/master/init.lua)
-- TODO: handle cases where battery state is not "charging", "discharging" or "full"
local states = {
    [0] = "unknown",
    "charging",
    "discharging",
    "empty",
    "full",
    "pending_charge",
    "pending_discharge"
}

local on_properties_changed_callbacks = {}

-- For now get only the first battery device
local function get_first_battery_proxy()
    local proxy
    local function init_proxy()
        proxy = dbus.Proxy:new(
            {
                bus = dbus.Bus.SYSTEM,
                name = "org.freedesktop.UPower",
                interface = "org.freedesktop.UPower",
                path = "/org/freedesktop/UPower"
            }
        )
    end

    if not pcall(init_proxy) then
        return
    end

    local devices = proxy:EnumerateDevices()
    for _, v in ipairs(devices) do
        local device_proxy = dbus.Proxy:new(
            {
                bus = dbus.Bus.SYSTEM,
                name = "org.freedesktop.UPower",
                interface = "org.freedesktop.UPower.Device",
                path = v
            }
        )
        if device_proxy.Type == 2 then
            return device_proxy
        end
    end

    proxy = nil
end

local proxy = get_first_battery_proxy()
if proxy then
    battery.enabled = true
else
    battery.enabled = false
    return battery
end

proxy:on_properties_changed(function (p, changed, invalidated)
    assert(p == proxy)
    local call_callback = false
    for k, v in pairs(changed) do
        if k == "Percentage" then
            battery.percentage = v
            call_callback = true
        elseif k == "State" then
            battery.state = states[v]
            call_callback = true
        elseif k == "TimeToFull" then
            battery.time_to_full = v
            call_callback = true
        elseif k == "TimeToEmpty" then
            battery.time_to_empty = v
            call_callback = true
        end
    end

    if call_callback then
        for _,v in pairs(on_properties_changed_callbacks) do
            v(changed)
        end
    end
end)

battery.percentage, battery.state = proxy.Percentage, states[proxy.State]
battery.time_to_full, battery.time_to_empty = proxy.TimeToFull, proxy.TimeToEmpty

function battery.on_properties_changed(func)
    table.insert(on_properties_changed_callbacks, func)
end

return battery
