-- Single monitor: DP-3 / ASUS VG27V, 1920x1080 @ 165Hz.
hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- Safe fallback for any other/unknown output.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
