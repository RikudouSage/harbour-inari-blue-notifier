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
                text: app.contactsUnitActiveState === 'active'
                      //% "Disable contacts access"
                      ? qsTrId("patterns.disable_contacts")
                      //% "Enable contacts access"
                      : qsTrId("patterns.enable_contacts")
                onClicked: {
                    const serviceName = "inari-blue-notifier-daemon-contacts.service";

                    if (app.contactsUnitActiveState === 'active') {
                        systemd.call("DisableUnitFiles", [
                            [serviceName],
                            false
                        ]);
                        systemd.call("StopUnit", [
                            serviceName,
                            "replace"
                        ]);
                        return;
                    }

                    const dialog = pageStack.push("EnableContactsPage.qml");
                    dialog.accepted.connect(function() {
                        systemd.call("EnableUnitFiles", [
                            [serviceName],
                            false,
                            false
                        ]);
                        systemd.call("StartUnit", [
                            serviceName,
                            "replace"
                        ]);
                    });
                }
            }

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
                //% "Active notifications"
                text: qsTrId("settings.events.notifications")
                checked: appSettings.notificationsEnabled
                onCheckedChanged: trackChange(function() {
                    appSettings.notificationsEnabled = checked;
                })
            }

            ExpandingSectionGroup {
                currentIndex: -1

                ExpandingSection {
                    //% "More events"
                    title: qsTrId("settings.events.more")

                    content.sourceComponent: Column {
                        width: parent.width
                        spacing: Theme.paddingLarge

                        StandardLabel {
                            //% "Toggles in this section can override the behaviour of the parent ones. For example, if you disable calls but enable favourite calls, the TOH will only blink for calls from favourite callers."
                            text: qsTrId("settings.events.more.explanation")
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                        StandardLabel {
                            //% "And if you disable favourite calls but have normal calls enabled, the TOH will blink for favourite calls but it will use the pattern configured for calls, not the one configured for favourites."
                            text: qsTrId("settings.events.more.explanation2")
                            font.pixelSize: Theme.fontSizeExtraSmall
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
                            //% "SMS"
                            text: qsTrId("settings.events.sms")
                            checked: appSettings.smsEnabled
                            onCheckedChanged: trackChange(function() {
                                appSettings.smsEnabled = checked;
                            })
                        }
                        TextSwitch {
                            //% "Emails"
                            text: qsTrId("settings.events.email")
                            checked: appSettings.emailEnabled
                            onCheckedChanged: trackChange(function() {
                                appSettings.emailEnabled = checked;
                            })
                        }
                        TextSwitch {
                            //: This is the Signal app, probably don't translate
                            //% "Signal"
                            text: qsTrId("settings.events.signal")
                            checked: appSettings.signalEnabled
                            onCheckedChanged: trackChange(function() {
                                appSettings.signalEnabled = checked;
                            })
                        }
                    }
                    content.active: true
                }
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
