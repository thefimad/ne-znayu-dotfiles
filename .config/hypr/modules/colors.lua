-- Palette: single source of truth for Hyprland and Quickshell.
-- Mirrored into ~/.config/quickshell/core/Theme.qml by ~/.local/bin/theme-sync.
-- Only edit hex literals here; never add other colors.

local colors = {
    bg0        = "#070707",
    bg1        = "#0E0E0D",
    bg2        = "#171716",
    line       = "#2A2A27",
    lineStrong = "#3D3D38",
    ink        = "#EDE9DF",
    inkDim     = "#8F8D84",
    cream      = "#E9E3D5",
    amber      = "#D98A3F",
}

-- Hyprland wants 0xRRGGBBAA for plain color options and rgba(RRGGBBAA) for gradients.
function colors.rgba(name, alpha)
    local hex = colors[name]:gsub("#", "")
    return "rgba(" .. hex .. (alpha or "ff") .. ")"
end

return colors
