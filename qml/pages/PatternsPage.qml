import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.DBus 2.0

import "../components"

Page {
    property bool anyPlaying: false
    property string errorText
    property var globalApp: app

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

            PatternButton {
                //% "Incoming call"
                label: qsTrId("patterns.active.call")
                pattern: appSettings.callPattern
                onError: errorText = error
                onPatternResolved: appSettings.callPattern = pattern
            }

            PatternButton {
                //% "Notifications"
                label: qsTrId("patterns.active.notifications")
                pattern: appSettings.notificationsPattern
                onError: errorText = error
                onPatternResolved: appSettings.notificationsPattern = pattern
            }

            PatternButton {
                //% "Off"
                label: qsTrId("patterns.active.off")
                pattern: appSettings.offPattern
                onError: errorText = error
                onPatternResolved: appSettings.offPattern = pattern
            }

            ExpandingSectionGroup {
                currentIndex: -1

                ExpandingSection {
                    //% "More patterns"
                    title: qsTrId("patterns.more")

                    content.sourceComponent: Column {
                        width: parent.width
                        spacing: Theme.paddingLarge

                        PatternButton {
                            //% "Incoming call from favourites"
                            label: qsTrId("patterns.active.favourite_call")
                            defaultKind: 'calls'
                            pattern: appSettings.favoriteCallPattern
                            onError: errorText = error
                            onPatternResolved: appSettings.favoriteCallPattern = pattern
                            onDefaultSelected: appSettings.favoriteCallPattern = {}
                        }

                        PatternButton {
                            //% "SMS"
                            label: qsTrId("patterns.active.sms")
                            defaultKind: 'notifications'
                            pattern: appSettings.smsPattern
                            onError: errorText = error
                            onPatternResolved: appSettings.smsPattern = pattern
                            onDefaultSelected: appSettings.smsPattern = {}
                        }

                        PatternButton {
                            //% "Email"
                            label: qsTrId("patterns.active.email")
                            defaultKind: 'notifications'
                            pattern: appSettings.emailPattern
                            onError: errorText = error
                            onPatternResolved: appSettings.emailPattern = pattern
                            onDefaultSelected: appSettings.emailPattern = {}
                        }

                        PatternButton {
                            //: This is the Signal app, probably don't translate
                            //% "Signal"
                            label: qsTrId("patterns.active.signal")
                            defaultKind: 'notifications'
                            pattern: appSettings.signalPattern
                            onError: errorText = error
                            onPatternResolved: appSettings.signalPattern = pattern
                            onDefaultSelected: appSettings.signalPattern = {}
                        }

                        PatternButton {
                            //: This is the Matrix protocol, probably don't translate
                            //% "Matrix"
                            label: qsTrId("patterns.active.matrix")
                            defaultKind: 'notifications'
                            pattern: appSettings.matrixPattern
                            onError: errorText = error
                            onPatternResolved: appSettings.matrixPattern = pattern
                            onDefaultSelected: appSettings.matrixPattern = {}
                        }
                    }
                }
            }

            ExpandingSection {
                visible: appSettings.customPatterns.length > 0
                //% "Custom patterns"
                title: qsTrId("patterns.custom")

                content.sourceComponent: Column {
                    width: parent.width
                    spacing: Theme.paddingLarge

                    Repeater {
                        model: appSettings.customPatterns

                        PatternButton {
                            appOverride: page.globalApp
                            label: modelData.name
                            defaultKind: 'notifications'
                            pattern: modelData.pattern
                            onError: errorText = error
                            onPatternResolved: appSettings.updateCustomPattern({name: modelData.name, pattern: pattern})
                            onDefaultSelected: appSettings.updateCustomPattern({name: modelData.name, pattern: {}})
                        }
                    }
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
