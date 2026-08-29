# Glass White

The light companion to [Glass Black](https://github.com/osungjinwoo/omarchy-glass-black): an [Omarchy](https://omarchy.org) theme built to feel like iOS's Control Center — real frosted glass, not just a blurred rectangle. Uses the [hyprglass](https://github.com/hyprnux/hyprglass) plugin for actual refraction — chromatic aberration, fresnel edge highlighting, specular reflections and lens distortion on window borders — with every tone-mapping knob pinned back to neutral so whatever's behind the glass shows through in its true color, just blurred.

![preview](preview.png)

## Highlights

- Base palette straight from iOS system colors (`#FF3B30` red, `#007AFF` blue, `#34C759` green, etc.) on a `#F2F2F7` near-white background
- 20px rounded corners with high rounding power for that iOS-widget curve, soft drop shadows
- Translucent bar, launcher, notifications, lock screen, and popups all matched to the same glass material with native Hyprland layer blur as a fallback if the plugin isn't loaded
- Animated gradient border on the active window (`#3e6b96` → `#6b9bc7` at 45°)

## Requirements

The glass/refraction effect on window borders needs the [hyprglass](https://github.com/hyprnux/hyprglass) Hyprland plugin. Installing the theme does **not** install this plugin — do it separately, once, via `hyprpm`:

```
hyprpm add https://github.com/hyprnux/hyprglass
hyprpm enable hyprglass
hyprpm reload
```

Without it, the theme still works — you get the color palette, rounding, and native Hyprland layer blur on the bar/menus/notifications — you just lose the refraction/chromatic-aberration effect on window borders.

## Wallpaper

No background image is bundled with this repo (to avoid redistributing a third-party image without a clear license — the original preview background is a generic "abstract grainy texture" JPEG whose source page couldn't be traced). Drop your own image into `~/.config/omarchy/themes/glass-white/backgrounds/` after installing, or set one via the Omarchy menu.

## Install

Via the terminal:

```
omarchy theme install https://github.com/osungjinwoo/omarchy-glass-white
```

Or via the Omarchy menu: `Super + Space` → *Install > Style > Theme* → paste this repo's URL.
