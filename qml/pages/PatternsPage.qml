import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    property bool anyPlaying: false
    property string errorText

    id: page

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

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
                //% "Active call pattern"
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

                    /*menu: ContextMenu {
                        MenuItem {
                            //% "Edit"
                            text: qsTrId("patterns.edit")
                        }
                    }*/
                }
            }
        }
    }
}
