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

    readonly property int activeWsNumber: focusedWorkspace?.number ?? focusedWorkspace?.lastIpcObject?.num ?? 1

    property var occupiedWorkspaces: ({})

    function dispatch(request: string): void {
        I3.dispatch(request);
    }

    function monitorFor(screen: var): var {
        return I3.monitorFor(screen);
    }

    // Get occupied workspaces (workspaces with windows)
    function updateOccupiedWorkspaces(): var {
        const occupied = {};
        for (const ws of workspaces.values) {
            const num = ws.number ?? ws.lastIpcObject?.num;
            const repr = ws.lastIpcObject?.representation ?? "";
            if (num !== undefined && num !== null) {
                occupied[num] = repr.length > 0;
            }
        }
        occupiedWorkspaces = occupied;
    }

    function refreshWorkspaceState(): void {
        I3.refreshWorkspaces();
        updateOccupiedWorkspaces();
    }

    // Refresh timer to ensure updates when events are missed
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            refreshWorkspaceState();
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
                refreshWorkspaceState()
                I3.refreshMonitors()
            } else if (["openwindow", "closewindow", "movewindow"].includes(n)) {
                refreshWorkspaceState()
            } else if (n.includes("workspace")) {
                refreshWorkspaceState()
            } else if (n.includes("window")) {
                refreshWorkspaceState()
            }
        }
    }

    Component.onCompleted: {
        refreshWorkspaceState()
    }
}
