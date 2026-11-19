-- Flat, editorial: 2px window rounding, no shadows, no blur, no transparency.
hl.config({
    decoration = {
        rounding       = 2,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive     = false,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },
})
