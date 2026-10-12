import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    property bool initialized: false

    function trackChange(callback) {
        callback();

        if (!initialized) {
            return;
        }

        app.serviceNeedsRestart = true
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                //% "Patterns"
                text: qsTrId("patterns.title")
                onClicked: {
                    pageStack.push("PatternsPage.qml")
                }
            }
        }

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            PageHeader {
                //% "Settings"
                title: qsTrId("settings.title")
            }

            ServiceRestartNotice {
                visible: app.serviceNeedsRestart
            }

            StandardLabel {
                //% "Configure the patterns using the pull down menu."
                text: qsTrId("settings.pull_down_hint")
                color: Theme.secondaryColor
            }

            SectionHeader {
                //% "Events"
                text: qsTrId("settings.events")
            }

            StandardLabel {
                //% "Configure whether the Inari Blue TOH reacts to the following events."
                text: qsTrId("settings.events.description")
                font.pixelSize: Theme.fontSizeSmall
            }

            TextSwitch {
                //% "Incoming calls"
                text: qsTrId("settings.events.calls")
                checked: appSettings.callsEnabled
                onCheckedChanged: trackChange(function() {
                    appSettings.callsEnabled = checked;
                })
            }

            TextSwitch {
                //% "Incoming calls from favourite contacts"
                text: qsTrId("settings.events.favorite_calls")
                checked: appSettings.favoriteCallsEnabled
                onCheckedChanged: trackChange(function() {
                    appSettings.favoriteCallsEnabled = checked;
                })
            }

            TextSwitch {
                //% "Active notifications"
                text: qsTrId("settings.events.notifications")
                checked: appSettings.notificationsEnabled
                onCheckedChanged: trackChange(function() {
                    appSettings.notificationsEnabled = checked;
                })
            }
        }
    }

    Component.onCompleted: initialized = true
}
