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

    function timeIsZero(date) {
        return date.getHours() === 0 && date.getMinutes() === 0 && date.getSeconds() === 0;
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

            SectionHeader {
                //% "Constraints"
                text: qsTrId("settings.constraints")
            }

            TextSwitch {
                id: editDatesSwitch
                //% "Disable TOH at certain times"
                text: qsTrId("settings.enable_time_constraints")
                checked: !timeIsZero(appSettings.startTime) || !timeIsZero(appSettings.endTime)
                onCheckedChanged: {
                    if (!checked) {
                        appSettings.startTime = new Date(2000, 0, 1, 0, 0);
                        appSettings.endTime = new Date(2000, 0, 1, 0, 0);
                        app.serviceNeedsRestart = true;
                    }
                }
            }

            ValueButton {
                //% "Start TOH at"
                label: qsTrId("settings.start_time")
                value: appSettings.startTime.toLocaleTimeString(undefined, Locale.ShortFormat)
                enabled: editDatesSwitch.checked
                onClicked: {
                    const dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                        hour: appSettings.startTime.getHours(),
                        minute: appSettings.startTime.getMinutes(),
                    });
                    dialog.accepted.connect(function() {
                        appSettings.startTime = dialog.time;
                        app.serviceNeedsRestart = true;
                    });
                }
            }

            ValueButton {
                //% "Stop TOH at"
                label: qsTrId("settings.end_time")
                value: appSettings.endTime.toLocaleTimeString(undefined, Locale.ShortFormat)
                enabled: editDatesSwitch.checked
                onClicked: {
                    const dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                        hour: appSettings.endTime.getHours(),
                        minute: appSettings.endTime.getMinutes(),
                    });
                    dialog.accepted.connect(function() {
                        appSettings.endTime = dialog.time;
                        app.serviceNeedsRestart = true;
                    });
                }
            }
        }
    }

    Component.onCompleted: initialized = true
}
