-- Floating rules and preserved stock fixes.

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- Floating utility windows (mixer, portal pickers) sit flat with no border noise.
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
    size  = "900 640",
    center = true,
})

hl.window_rule({
    name  = "float-portal-gtk",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float  = true,
    center = true,
})
