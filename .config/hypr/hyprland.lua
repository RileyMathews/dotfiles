-- Hyprland Lua config for the root-level stow layout.
-- See: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

local function hostname()
    local handle = io.popen("hostname", "r")
    if handle == nil then
        return os.getenv("HOSTNAME") or ""
    end

    local value = handle:read("*l") or ""
    handle:close()

    return value:gsub("%s+$", "")
end

local monitors_by_host = {
    ds9 = {
        {
            output = "DP-1",
            mode = "3840x2160@144",
            position = "0x0",
            vrr = 1,
            scale = 1,
            -- bitdepth = 10,
            -- cm = "hdr",
            -- sdrbrightness = 0.94,
            -- sdrsaturation = 0.98,
            -- sdr_max_luminance = 604,
            -- sdr_min_luminance = 0.101,
            -- sdr_eotf = "srgb",
        },
        {
            output = "HDMI-A-1",
            mode = "3440x1440@60",
            position = "-3440x0",
            vrr = 0,
            scale = 1,
            bitdepth = 10,
            cm = "srgb",
        },
    },

    picard = {
        {
            output = "eDP-2",
            mode = "3840x2160@60.00",
            position = "3840x0",
            scale = 2,
            vrr = 0,
        },
        {
            output = "eDP-1",
            mode = "3840x2160@60.00",
            position = "3840x0",
            vrr = 0,
            scale = 2,
        },
        {
            output = "DP-3",
            mode = "3840x2160@144",
            position = "0x0",
            vrr = 1,
            scale = 1,
            -- bitdepth = 10,
            -- cm = "hdr",
            -- sdrbrightness = 0.94,
            -- sdrsaturation = 0.98,
            -- sdr_max_luminance = 604,
            -- sdr_min_luminance = 0.101,
            -- sdr_eotf = "srgb",
        },
        {
            output = "HDMI-A-1",
            mode = "3440x1440@60",
            position = "-3440x0",
            vrr = 0,
            scale = 1,
            bitdepth = 10,
            cm = "srgb",
        },
    },

    scotty = {
        {
            output = "DP-1",
            mode = "3840x2160@60",
            position = "0x0",
            scale = 1,
            vrr = 0,
            bitdepth = 10,
            cm = "hdr",
            sdrbrightness = 1.08,
            sdrsaturation = 0.98,
            sdr_max_luminance = 220,
            sdr_min_luminance = 0.005,
            sdr_eotf = "srgb",
        },
        {
            output = "DP-4",
            mode = "3440x1440@60",
            position = "-3440x0",
            scale = 1,
            bitdepth = 10,
            cm = "hdr",
            sdrbrightness = 1.0,
            sdrsaturation = 1.3,
            sdr_max_luminance = 220,
            sdr_min_luminance = 0.005,
            sdr_eotf = "srgb",
        },
        {
            output = "eDP-2",
            mode = "2560x1600@60",
            position = "3840x0",
            scale = 1.33,
        },
    },
}

-- Fallback for unknown hosts or newly attached monitors.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

for _, monitor in ipairs(monitors_by_host[hostname()] or {}) do
    hl.monitor(monitor)
end

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "alacritty"
local menu = "rofi -show drun"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("dunst")
    hl.exec_cmd("tmux start-server")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("GTK_BACKEND", "wayland")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in = 0,
        gaps_out = { top = 0, right = 4, bottom = 0, left = 4 },
        border_size = 1,
        col = {
            active_border = "rgba(74c7ecff)",
            inactive_border = "rgba(585b70ff)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "scrolling",
    },

    decoration = {
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = false,
            size = 8,
            passes = 1,
            vibrancy = 0.1696,
        },
        shadow = {
            enabled = false,
            range = 8,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },

    render = {
        cm_auto_hdr = 1,
    },

    animations = {
        enabled = false,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = false,
        vrr = 1,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        mouse_refocus = false,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
            clickfinger_behavior = true,
            tap_to_click = true,
        },
    },
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/.local/scripts/launch-browser"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("wlr-which-key"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("web-bookmarks"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + N", hl.dsp.focus({ monitor = "+1" }))

hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))

hl.bind(mainMod .. " + ALT + H", hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.workspace.move({ monitor = "+1" }))

hl.bind("Print", hl.dsp.exec_cmd("/home/riley/.local/scripts/hypr-screenshot >> /home/riley/error.txt 2>&1"))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volume up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volume down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volume mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("backlight up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("backlight down"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("SHIFT + XF86AudioPrev", hl.dsp.exec_cmd("playerctl position 10-"))
hl.bind("SHIFT + XF86AudioNext", hl.dsp.exec_cmd("playerctl position 10+"))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.exec_cmd("playerctl position 10-"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("playerctl position 10+"))

hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))
hl.bind(mainMod .. " + Tab", hl.dsp.group.next())

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name = "thunderbird-calendar-alerts",
    match = {
        initial_class = "^(thunderbird)$",
        initial_title = "^(Calendar Reminders)$",
    },
    float = true,
    move = { 50, 50 },
    size = { 500, 500 },
})
