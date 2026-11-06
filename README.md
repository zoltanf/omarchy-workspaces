# omarchy-workspaces

An Omarchy bar widget (`zoltanf.workspaces`) that replaces the stock
`omarchy.workspaces`. Built for Omarchy 4.5 with more than one monitor.

![bar](preview.png)

- **Numbers stay visible.** Omarchy 4.5 turns the current workspace into a
  filled square. This widget keeps the number and puts a light background
  behind it instead.
- **One highlight per monitor.** Each monitor's bar highlights the workspace
  shown on that monitor, not only the one that has keyboard focus.
- **Underline for this monitor's workspaces.** With more than one monitor, the
  workspaces that belong to the bar's monitor are underlined. An existing
  workspace belongs to the monitor it is on. An empty one belongs to the
  monitor a `monitor = ...` workspace rule would open it on.
- Empty workspaces are dimmed. The highlight is a tint of the theme's text
  color, so it works with light and dark themes.

## Install

```sh
omarchy plugin add https://github.com/zoltanf/omarchy-workspaces.git --enable
```

The plugin declares itself a replacement for `omarchy.workspaces`
(`"clonedFrom": "omarchy.workspaces"` in `manifest.json`), so enabling it puts
it in the stock widget's place in the bar. No extra packages are needed.

## Removal

To go back to the stock widget, disable this one:

```sh
omarchy plugin disable zoltanf.workspaces
```

To uninstall it completely:

```sh
omarchy plugin remove zoltanf.workspaces
```

## License

MIT, see [LICENSE](LICENSE). The code comes from Omarchy's own workspaces
widget and keeps its MIT notice (© David Heinemeier Hansson,
[LICENSE.omarchy](LICENSE.omarchy)).
