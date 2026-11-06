# omarchy-workspaces: agent notes

Omarchy bar widget `zoltanf.workspaces`, cloned from `omarchy.workspaces` with
`omarchy plugin clone`. Public GitHub repo `zoltanf/omarchy-workspaces`,
created 2026-11-06. README.md covers features and install.

**Public repo:** keep home-network details out, and screenshots too, except
crops of the workspace numbers.

## State (2026-11-06)

- Works on the author's laptop (Omarchy 4.5.0-3). It is installed as a
  **symlink** `~/.config/omarchy/plugins/zoltanf.workspaces` pointing to this
  checkout. Apply edits with `omarchy restart shell`, then check with
  `grim -o eDP-1` / `grim -o DP-1`.
- Why it exists: in 4.5, WidgetButton renders a single private-use glyph label
  through OpticalGlyph at `Style.bar.iconSize`. The stock widget's active-glyph
  marker therefore shows up as a filled black square.
- Dead end: a zero-width space next to the glyph (so it is no longer one code
  point) did not change the look. The glyph is a filled square by design.
- Highlight color: `foreground` at 25% alpha. The theme's `selection` color
  (e.g. #d1d1d6) is not exposed by `Commons/Color.qml` and was too light anyway.
- `activeId` comes from `Hyprland.monitors[screen].activeWorkspace`. It falls
  back to `Hyprland.focusedWorkspace`. Switching workspaces live was not tested
  when this was added; the initial render was correct on both monitors.
