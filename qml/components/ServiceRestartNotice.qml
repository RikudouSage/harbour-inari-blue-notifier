import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    //% "Service restart required"
    property string title: qsTrId("service_restart_notice.title")
    //% "Restart the service to apply your changes."
    property string message: qsTrId("service_restart_notice.message")

    width: parent ? parent.width : implicitWidth
    implicitWidth: Math.max(titleLabel.implicitWidth, messageLabel.implicitWidth)
                   + Theme.paddingLarge * 2
    implicitHeight: content.implicitHeight + Theme.paddingLarge * 2

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightColor
    }

    Column {
        id: content
        x: Theme.paddingLarge
        y: Theme.paddingLarge
        width: parent.width - Theme.paddingLarge * 2
        spacing: Theme.paddingSmall

        Label {
            id: titleLabel
            width: parent.width
            text: root.title
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            wrapMode: Text.WordWrap
        }

        Label {
            id: messageLabel
            width: parent.width
            text: root.message
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
        }
    }
}
