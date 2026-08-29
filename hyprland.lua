-- iOS Glass theme (light variant): bright, translucent, rounded, using the
-- hyprglass plugin for the frosted "Liquid Glass" window/layer effect.

local active_border_color = { colors = { "rgba(3e6b96dd)", "rgba(6b9bc7dd)" }, angle = 45 }
local inactive_border_color = "rgba(d1d1d677)"

hl.config({
  general = {
    border_size = 2,
    gaps_in = 8,
    gaps_out = 18,

    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    rounding = 20,
    rounding_power = 4,

    shadow = {
      enabled = true,
      range = 24,
      render_power = 3,
      color = "rgba(00000055)",
      color_inactive = "rgba(00000033)",
    },

    blur = {
      enabled = true,
      size = 60,
      passes = 10,
      new_optimizations = false,
    },
  },
})

-- Same low opacity as the dark variant -- genuinely see-through, not just a
-- light-colored panel.
o.window({ tag = "default-opacity" }, { opacity = "0.7 0.55" })

-- Native Hyprland layer blur for the Quickshell surfaces (bar, menu/launcher/
-- emojis/clipboard/keyboard-panel, OSD, notifications). shell.toml gives
-- these surfaces their own alpha; this makes sure Hyprland actually blurs
-- what's behind them too, rather than relying only on hyprglass's hg.layer
-- (which currently only covers omarchy-bar) -- so the frosted look survives
-- even if the plugin fails to load. ignore_alpha = 0 blurs through fully
-- transparent regions too (equivalent to the .conf `ignorezero` directive).
-- Pattern mirrors the namespace regex Omarchy itself uses in
-- default/hypr/apps/omarchy-shell.lua for animation rules.
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({
  match = { namespace = "^(omarchy-menu|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel)$" },
  blur = true,
  ignore_alpha = 0,
})
hl.layer_rule({ match = { namespace = "omarchy-osd" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "omarchy-notifications" }, blur = true, ignore_alpha = 0 })

-- hyprglass is loaded via `hyprpm` (see https://github.com/hyprnux/hyprglass).
--
-- Loaded via exec_on_start (after the compositor's event loop is already
-- running) rather than a config-time `plugin =` directive (loaded
-- synchronously during config parse) -- that synchronous path is what hung
-- Hyprland before. `hyprctl reload` afterward re-runs this file so the
-- `hl.plugin.hyprglass` block below actually applies once the plugin exists.
o.exec_on_start("hyprpm reload && hyprctl reload")
--
-- iOS-widget preset: genuinely transparent frosted material (like a Control
-- Center/home-screen widget) -- what's behind the glass should read through
-- in its own color, just blurred. The stock hyprglass tone-mapping defaults
-- (saturation < 1, adaptive_dim/adaptive_boost > 0 on both themes) bake in a
-- deliberate gray wash, so every tone-mapping knob below is pinned back to
-- neutral (full saturation, brightness/contrast at 1.0, adaptive_dim/boost
-- near zero) for both the light and dark variants rather than left at those
-- defaults. "glass" ("solid glass block effect with a lot of chromatic
-- aberration" per the plugin's own preset description) is also swapped for
-- "clear" ("minimal transparent effect, like a transparent rounded border
-- glass plate"), which is the built-in preset actually meant for this look.
if hl.plugin.hyprglass then
  local hg = hl.plugin.hyprglass

  local neutral_light = {
    brightness = 1.0,
    contrast = 1.0,
    saturation = 1.0,
    vibrancy = 0.0,
    adaptive_boost = 0.05,
    adaptive_dim = 0.05,
  }
  local neutral_dark = neutral_light

  hg.config({
    default_theme = "light",
    default_preset = "clear",
    tint_color = 0xf2f2f712,

    light = neutral_light,
    dark = neutral_dark,

    layers = { enabled = true },
  })

  -- omarchy-bar is the taskbar's layer namespace (confirmed via `hyprctl layers`).
  hg.layer("omarchy-bar", { preset = "clear", mask_threshold = 0.05 })

  hg.preset("clear", {
    glass_opacity = 1.0,
    blur_strength = 15.0,
    blur_iterations = 5,
    refraction_strength = 0.15,
    chromatic_aberration = 0.05,
    fresnel_strength = 0.2,
    specular_strength = 0.3,
    lens_distortion = 0.1,
    edge_thickness = 0.05,
    light = neutral_light,
    dark = neutral_dark,
  })
end
