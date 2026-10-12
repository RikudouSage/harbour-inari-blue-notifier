import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.DBus 2.0

import "../components"

Page {
    property bool anyPlaying: false
    property string errorText

    id: page

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                //% "Add a pattern"
                text: qsTrId("patterns.add")
                onClicked: {
                    const dialog = pageStack.push("EditPatternPage.qml");
                    dialog.accepted.connect(function() {
                        appSettings.updatePattern(dialog.pattern);
                    });
                }
            }

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
        }

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            PageHeader {
                //% "Patterns"
                title: qsTrId("patterns.title")
            }

            ServiceRestartNotice {
                visible: app.serviceNeedsRestart
            }

            SectionHeader {
                //% "Active patterns"
                text: qsTrId("patterns.active")
            }

            ValueButton {
                //% "Incoming call"
                label: qsTrId("patterns.active.call")
                value: typeof appSettings.callPattern.name !== 'undefined' ? appSettings.callPattern.name : ''

                onClicked: {
                    const dialog = pageStack.push("PatternSelectorPage.qml", {
                        patterns: appSettings.storedPatterns,
                    });
                    dialog.itemSelected.connect(function(name) {
                        const found = appSettings.patternByName(name);
                        if (!found.name) {
                            //% "A pattern with the name '%1' was not found.
                            errorText = qsTrId("patterns.not_found").arg(name)
                            return;
                        }

                        appSettings.callPattern = found;
                        app.serviceNeedsRestart = true;
                    });
                }
            }

            ValueButton {
                //% "Incoming call from favorites"
                label: qsTrId("patterns.active.favourite_call")
                value: typeof appSettings.favoriteCallPattern.name !== 'undefined' ? appSettings.favoriteCallPattern.name : ''
                enabled: app.contactsUnitActiveState === 'active'

                onClicked: {
                    const dialog = pageStack.push("PatternSelectorPage.qml", {
                        patterns: appSettings.storedPatterns,
                    });
                    dialog.itemSelected.connect(function(name) {
                        const found = appSettings.patternByName(name);
                        if (!found.name) {
                            //% "A pattern with the name '%1' was not found.
                            errorText = qsTrId("patterns.not_found").arg(name)
                            return;
                        }

                        appSettings.favoriteCallPattern = found;
                        app.serviceNeedsRestart = true;
                    });
                }
            }

            StandardLabel {
                visible: errorText !== ''
                text: errorText
                color: Theme.errorColor
            }

            SectionHeader {
                //% "All patterns"
                text: qsTrId("patterns.stored")
            }

            Repeater {
                model: appSettings.storedPatterns

                ListItem {
                    id: patternItem
                    property bool playing: false

                    contentHeight: Theme.itemSizeSmall

                    Label {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.horizontalPageMargin
                            right: playButton.left
                            rightMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                        }
                        text: modelData.name
                        truncationMode: TruncationMode.Fade
                    }

                    IconButton {
                        enabled: !anyPlaying || patternItem.playing

                        id: playButton
                        anchors {
                            right: parent.right
                            rightMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                        }
                        icon.source: patternItem.playing
                                     ? "image://theme/icon-m-stop"
                                     : "image://theme/icon-m-play"
                        onClicked: {
                            patternItem.playing = !patternItem.playing;
                            anyPlaying = patternItem.playing;

                            if (patternItem.playing) {
                                daemon.playPattern(modelData);
                            } else {
                                daemon.stopPlaying();
                            }
                        }
                    }

                    menu: ContextMenu {
                        MenuItem {
                            //% "Edit pattern"
                            text: qsTrId("edit_pattern.title")
                            onClicked: {
                                const dialog = pageStack.push("EditPatternPage.qml", {
                                    pattern: modelData
                                });
                                dialog.accepted.connect(function() {
                                    appSettings.updatePattern(dialog.pattern, modelData.name);
                                });
                            }
                        }

                        MenuItem {
                            //% "Remove"
                            text: qsTrId("patterns.remove")
                            onClicked: {
                                remorseDelete(function() {
                                    var patterns = appSettings.storedPatterns;
                                    patterns = patterns.filter(function(pattern) {
                                        return pattern.name !== modelData.name;
                                    });
                                    appSettings.storedPatterns = patterns;
                                });
                            }
                        }
                    }
                }
            }
        }
    }
}
