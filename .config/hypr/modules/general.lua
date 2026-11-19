local colors = require("modules.colors")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    cursor = {
        no_hardware_cursors = true,
        inactive_timeout    = 0,
    },

    general = {
        gaps_in     = 3,
        gaps_out    = 5,
        border_size = 1,

        col = {
            active_border   = { colors = { colors.rgba("cream") }, angle = 45 },
            inactive_border = colors.rgba("line"),
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        force_split    = 0,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
        disable_splash_rendering = true,
        focus_on_activate       = true,
    },

    layers = {
        allow_new_top_layers_over_existing_fullscreen = true,
    },

    env = {
        "LC_TIME,ru_RU.UTF-8",
        "TZ,Asia/Vladivostok",
    },
})
