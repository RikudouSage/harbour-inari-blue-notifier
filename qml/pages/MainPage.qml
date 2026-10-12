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

    function stopUnit() {
        systemd.call("StopUnit", [
            "inari-blue-notifier-daemon.service",
            "replace"
        ]);
        app.serviceNeedsRestart = false;
    }

    function startUnit() {
        systemd.call("StartUnit", [
            "inari-blue-notifier-daemon.service",
            "replace"
        ]);
    }

    function restartUnit() {
        systemd.call("RestartUnit", [
            "inari-blue-notifier-daemon.service",
            "replace"
        ]);
        app.serviceNeedsRestart = false;
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                visible: unitActiveState == "active" || unitActiveState == "inactive"
                text: unitActiveState == "active"
                        //% "Stop notifier"
                        ? qsTrId("main.deactivate")
                        //% "Start notifier"
                        : qsTrId("main.activate")

                onClicked: {
                    if (unitActiveState == "active") {
                        stopUnit();
                        return;
                    }

                    if (unitActiveState == "inactive") {
                        startUnit();
                        return;
                    }
                }
            }

            MenuItem {
                visible: unitActiveState == "active"
                //% "Restart notifier"
                text: qsTrId("main.restart")

                onClicked: {
                    restartUnit();
                }
            }

            MenuItem {
                //% "Settings"
                text: qsTrId("settings.title")
                onClicked: pageStack.push("SettingsPage.qml");
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

            ServiceRestartNotice {
                visible: app.serviceNeedsRestart
            }

            StandardLabel {
                //% "Using the pull down menu app you can configure the patterns and control the active state of the background process."
                text: qsTrId("main.intro")
            }

            StandardLabel {
                //% "Current status: %1"
                text: qsTrId("main.current_status").arg(getStatusLabel(unitActiveState))
                color: unitActiveState === "failed" ? Theme.errorColor : Theme.highlightColor
            }
            StandardLabel {
                //% "Contacts access status: %1"
                text: qsTrId("main.contacts_enabled").arg(getStatusLabel(contactsUnitActiveState))
                color: contactsUnitActiveState === "failed" ? Theme.errorColor : Theme.highlightColor
            }
        }
    }
}
