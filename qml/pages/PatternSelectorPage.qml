import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    readonly property string defaultId: '**defaultPattern**'

    property bool withDefaults: false
    property string defaultKind
    property alias patterns: listView.model

    signal itemSelected(string name)
    signal defaultSelected()

    SilicaListView {
        id: listView
        anchors.fill: parent
        header: PageHeader {
            //% "Choose a pattern"
            title: qsTrId("pattern_selector.title")
        }

        VerticalScrollDecorator {}

        delegate: ListItem {
            StandardLabel {
                text: modelData.name
            }

            onClicked: {
                if (typeof modelData.id !== 'undefined' && modelData.id === defaultId) {
                    defaultSelected();
                } else {
                    itemSelected(modelData.name)
                }

                pageStack.pop()
            }
        }
    }

    Component.onCompleted: {
        if (withDefaults && defaultKind) {
            const newPatterns = [];

            if (defaultKind === 'notifications') {
                //% "Same as notifications"
                newPatterns.push({name: qsTrId("pattern_select.default_notifications"), id: defaultId});
            }
            if (defaultKind === 'calls') {
                //% "Same as calls"
                newPatterns.push({name: qsTrId("pattern_select.default_calls"), id: defaultId});
            }

            for (var i in patterns) {
                if (!patterns.hasOwnProperty(i)) {
                    continue;
                }
                newPatterns.push(patterns[i]);
            }

            patterns = newPatterns;
        }
    }
}
