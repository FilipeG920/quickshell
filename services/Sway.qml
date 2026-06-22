pragma Singleton

import Quickshell
import Quickshell.I3
import QtQuick 6.10

Singleton {
    id: root

    readonly property var monitors: I3.monitors
    readonly property var workspaces: I3.workspaces

    readonly property var focusedMonitor: I3.focusedMonitor
    readonly property var focusedWorkspace: I3.focusedWorkspace

    readonly property int activeWsId: focusedWorkspace?.id ?? 1

    function dispatch(request: string): void {
        I3.dispatch(request);
    }

    function monitorFor(screen: var): var {
        return I3.monitorFor(screen);
    }

    // Get occupied workspaces (workspaces with windows)
    function getOccupiedWorkspaces(): var {
        const occupied = {};
        for (const ws of workspaces.values) {
            occupied[ws.id] = (ws.lastIpcObject?.windows ?? 0) > 0;
        }
        return occupied;
    }

    // Refresh timer to ensure updates when events are missed
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            I3.refreshWorkspaces();
        }
    }

    Connections {
        target: I3

        function onRawEvent(event: var): void {
            const n = event?.name ?? ""

            if (n.length === 0)
                return

            if (n.endsWith("v2"))
                return

            if (["workspace", "moveworkspace", "activespecial", "focusedmon", "activewindow"].includes(n)) {
                I3.refreshWorkspaces()
                I3.refreshMonitors()
            } else if (["openwindow", "closewindow", "movewindow"].includes(n)) {
                I3.refreshWorkspaces()
            } else if (n.includes("workspace")) {
                I3.refreshWorkspaces()
            } else if (n.includes("window")) {
                I3.refreshWorkspaces()
            }
        }
    }
}
