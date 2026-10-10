import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    id: page

    function getStatusLabel(state) {
        switch (state) {
        case "active":
        case "activating":
            //% "Active"
            return qsTrId("main.state.active");
        case "inactive":
        case "deactivating":
            //% "Inactive"
            return qsTrId("main.state.inactive");
        case "failed":
            //% "Failed"
            return qsTrId("main.state.failed");
        default:
            //% "Unknown"
            return qsTrId("main.state.unknown");
        }
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            visible: unitActiveState == "active" || unitActiveState == "inactive"

            MenuItem {
                text: unitActiveState == "active"
                        //% "Stop notifier"
                        ? qsTrId("main.deactivate")
                        //% "Start notifier"
                        : qsTrId("main.activate")

                onClicked: {
                    if (unitActiveState == "active") {
                        systemd.call("StopUnit", [
                            "inari-blue-notifier-daemon.service",
                            "replace"
                        ]);
                        return;
                    }

                    if (unitActiveState == "inactive") {
                        systemd.call("StartUnit", [
                            "inari-blue-notifier-daemon.service",
                            "replace"
                        ]);
                        return;
                    }
                }
            }
        }

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            PageHeader {
                //% "Inari Blue Notifier"
                title: qsTrId("app.name")
            }

            StandardLabel {
                //% "Using the pull down menu app you can control whether the background process blinking your Inari Blue on events like incoming calls is running or not."
                text: qsTrId("main.intro")
            }

            StandardLabel {
                //% "Current status: %1"
                text: qsTrId("main.current_status").arg(getStatusLabel(unitActiveState))
                color: unitActiveState === "failed" ? Theme.errorColor : Theme.highlightColor
            }

            StandardLabel {
                //% "Right now the app is rather simple, but no worries, more is coming!"
                text: qsTrId("main.more_coming")
                color: Theme.secondaryColor
            }
        }
    }
}
