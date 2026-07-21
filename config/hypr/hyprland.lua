-- ~/.config/hypr/hyprland.lua
-- Hyprland Lua Configuration (API Nativa hl - Infinite Desktop Sync)

local wal_colors = {}
local wal_file = io.open(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf", "r")
if wal_file then
    for line in wal_file:lines() do
        local key, value = line:match("^%$([%w_]+)%s*=%s*(.+)$")
        if key and value then
            wal_colors[key] = value:gsub("^%s*(.-)%s*$", "%1")
        end
    end
    wal_file:close()
end

local function c(name, fallback)
    return wal_colors[name] or fallback
end

local mainMod = "SUPER"

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 0,
        col = {
            active_border = "rgba(ffffffaa)",
            inactive_border = "rgba(1a1a1aaa)",
        },
        layout = "dwindle",
        allow_tearing = false,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
    cursor = {
        no_hardware_cursors = false,
    },
    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
            size = 6,
            passes = 2,
        },
        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
        },
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4,  bezier = "default" })

-- Auto-start
hl.on("hyprland.start", function()
    hl.exec_cmd("python3 ~/scripts/infinite_desktop_core.py 1.6 > /tmp/infinite-desktop.log 2>&1")
    hl.exec_cmd("hyprctl keyword bindm SUPER_ALT, mouse_move, hyprctl dispatch workspace global")

    hl.exec_cmd("quickshell -c notifications")
    hl.exec_cmd("waybar-launcher.sh")
    hl.exec_cmd("awww-daemon")

    hl.exec_cmd("hyprctl keyword dwindle:pseudotile true")
    hl.exec_cmd("hyprctl keyword dwindle:preserve_split true")
    hl.exec_cmd("hyprctl keyword gestures:workspace_swipe true")

    hl.exec_cmd("hyprctl windowrulev2 pin,class:\\^\\(quickshell\\)\\$")
    hl.exec_cmd("hyprctl windowrulev2 noanim,class:\\^\\(quickshell\\)\\$")
    hl.exec_cmd("hyprctl windowrulev2 noblur,class:\\^\\(quickshell\\)\\$")
    hl.exec_cmd("hyprctl windowrulev2 noborder,class:\\^\\(quickshell\\)\\$")
    hl.exec_cmd("hyprctl windowrulev2 nofocus,class:\\^\\(quickshell\\)\\$")
end)

hl.window_rule({
    match = { class = "pavucontrol" },
    float = true,
})

-- Binds básicos y de aplicaciones
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("foot"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. "+ M", hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("hyprctl dispatch fullscreenstate 0 2"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell -c hyprquickpaper"))

hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("wlogout"))
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprctl dispatch pseudo"))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("hyprctl dispatch togglesplit"))

-- Workspaces (Navegación relativa sugerida para Infinite Desktop)
hl.bind(mainMod .. " + Z", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + X", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.window.move({ workspace = "+1" }))

-- Infinite Desktop / Mover y alternar layouts
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("python3 ~/scripts/floating_tile_toggle.py"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" })) -- Cambia una ventana sola flotante/mosaico

-- Navegación entre ventanas flotantes/mosaico
hl.bind(mainMod .. " + left",  hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py left"))
hl.bind(mainMod .. " + right", hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py right"))
hl.bind(mainMod .. " + up",    hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py up"))
hl.bind(mainMod .. " + down",  hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py down"))

-- Mover ventanas en modo mosaico (Tiled)
hl.bind(mainMod .. " + ALT + left",  hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py left"))
hl.bind(mainMod .. " + ALT + right", hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py right"))
hl.bind(mainMod .. " + ALT + up",    hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py up"))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py down"))

-- Mover ventanas flotantes (Hold SHIFT + SUPER + Arrows)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.exec_cmd("python3 ~/scripts/move_window.py left"),  { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("python3 ~/scripts/move_window.py right"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.exec_cmd("python3 ~/scripts/move_window.py up"),    { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.exec_cmd("python3 ~/scripts/move_window.py down"),  { repeating = true })

-- Redimensionar ventanas (Hold CTRL + SUPER + Arrows)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py left"),  { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py right"), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py up"),    { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py down"),  { repeating = true })

-- Workspaces numéricos fijos (1-5)
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Binds de ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + ALT + mouse:272", hl.dsp.exec_cmd("hyprctl dispatch workspace global"))
