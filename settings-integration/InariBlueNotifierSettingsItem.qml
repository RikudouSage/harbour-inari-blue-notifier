import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import Nemo.DBus 2.0

SettingItem {
    id: root

    property int leftMargin: Theme.horizontalPageMargin
    property int rightMargin: Theme.horizontalPageMargin

    implicitHeight: Math.max(Theme.itemSizeSmall, label.height + 2 * Theme.paddingMedium)

    onClicked: activation.call("open", undefined, function() {}, function(error, message) {
        console.warn("Failed to open Inari Blue Notifier:", error, message)
    })

    DBusInterface {
        id: activation

        bus: DBus.SessionBus
        service: "dev.rikudou.inari-blue-notifier"
        path: "/dev/rikudou/InariBlueNotifier"
        iface: "dev.rikudou.InariBlueNotifier"
    }

    Image {
        id: icon

        x: root.leftMargin
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.iconSizeMedium
        height: width
        source: "file:///usr/share/icons/hicolor/86x86/apps/harbour-inari-blue-notifier.png"
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: label

        text: "Inari Blue Notifier"
        truncationMode: TruncationMode.Fade
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
        anchors {
            left: icon.right
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: root.rightMargin
        }
    }
}
