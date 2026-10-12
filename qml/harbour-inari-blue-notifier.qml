import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import "pages"

ApplicationWindow {
    property string unitActiveState
    property string contactsUnitActiveState
    property bool serviceNeedsRestart: false

    id: app

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    DBusInterface {
        id: systemd

        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"

        Component.onCompleted: {
            call("Subscribe", undefined, function() {
                call("GetUnit",
                     ["inari-blue-notifier-daemon.service"],
                     function(unitPath) {
                         unit.path = unitPath
                     });
                call("GetUnit",
                     ["inari-blue-notifier-daemon-contacts.service"],
                     function(unitPath) {
                         contactsUnit.path = unitPath
                     })
            })
        }
    }

    DBusInterface {
        id: unit

        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        iface: "org.freedesktop.systemd1.Unit"

        propertiesEnabled: true

        property string activeState

        onActiveStateChanged: {
            unitActiveState = activeState
            console.log("Service state:", activeState)
        }
    }

    DBusInterface {
        id: contactsUnit

        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        iface: "org.freedesktop.systemd1.Unit"

        propertiesEnabled: true

        property string activeState

        onActiveStateChanged: {
            contactsUnitActiveState = activeState
            console.log("Contacts service state:", activeState)
        }
    }
}
