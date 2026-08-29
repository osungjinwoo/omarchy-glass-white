# Glass White

The light companion to [Glass Black](https://github.com/osungjinwoo/omarchy-glass-black): an [Omarchy](https://omarchy.org) theme built to feel like iOS's Control Center — real frosted glass, not just a blurred rectangle. Uses the [hyprglass](https://github.com/hyprnux/hyprglass) plugin for actual refraction — chromatic aberration, fresnel edge highlighting, specular reflections and lens distortion on window borders — with every tone-mapping knob pinned back to neutral so whatever's behind the glass shows through in its true color, just blurred.

![preview](preview.png)

## Highlights

- Base palette straight from iOS system colors (`#FF3B30` red, `#007AFF` blue, `#34C759` green, etc.) on a `#F2F2F7` near-white background
- 20px rounded corners with high rounding power for that iOS-widget curve, soft drop shadows
- Translucent bar, launcher, notifications, lock screen, and popups all matched to the same glass material with native Hyprland layer blur as a fallback if the plugin isn't loaded
- Animated gradient border on the active window (`#3e6b96` → `#6b9bc7` at 45°)

## Install

Run these in order:

```
hyprpm add https://github.com/hyprnux/hyprglass
hyprpm enable hyprglass
hyprpm reload

omarchy-theme-install https://github.com/osungjinwoo/omarchy-glass-white

rm -rf ~/.config/omarchy/themes/glass-white/.git
omarchy-theme-set glass-white
```

What each part does:

1. **`hyprpm add/enable/reload`** — installs the [hyprglass](https://github.com/hyprnux/hyprglass) plugin, which drives the glass/refraction effect on window borders. Optional: skip it and you still get this theme's rounding, opacity, and native Hyprland layer blur on the bar/menus/notifications, just not the refraction effect.
2. **`omarchy-theme-install`** — clones this repo and applies it. On its own this only gets you the color palette and translucent bar/menu/notifications: Omarchy refuses to apply `.lua` or terminal-config files from a theme it just git-cloned (they can run code), so `hyprland.lua` and `foot.ini` are silently replaced with generic, recolored versions.
3. **`rm -rf .git` + `omarchy-theme-set`** — not optional, this is what actually unlocks the glass effect. Deleting the leftover `.git` from the clone makes Omarchy treat the theme as trusted, so reselecting it copies this repo's real `hyprland.lua` (hyprglass config, rounding, blur) and `foot.ini` instead of the generic versions. (Or delete `.git` first, then just reselect the theme from the Omarchy menu instead of running `omarchy-theme-set` by hand.)

## Wallpaper

One wallpaper is bundled in `backgrounds/`: a generic "abstract grainy texture" JPEG whose original source page couldn't be traced. If this is yours and you'd rather it not be here, open an issue.
