-- iOS Glass theme (light variant): bright, translucent, rounded, using the
-- hyprglass plugin for the frosted "Liquid Glass" window/layer effect.

-- A fixed `sleep N && force_renderer_reload` guess is flaky -- how long
-- "settled" takes isn't constant, so it sometimes fires before the reload
-- has actually committed and does nothing. `config.reloaded` is Hyprland's
-- own signal for "this reload just finished", so kick the renderer from
-- that instead of guessing a delay. Subscriptions outlive the reload that
-- registers them (each reload adds another, since Lua state doesn't carry
-- over to know one's already there), so remove this one the moment it
-- fires -- otherwise the pile-up would still be running on every future
-- reload no matter which theme is active by then, which is exactly the
-- kind of reaching into another theme's session this file shouldn't do.
-- force_renderer_reload alone fixes the blur render targets (size/passes)
-- but NOT window opacity: windows that were already open under a theme
-- without the "-default-opacity" tag removal below (any non-glass theme, or
-- glass itself before this rule existed) keep the stale "default-opacity"
-- tag forever -- Hyprland only assigns/removes `tag` on window open, never
-- retroactively on reload -- so their opacity rule flips between "1 1" and
-- "0.7 0.55" depending on which windowrule the engine happens to resolve
-- last, and that resolution only lands on the terminal-tag rule (opacity
-- 1 1, i.e. full blur) after a SECOND reload once this one has settled.
-- Confirmed by hand: after switching to this theme, a bare `hyprctl reload`
-- reliably restores the terminal's blur/opacity that the switch itself
-- left broken. This marker makes that second reload automatic while
-- guaranteeing exactly one -- the second reload's own config.reloaded fires
-- this same handler again (fresh Lua state, so it can't just check a local
-- flag), finds the marker, deletes it, and stops instead of chaining a
-- third reload.
local blur_kick_marker = "/tmp/omarchy-glass-white-blur-kick"

local blur_kick_subscription
blur_kick_subscription = hl.on("config.reloaded", function()
  hl.dispatch(hl.dsp.force_renderer_reload())
  if blur_kick_subscription then blur_kick_subscription:remove() end

  local marker = io.open(blur_kick_marker, "r")
  if marker then
    marker:close()
    os.remove(blur_kick_marker)
  else
    io.open(blur_kick_marker, "w"):close()
    hl.exec_cmd("sleep 0.3 && hyprctl reload")
  end
end)

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
      size = 10,
      passes = 4,
      new_optimizations = true,
      contrast = 1.0,
      brightness = 1.0,
      noise = 0.0,
    },
  },
})

-- Terminal transparency is fully owned by foot.ini's own alpha (0.3) so it
-- composites correctly with Hyprland's blur behind it. Leaving it tagged
-- default-opacity would multiply that alpha by the rule below (0.3 * 0.7 =
-- ~0.21), making the terminal noticeably more washed-out/blurred-looking
-- than every other glass surface.
o.window({ tag = "terminal" }, { tag = "-default-opacity", opacity = "1 1" })

-- Self-hosted/custom web apps launched via omarchy-launch-webapp get an
-- auto-generated "chrome-<host>__-<profile>" class (confirmed live via
-- `hyprctl clients` -- e.g. "chrome-192.168.1.142__-Default"), which doesn't
-- match browser.lua's own "(google-)?[cC]hrom(e|ium)" class regex (Hyprland
-- class matching is a full match, not a substring search, so the trailing
-- "-<host>__-<profile>" breaks it). That leaves them tagged default-opacity
-- and glass-tinted like a normal window instead of reading like Chrome.
-- Same opt-out browser.lua gives the main browser window.
o.window("chrome-.*", { tag = "-default-opacity", opacity = "1.0 0.985" })

-- Same low opacity as the dark variant -- genuinely see-through, not just a
-- light-colored panel. This is the fallback for ordinary app windows
-- (anything not opted out above) -- the bar/menu/popups/notifications glass
-- look lives in shell.toml instead, so it doesn't drag web apps and other
-- chromium-class windows that don't match browser.lua's regex down to the
-- same low opacity as the shell.
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
    tint_color = 0xf2f2f700,

    light = neutral_light,
    dark = neutral_dark,

    layers = { enabled = true },
  })

  -- Every Quickshell surface namespace whitelisted so the real hyprglass
  -- refraction (not just plain hl.layer_rule blur below) covers all of them,
  -- not only the bar. Names confirmed via `hyprctl layers` while each panel
  -- was open.
  hg.layer("omarchy-bar", { preset = "clear", mask_threshold = 0.05 })
  hg.layer("omarchy-menu", { preset = "clear", mask_threshold = 0.05 })
  hg.layer("omarchy-image-selector", { preset = "clear", mask_threshold = 0.05 })
  hg.layer("omarchy-emojis", { preset = "clear", mask_threshold = 0.05 })
  hg.layer("omarchy-clipboard", { preset = "clear", mask_threshold = 0.05 })
  hg.layer("omarchy-keyboard-panel", { preset = "clear", mask_threshold = 0.05 })
  hg.layer("omarchy-osd", { preset = "clear", mask_threshold = 0.05 })
  hg.layer("omarchy-notifications", { preset = "clear", mask_threshold = 0.05 })

  -- blur_strength/iterations pushed to their practical maximum (iterations
  -- is hard-capped at 5 by the plugin) for the strongest frost the effect
  -- supports.
  hg.preset("clear", {
    glass_opacity = 1.0,
    blur_strength = 30.0,
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
