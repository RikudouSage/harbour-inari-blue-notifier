import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: label
        anchors.centerIn: parent
        //: The app name, you may or may not translate it, it's up to you.
        //% "Inari Blue Notifier"
        text: qsTrId("app.name")
    }

    CoverActionList {
        enabled: app.unitActiveState === "active"

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
            onTriggered: {
                systemd.call("StopUnit", [
                    "inari-blue-notifier-daemon.service",
                    "replace"
                ]);
            }
        }
    }

    CoverActionList {
        enabled: app.unitActiveState === "inactive"

        CoverAction {
            iconSource: "image://theme/icon-cover-play"
            onTriggered: {
                systemd.call("StartUnit", [
                    "inari-blue-notifier-daemon.service",
                    "replace"
                ]);
            }
        }
    }
}
