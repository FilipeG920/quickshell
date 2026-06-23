import Quickshell
import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../../config" as QsConfig
import "../../../services" as QsServices

// Clean workspace container - no outer pill
Item {
    id: root
    
    property var screen
    
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    readonly property var sway: QsServices.Sway
    readonly property int activeWsNumber: sway.activeWsNumber
    readonly property var occupied: sway.occupiedWorkspaces
    
    implicitWidth: layout.implicitWidth
    implicitHeight: config.bar.height - config.bar.padding * 2
    
    RowLayout {
        id: layout
        
        anchors.centerIn: parent
        spacing: root.config.bar.workspaces.spacing
        
        Repeater {
            id: workspaceRepeater
            model: root.config.bar.workspaces.count
            
            delegate: Loader {
                required property int index
                
                source: "Workspace.qml"
                asynchronous: false
                
                onLoaded: {
                    item.workspaceId = index + 1
                    item.isActive = Qt.binding(() => root.activeWsNumber === (index + 1))
                    item.isOccupied = Qt.binding(() => root.occupied[index + 1] ?? false)
                    item.clicked.connect(function() {
                        if (root.sway.activeWsNumber !== item.workspaceId) {
                            root.sway.dispatch(`workspace ${item.workspaceId}`)
                        }
                    })
                }
            }
        }
    }
}
