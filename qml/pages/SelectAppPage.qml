import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    property var packages: []
    signal packageSelected(string packageId)

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            PageHeader {
                //% "Select an app"
                title: qsTrId("select_app.title")
            }

            Repeater {
                model: packages

                Item {
                    width: parent.width
                    height: row.height

                    Row {
                        id: row
                        width: parent.width
                        spacing: Theme.paddingLarge

                        Image {
                            id: icon
                            source: modelData.iconPath
                            width: Theme.iconSizeLarge
                            height: width
                        }
                        Column {
                            width: parent.width - icon.width - parent.spacing * 2
                            Label {
                                text: modelData.name
                            }
                            Label {
                                text: modelData.packageId
                                color: Theme.secondaryColor
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            packageSelected(modelData.packageId)
                            pageStack.pop();
                        }
                    }
                }
            }
        }
    }
}
