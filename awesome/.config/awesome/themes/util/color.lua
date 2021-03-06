local color = {}

local xresources = require("beautiful.xresources")
local xresources_theme = xresources.get_current_theme()

color.bg = xresources_theme["background"]
color.fg = xresources_theme["foreground"]

color.black = xresources_theme["color0"]
color.black_alt = xresources_theme["color8"]

color.red = xresources_theme["color1"]
color.red_alt = xresources_theme["color9"]

color.green = xresources_theme["color2"]
color.green_alt = xresources_theme["color10"]

color.yellow = xresources_theme["color3"]
color.yellow_alt = xresources_theme["color11"]

color.blue = xresources_theme["color4"]
color.blue_alt = xresources_theme["color12"]

color.magenta = xresources_theme["color5"]
color.magenta_alt = xresources_theme["color13"]

color.cyan = xresources_theme["color6"]
color.cyan_alt = xresources_theme["color14"]

color.white = xresources_theme["color7"]
color.white_alt = xresources_theme["color15"]

color.true_white = "#FFFFFF"
color.true_black = "#000000"

local mt_2D = {
    __index = function(t, k)
            local inner = {}
            rawset(t, k, inner)
            return inner
        end
}
local color_lighten_cache = setmetatable({}, mt_2D)
local color_darken_cache = setmetatable({}, mt_2D)

-- c is a string hex representation of a rgb color
local function rgbhex_to_rgbtable(c)
    local R, G, B = c:match("#(%x%x)(%x%x)(%x%x)")
    return {r = tonumber(R, 16), g = tonumber(G, 16), b = tonumber(B, 16)}
end

local function round(x)
    return x + 0.5 - (x + 0.5) % 1
end

-- c is a table representation of a rgb color
local function rgbtable_to_rgbhex(c)
    return "#" .. string.format("%.2x", round(c.r)) .. string.format("%.2x", round(c.g)) .. string.format("%.2x", round(c.b))
end

-- c is a rgb table
local function rgb_to_hsl(c)
    local temp = {r = c.r / 255, g = c.g / 255, b = c.b / 255}
    local min = math.min(temp.r, temp.g, temp.b)
    local max = math.max(temp.r, temp.g, temp.b)

    local delta = max- min

    local L = (max + min) / 2
    local H, S

    if delta == 0 then
        H, S = 0, 0
    else
        if L < 0.5 then
            S = delta / (max + min)
        else
            S = delta / (2 - max - min)
        end

        local delta_r = (((max - temp.r) / 6) + (delta / 2)) / delta
        local delta_g = (((max - temp.g) / 6) + (delta / 2)) / delta
        local delta_b = (((max - temp.b) / 6) + (delta / 2)) / delta

        if temp.r == max then
            H = delta_b - delta_g
        elseif temp.g == max then
            H = (1 / 3) + delta_r - delta_b
        elseif temp.b == max then
            H = (2 / 3) + delta_g - delta_r
        end

        if H < 0 then H = H + 1 end
        if H > 1 then H = H - 1 end
    end

    return {h = H * 360, s = S, l = L}
end

local function hue_to_rgb(var1, var2, h)
    if h < 0 then h = h + 1 end
    if h > 1 then h = h - 1 end
    if (6 * h) < 1 then
        return var1 + (var2 - var1) * 6 * h
    end
    if (2 * h) < 1 then
        return var2
    end
    if (3 * h) < 2 then
        return var1 + ((var2 - var1) * ((2 / 3) - h) * 6)
    end
    return var1
end

-- c is a hsl table
local function hsl_to_rgb(c)
    local temp = {h = c.h / 360, s = c.s, l = c.l}

    local R, G, B
    if temp.s == 0 then
        R = temp.l * 255
        G = temp.l * 255
        B = temp.l * 255
    else
        local var1, var2
        if temp.l < 0.5 then
            var2 = temp.l * (1 + temp.s)
        else
            var2 = (temp.l + temp.s) - (temp.s * temp.l)
        end
        var1 = 2 * temp.l - var2

        R = 255 * hue_to_rgb(var1, var2, temp.h + (1 / 3))
        G = 255 * hue_to_rgb(var1, var2, temp.h)
        B = 255 * hue_to_rgb(var1, var2, temp.h - (1 / 3))
    end

    return {r = R, g = G, b = B}
end

-- c is a hex representation of a rgb color, 0 <= value <= 1
function color.lighten_by(c, value)
    if color_lighten_cache[c][value] then return color_lighten_cache[c][value] end

    local temp = rgbhex_to_rgbtable(c)
    temp = rgb_to_hsl(temp)

    local delta = 1 - temp.l
    temp.l = temp.l + delta * value

    temp = hsl_to_rgb(temp)
    color_lighten_cache[c][value] = rgbtable_to_rgbhex(temp)
    return color_lighten_cache[c][value]
end

-- c is a hex representation of a rgb color, 0 <= value <= 1
function color.darken_by(c, value)
    if color_darken_cache[c][value] then return color_darken_cache[c][value] end
    
    local temp = rgbhex_to_rgbtable(c)
    temp = rgb_to_hsl(temp)

    temp.l = temp.l - temp.l * value

    temp = hsl_to_rgb(temp)
    color_darken_cache[c][value] = rgbtable_to_rgbhex(temp)
    return color_darken_cache[c][value]
end

return color
