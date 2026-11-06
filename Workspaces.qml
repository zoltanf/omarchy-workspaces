import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // With more than one monitor, workspaces that belong to this bar's monitor
  // are underlined. An existing workspace belongs where it actually is; an
  // empty one belongs where a `monitor = ...` workspace rule would open it.
  property var monitorInfo: []
  property var workspaceRules: []

  readonly property string screenName: {
    var window = root.QsWindow.window
    return window && window.screen ? String(window.screen.name || "") : ""
  }
  readonly property bool multiMonitor: Hyprland.monitors.values.length > 1

  // The workspace shown on this bar's monitor (not the globally focused one).
  readonly property int activeId: {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (monitors[i].name === screenName && monitors[i].activeWorkspace) return monitors[i].activeWorkspace.id
    }
    return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
  }

  function refreshLayout() {
    if (!layoutProc.running) layoutProc.running = true
  }

  function selectorMatches(selector, monitor) {
    if (!selector || !monitor) return false
    if (selector.indexOf("desc:") === 0) {
      var desc = selector.substring(5)
      return String(monitor.description || "").indexOf(desc) === 0
    }
    return selector === monitor.name
  }

  function onThisMonitor(id) {
    if (!multiMonitor || screenName === "") return false

    var workspace = workspaceById(id)
    if (workspace !== null && workspace.monitor) return workspace.monitor.name === screenName

    var monitor = null
    for (var i = 0; i < monitorInfo.length; i++) {
      if (monitorInfo[i].name === screenName) monitor = monitorInfo[i]
    }
    for (var j = 0; j < workspaceRules.length; j++) {
      var rule = workspaceRules[j]
      if (rule.workspaceString === String(id) && rule.monitor) return selectorMatches(rule.monitor, monitor)
    }
    return false
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  Component.onCompleted: refreshLayout()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event.name
      if (name === "configreloaded" || name.indexOf("monitoradded") === 0 || name.indexOf("monitorremoved") === 0)
        root.refreshLayout()
    }
  }

  Process {
    id: layoutProc
    command: ["sh", "-c", "printf '{\"monitors\":%s,\"rules\":%s}' \"$(hyprctl -j monitors)\" \"$(hyprctl -j workspacerules)\""]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var parsed = JSON.parse(text || "{}")
          root.monitorInfo = parsed.monitors || []
          root.workspaceRules = parsed.rules || []
        } catch (e) {}
      }
    }
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        id: button
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: root.activeId === modelData
        readonly property bool local: root.onThisMonitor(modelData)

        bar: root.bar
        text: modelData === 10 ? "0" : String(modelData)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }

        // The workspace shown on this monitor keeps its number on a faint
        // background, a tint of the bar's text color (works on any theme).
        Rectangle {
          z: -1
          visible: button.focused
          width: Math.max(8, button.labelWidth) + Style.space(8)
          height: Math.round(button.fontSize * 1.5)
          radius: Style.space(3)
          color: Qt.rgba(button.foreground.r, button.foreground.g, button.foreground.b, 0.25)
          anchors.centerIn: parent
        }

        Rectangle {
          visible: button.local
          width: Math.max(8, button.labelWidth)
          height: 2
          radius: 1
          color: button.foreground
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          anchors.bottomMargin: Math.round(root.barSize * 0.18)
        }
      }
    }
  }
}
