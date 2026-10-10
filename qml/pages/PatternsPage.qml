import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
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
        }
    }
}
