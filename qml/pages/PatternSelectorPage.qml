import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    property alias patterns: listView.model
    signal itemSelected(string name)

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
                itemSelected(modelData.name)
                pageStack.pop()
            }
        }
    }
}
