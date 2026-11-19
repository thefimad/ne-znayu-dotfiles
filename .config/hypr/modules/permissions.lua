-- Hyprland 0.57 gatekeeps screencopy. Allow the tools we actually use.
-- Enforcement stays off for the live session; these entries take effect if it
-- is enabled later (ecosystem.enforce_permissions = true, needs a restart).
hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/slurp", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprshot", "screencopy", "allow")
hl.permission("/usr/lib/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/(bin|lib|libexec|lib64)/xdg-desktop-portal(-gtk|-hyprland)?", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
