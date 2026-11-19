-- Short ease-out fades. speed is in deciseconds (1 = 100ms).
-- Windows: 160ms opacity fade, no popin scale. Layers/panels: 120ms. Borders: 90ms.
hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("easeOut", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
hl.curve("linear",  { type = "bezier", points = { {0, 0},    {1, 1}   } })

hl.animation({ leaf = "global",        enabled = true, speed = 1.2, bezier = "easeOut" })
hl.animation({ leaf = "border",        enabled = true, speed = 0.9, bezier = "easeOut" })

hl.animation({ leaf = "windows",       enabled = true, speed = 1.6, bezier = "easeOut" })
hl.animation({ leaf = "windowsIn",     enabled = false })
hl.animation({ leaf = "windowsOut",    enabled = false })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 1.6, bezier = "easeOut" })

hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.6, bezier = "easeOut" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.6, bezier = "linear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 1.2, bezier = "easeOut" })
hl.animation({ leaf = "fadeSwitch",    enabled = true, speed = 1.2, bezier = "easeOut" })
hl.animation({ leaf = "fadeDim",       enabled = true, speed = 1.2, bezier = "easeOut" })

hl.animation({ leaf = "layers",        enabled = true, speed = 1.2, bezier = "easeOut" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 1.2, bezier = "easeOut" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.2, bezier = "linear" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.2, bezier = "easeOut" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.2, bezier = "linear" })

hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.2, bezier = "easeOut", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.2, bezier = "easeOut", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.2, bezier = "easeOut", style = "fade" })

hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 1.2, bezier = "easeOut" })
